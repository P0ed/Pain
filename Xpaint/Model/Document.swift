import SwiftUI
import UniformTypeIdentifiers
import Accelerate

struct Document<ContentType: TypeProvider>: FileDocument {
	var size: CanvasSize
	var pxs: [Px]

	static var readableContentTypes: [UTType] { [ContentType.type] }
	static var hasLayers: Bool { ContentType.type == .pxd }

	init(width: Int = 32, height: Int = 32) {
		size = CanvasSize(width: width, height: height, hasLayers: Self.hasLayers)
		pxs = size.alloc()
		withMutablePixel(0) { px in px = .white }
	}

	init<T: TypeProvider>(converting file: Document<T>) where T.ExportType == ContentType {
		size = file.size
		size.hasLayers = Self.hasLayers
		pxs = size.alloc()

		file.withPixelBuffers { src in
			withMutablePixelBuffers { dst in
				src.forEach(dst[0].merge)
			}
		}
	}

	init(configuration: ReadConfiguration) throws {
		let data = try configuration.file.regularFileContents
			.throwing("Failed to read file")

		let film = try (NSBitmapImageRep(data: data)?.cgImage)
			.throwing("Failed to open image")

		if Self.hasLayers, film.height & 0b11 != 0 {
			throw Err("Corrupted file")
		}
		size = CanvasSize(
			width: film.width,
			height: film.height / (Self.hasLayers ? 4 : 1),
			hasLayers: Self.hasLayers
		)
		if size.count > CanvasSize.max.count {
			throw Err("File too large")
		}
		pxs = size.alloc()
		drawFilm(film)
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		let film = try image()
			.throwing("Failed to create CGImage")

		let data = try NSBitmapImageRep(cgImage: film)
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

	mutating func resize(width: Int, height: Int) {
		guard let film = image() else { return }

		var new = Document(width: width, height: height)
		new.drawFilm(film)

		self = new
	}

	mutating func withFilmContext(
		interpolationQuality: CGInterpolationQuality = .none,
		_ body: (CGContext) -> Void
	) {
		pxs.withUnsafeMutableBytes { ptr in
			if let ctx = CGContext(
				data: ptr.baseAddress,
				width: size.width,
				height: size.height * size.layers,
				bitsPerComponent: 8,
				bytesPerRow: size.width * 4,
				space: CGColorSpaceCreateDeviceRGB(),
				bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
			) {
				ctx.interpolationQuality = interpolationQuality
				body(ctx)
			}
		}
	}

	private mutating func drawFilm(_ image: CGImage) {
		withFilmContext { [size] ctx in
			ctx.draw(image, in: CGRect(
				origin: .zero,
				size: CGSize(width: size.width, height: size.height * size.layers)
			))
		}
	}

	private func image(_ layer: Int? = .none) -> CGImage? {
		try? pxs[range(layer)].withUnsafeBytes { raw in
			let data = try CFDataCreate(nil, raw.baseAddress, raw.count)
				.throwing("Can't make CFData")
			let provider = try CGDataProvider(data: data)
				.throwing("Can't make CGDataProvider")
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)

			return try CGImage(
				width: size.width,
				height: size.height * (layer == nil && Self.hasLayers ? 4 : 1),
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

	private var layers: [CGImage]? {
		try? (0..<size.layers).map { layer in
			try image(layer).throwing("Can't make CGImage")
		}
	}

	func range(_ layer: Int?) -> Range<Int> {
		layer.map { layer in
			layer * size.count ..< (layer + 1) * size.count
		}
		?? 0 ..< size.count * size.layers
	}

	func withPixelBuffers<A>(_ body: ([PixelBuffer<Interleaved8x4>]) -> A) -> A {
		pxs.withUnsafeBytes { ptr in
			body((0..<size.layers).map { idx in
				PixelBuffer<Interleaved8x4>(
					data: .init(mutating: ptr.baseAddress!.advanced(by: idx * size.count * 4)),
					width: size.width,
					height: size.height,
					byteCountPerRow: size.width * 4
				)
			})
		}
	}

	mutating func withMutablePixelBuffers<A>(_ body: ([PixelBuffer<Interleaved8x4>]) -> A) -> A {
		pxs.withUnsafeMutableBytes { ptr in
			body((0..<size.layers).map { idx in
				PixelBuffer<Interleaved8x4>(
					data: ptr.baseAddress!.advanced(by: idx * size.count * 4),
					width: size.width,
					height: size.height,
					byteCountPerRow: size.width * 4
				)
			})
		}
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

	func render(mask: Int, in context: GraphicsContext, size: CGSize) {
		layers?.enumerated().forEach { index, image in
			if mask & 1 << index != 0 {
				context.draw(image.ui, in: CGRect(origin: .zero, size: size))
			}
		}
	}
}
