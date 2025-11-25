import SwiftUI
import UniformTypeIdentifiers

struct Document<ContentType: TypeProvider>: FileDocument {
	private(set) var size: CanvasSize
	var pxs: [Px]

	static var readableContentTypes: [UTType] { [ContentType.type] }

	init() {
		size = CanvasSize(width: 32, height: 32, hasLayers: ContentType.type == .pxd)
        pxs = size.alloc(color: .clear)
	}

	init<T: TypeProvider>(converting file: Document<T>) where T.ExportType == ContentType {
		size = CanvasSize(
			width: file.size.width,
			height: file.size.height,
			hasLayers: ContentType.type == .pxd
		)
		if ContentType.type == .pxd {
			pxs = file.pxs + .init(repeating: .clear, count: file.size.count * 3)
		} else {
			// TODO: Blend all layers into one
			pxs = Array(file.pxs.prefix(file.size.count))
		}
	}

	init(configuration: ReadConfiguration) throws {
		let data = try configuration.file.regularFileContents
			.throwing("Failed to read file")

		let image = try (NSBitmapImageRep(data: data)?.cgImage)
			.throwing("Failed to open image")

		if ContentType.type == .png {
			size = CanvasSize(
				width: image.width,
				height: image.height,
				hasLayers: false
			)
		} else {
			guard image.height & 0b11 == 0 else { throw Err("Corrupted file") }

			size = CanvasSize(
				width: image.width,
				height: image.height >> 2,
				hasLayers: true
			)
		}
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
			size.index(at: pxl).map { idx in pxs[idx] } ?? .clear
		}
		set {
			size.index(at: pxl).map { idx in pxs[idx] = newValue }
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
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
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
			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

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

	subscript(layer: Int) -> ArraySlice<Px> {
		pxs[(size.count * layer)..<(size.count * (layer + 1))]
	}

	private var layers: [CGImage] {
		(try? (0..<size.layers).map { layerIndex in
			try self[layerIndex].withUnsafeBytes { raw in
				let bytes = raw.bindMemory(to: UInt8.self)
				let data = try CFDataCreate(nil, bytes.baseAddress, bytes.count)
					.throwing("Can't make CFData")
				let provider = try CGDataProvider(data: data)
					.throwing("Can't make CGDataProvider")
				let colorSpace = CGColorSpaceCreateDeviceRGB()
				let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

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
