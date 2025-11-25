import SwiftUI
import UniformTypeIdentifiers
import Accelerate

struct Document<ContentType: TypeProvider>: FileDocument {
	var size: Size
	var layers: [4 of PixelBuffer<Interleaved8x4>]
	@Heap
	var registers: [2 of PixelBuffer<Interleaved8x4>]

	static var readableContentTypes: [UTType] { [ContentType.type] }
	static var hasLayers: Bool { ContentType.type == .pxd }

	init() {
		size = Size(width: 32, height: 32)
		layers = .init(repeating: .init(size: size))
		registers = .init(repeating: .init(size: size))
	}

	init<T: TypeProvider>(converting file: Document<T>) where T.ExportType == ContentType {
		size = file.size
		if ContentType.type == .pxd {
			layers = file.layers
		} else {
			layers = file.layers
			layers[0].merge(layers[1])
			layers[0].merge(layers[2])
			layers[0].merge(layers[3])
		}
		registers = .init(repeating: .init(size: size))
	}

	init(configuration: ReadConfiguration) throws {
		let data = try configuration.file.regularFileContents
			.throwing("Failed to read file")

		let image = try (NSBitmapImageRep(data: data)?.cgImage)
			.throwing("Failed to open image")

		if ContentType.type == .png {
			size = Size(
				width: image.width,
				height: image.height
			)
		} else {
			guard image.height & 0b11 == 0 else { throw Err("Corrupted file") }

			size = Size(
				width: image.width,
				height: image.height >> 2
			)
		}
		registers = .init(repeating: .init(size: size))
		layers = .init(repeating: .init(size: size))
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
				layers[pxl.z].withPixels { pxs in
					pxs[idx]
				}
			} ?? .clear
		}
		set {
			size.index(at: pxl).map { idx in
				layers[pxl.z].withMutablePixels { pxs in
					pxs[idx] = newValue
				}
			}
		}
	}

	private mutating func draw(_ image: CGImage) {
//		pxs.withUnsafeMutableBytes { ptr in
//			let colorSpace = CGColorSpaceCreateDeviceRGB()
//			if let ctx = CGContext(
//				data: ptr.baseAddress,
//				width: image.width,
//				height: image.height,
//				bitsPerComponent: 8,
//				bytesPerRow: image.width * 4,
//				space: colorSpace,
//				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//			) {
//				ctx.interpolationQuality = .none
//				ctx.draw(image, in: CGRect(
//					origin: .zero,
//					size: CGSize(width: image.width, height: image.height)
//				))
//			}
//		}
	}

	private var exportImage: CGImage? {
//		try? pxs.withUnsafeBytes { raw in
//			let bytes = raw.bindMemory(to: UInt8.self)
//			let data = try CFDataCreate(nil, bytes.baseAddress, bytes.count)
//				.throwing("Can't make CFData")
//			let provider = try CGDataProvider(data: data)
//				.throwing("Can't make CGDataProvider")
//			let colorSpace = CGColorSpaceCreateDeviceRGB()
//			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//
//			return try CGImage(
//				width: size.width,
//				height: size.height * size.layers,
//				bitsPerComponent: 8,
//				bitsPerPixel: 32,
//				bytesPerRow: size.width * 4,
//				space: colorSpace,
//				bitmapInfo: bitmapInfo,
//				provider: provider,
//				decode: nil,
//				shouldInterpolate: false,
//				intent: .defaultIntent
//			)
//			.throwing("Can't make CGImage")
//		}
		nil
	}

	private var layerImages: [CGImage] {
		Self.hasLayers ? layers.map(\.cgImage) : [layers[0].cgImage]
	}

	func render(in context: GraphicsContext, size: CGSize) {
		layerImages.forEach { image in
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
