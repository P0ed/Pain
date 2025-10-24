import SwiftUI
import UniformTypeIdentifiers

struct Document: FileDocument {
	var size: PxSize
	var pxs: [Px]

	static var readableContentTypes: [UTType] { [.png] }

	subscript(_ pxl: PxL) -> Px {
		get { size.index(at: pxl).map { idx in pxs[idx] } ?? .clear }
		set { size.index(at: pxl).map { idx in pxs[idx] = newValue } }
	}

	init() {
		size = PxSize(width: 32, height: 32)
        pxs = size.alloc(color: .white)
	}

	init(configuration: ReadConfiguration) throws {
		let data = try configuration.file.regularFileContents
			.unwrap("Failed to read file")

		let image = try (NSBitmapImageRep(data: data)?.cgImage)
			.unwrap("Failed to open image")

		size = PxSize(width: image.width, height: image.height)
        pxs = size.alloc(color: .clear)

		pxs.withUnsafeMutableBytes { [size] ptr in
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			if let ctx = CGContext(
				data: ptr.baseAddress,
				width: size.width,
				height: size.height,
				bitsPerComponent: 8,
				bytesPerRow: size.width * 4,
				space: colorSpace,
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
			) {
				ctx.interpolationQuality = .none
				ctx.draw(image, in: CGRect(origin: .zero, size: size.cgSize))
			}
		}
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		try FileWrapper(
			regularFileWithContents: NSBitmapImageRep(cgImage: cgImage())
				.representation(using: .png, properties: [:])
				.unwrap("Failed to create PNG representation")
		)
	}

	func cgImage() throws -> CGImage {
		try pxs.withUnsafeBytes { raw in
			let bytes = raw.bindMemory(to: UInt8.self)
			let data = try CFDataCreate(nil, bytes.baseAddress, bytes.count)
				.unwrap("Can't make CFData")
			let provider = try CGDataProvider(data: data)
				.unwrap("Can't make CGDataProvider")
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
			.unwrap("Can't make CGImage")
		}
	}
}
