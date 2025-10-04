import SwiftUI
import SpriteKit
import UniformTypeIdentifiers

struct Document: FileDocument {
	var size: PxSize
	var contents: [Px]

	static var readableContentTypes: [UTType] { [.png] }
	static var writableContentTypes: [UTType] { [.png] }

	init() {
		size = PxSize(width: 32, height: 32)
		contents = [Px](repeating: .white, count: size.count)
	}

	init(configuration: ReadConfiguration) throws {
		let data = try configuration.file.regularFileContents
			.unwrap("Failed to read file")

		let image = try (NSBitmapImageRep(data: data)?.cgImage)
			.unwrap("Failed to open image")

		size = PxSize(width: image.width, height: image.height)
		contents = [Px](repeating: .clear, count: size.count)

		contents.withUnsafeMutableBytes { [size] ptr in
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
		let image: CGImage = try contents.withUnsafeBytes { raw in
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
		let rep = NSBitmapImageRep(cgImage: image)
		let data = try rep.representation(using: .png, properties: [:])
			.unwrap("Failed to create PNG representation")

		return .init(regularFileWithContents: data)
	}
}
