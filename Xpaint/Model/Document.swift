import SwiftUI
import UniformTypeIdentifiers
import Accelerate

struct Document<ContentType: TypeProvider>: FileDocument {
	var size: CanvasSize
	var pxs: [Px]

	static var readableContentTypes: [UTType] { [ContentType.type] }
	static var hasLayers: Bool { ContentType.type == .pxd }

	init() {
		size = CanvasSize(width: 32, height: 32, hasLayers: Self.hasLayers)
		pxs = size.alloc()
		withMutablePixel(0) { px in px = .white }
	}

	init<T: TypeProvider>(converting file: Document<T>) where T.ExportType == ContentType {
		size = file.size
		size.hasLayers = Self.hasLayers
		pxs = size.alloc()

		if !Self.hasLayers {
			file.pixelBuffers.forEach(pixelBuffers[0].merge)
		}
	}

	init(configuration: ReadConfiguration) throws {
		let data = try configuration.file.regularFileContents
			.throwing("Failed to read file")

		let image = try (NSBitmapImageRep(data: data)?.cgImage)
			.throwing("Failed to open image")

		if Self.hasLayers, image.height & 0b11 != 0 {
			throw Err("Corrupted file")
		}
		size = CanvasSize(
			width: image.width,
			height: image.height >> (Self.hasLayers ? 2 : 0),
			hasLayers: Self.hasLayers
		)
		pxs = size.alloc()
		draw(image)
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		let cgImage = try exportImage
			.throwing("Failed to create CGImage")

		let data = try NSBitmapImageRep(cgImage: cgImage)
			.representation(using: .png, properties: [:])
			.throwing("Failed to create PNG representation")

		return FileWrapper(regularFileWithContents: data)
	}

	subscript(_ pxl: PxL) -> Px {
		get {
			size.index(at: pxl).map { idx in
				pxs[idx]
			} ?? .clear
		}
		set {
			size.index(at: pxl).map { idx in
				pxs[idx] = newValue
			}
		}
	}

	private mutating func draw(_ image: CGImage) {
		pxs.withUnsafeMutableBytes { ptr in
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			if let ctx = CGContext(
				data: ptr.baseAddress,
				width: image.width,
				height: image.height,
				bitsPerComponent: 8,
				bytesPerRow: image.width * 4,
				space: colorSpace,
				bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
			) {
				ctx.interpolationQuality = .none
				ctx.draw(image, in: CGRect(
					origin: .zero,
					size: CGSize(width: image.width, height: image.height)
				))
			}
		}
	}

	private var exportImage: CGImage? {
		try? pxs.withUnsafeBytes { raw in
			let bytes = raw.bindMemory(to: UInt8.self)
			let data = try CFDataCreate(nil, bytes.baseAddress, bytes.count)
				.throwing("Can't make CFData")
			let provider = try CGDataProvider(data: data)
				.throwing("Can't make CGDataProvider")
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

			return try CGImage(
				width: size.width,
				height: size.height * size.layers,
				bitsPerComponent: 8,
				bitsPerPixel: 32,
				bytesPerRow: size.width * 4,
				space: colorSpace,
				bitmapInfo: bitmapInfo,
				provider: provider,
				decode: nil,
				shouldInterpolate: false,
				intent: .defaultIntent
			)
			.throwing("Can't make CGImage")
		}
	}

	private var layers: [CGImage] {
		(try? (0..<size.layers).map { layer in
			try pxs[range(layer)].withUnsafeBytes { raw in
				let bytes = raw.bindMemory(to: UInt8.self)
				let data = try CFDataCreate(nil, bytes.baseAddress, bytes.count)
					.throwing("Can't make CFData")
				let provider = try CGDataProvider(data: data)
					.throwing("Can't make CGDataProvider")
				let colorSpace = CGColorSpaceCreateDeviceRGB()
				let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

				return try CGImage(
					width: size.width,
					height: size.height,
					bitsPerComponent: 8,
					bitsPerPixel: 32,
					bytesPerRow: size.width * 4,
					space: colorSpace,
					bitmapInfo: bitmapInfo,
					provider: provider,
					decode: nil,
					shouldInterpolate: false,
					intent: .defaultIntent
				)
				.throwing("Can't make CGImage")
			}
		}) ?? []
	}

	private var pixelBuffers: [PixelBuffer<Interleaved8x4>] {
		pxs.withUnsafeBytes { ptr in
			(0..<size.layers).map { idx in
				PixelBuffer<Interleaved8x4>(
					data: .init(mutating: ptr.baseAddress!.advanced(by: idx * size.count * 4)),
					width: size.width,
					height: size.height,
					byteCountPerRow: size.width * 4
				)
			}
		}
	}

	private func range(_ layer: Int) -> Range<Int> {
		layer * size.count ..< (layer + 1) * size.count
	}

	mutating func withMutableLayer<A>(_ layer: Int, body: (UnsafeMutableBufferPointer<Px>) -> A) -> A {
		pxs.withUnsafeMutableBufferPointer { [rng = range(layer)] ptr in
			body(ptr.extracting(rng))
		}
	}

	mutating func withMutablePixel(_ layer: Int, body: (inout Px) -> Void) {
		withMutableLayer(layer) { ptr in
			for (idx, var px) in ptr.enumerated() {
				body(&px)
				ptr[idx] = px
			}
		}
	}

	func render(in context: GraphicsContext, size: CGSize) {
		layers.forEach { image in
			context.draw(image.ui, in: CGRect(origin: .zero, size: size))
		}
	}
}

protocol TypeProvider {
	static var type: UTType { get }
	associatedtype ExportType: TypeProvider
}

enum PXD: TypeProvider {
	static var type: UTType { .pxd }
	typealias ExportType = PNG
}

enum PNG: TypeProvider {
	static var type: UTType { .png }
	typealias ExportType = PXD
}

extension UTType {
	static var pxd: Self { UTType("p0.xpaint.pxd")! }
}
