import CoreGraphics
import SwiftUI

struct Film: Equatable {
	var size: FilmSize
	var pxs: [Px]
}

extension Film {

	init(size: FilmSize, color: Px? = .none) {
		self.size = size
		pxs = size.alloc()
		if let color {
			withMutablePixel(0) { px in px = color }
		}
	}

	init(width: Int = 32, height: Int = 32, frames: Int = 1, color: Px? = .white) {
		self = .init(
			size: FilmSize(width: width, height: height, frames: frames),
			color: color
		)
	}

	var indices: Range<Int> { (0..<size.frames) }

	subscript(_ pxl: PxL) -> Px {
		get {
			size.index(at: pxl).map { idx in pxs[idx] } ?? .clear
		}
		set {
			size.index(at: pxl).map { idx in pxs[idx] = newValue }
		}
	}

	func range(_ layer: Int?) -> Range<Int> {
		layer.map { layer in
			layer * size.count ..< (layer + 1) * size.count
		}
		?? 0 ..< size.count * size.frames
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

	mutating func resize(width: Int, height: Int) {
		guard let film = image() else { return }

		var new = Film(width: width, height: height, color: .none)
		new.drawFilm(film)

		self = new
	}
}


extension Film {

	mutating func merge(_ f: Film) {
		withMutableLayer(0) { [fs = f.size, fc = f.size.count] ptr in
			for frame in f.indices {
				for (idx, px) in ptr.enumerated() {
					ptr[idx] = px + f[fs.pxl(at: idx + frame * fc)]
				}
			}
		}
	}
}

extension Film {

	mutating func withFilmContext(
		interpolationQuality: CGInterpolationQuality = .none,
		_ body: (CGContext) -> Void
	) {
		pxs.withUnsafeMutableBytes { [size] ptr in
			if let ctx = CGContext(
				data: ptr.baseAddress,
				width: size.width,
				height: size.height * size.frames,
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

	mutating func drawFilm(_ image: CGImage) {
		withFilmContext { [size] ctx in
			ctx.draw(image, in: CGRect(
				origin: .zero,
				size: CGSize(width: size.width, height: size.height * size.frames)
			))
		}
	}

	func image(_ layer: Int? = .none) -> CGImage? {
		try? pxs[range(layer)].withUnsafeBytes { raw in
			let data = try CFDataCreate(nil, raw.baseAddress, raw.count)
				.throwing("Can't make CFData")
			let provider = try CGDataProvider(data: data)
				.throwing("Can't make CGDataProvider")
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)

			return try CGImage(
				width: size.width,
				height: size.height * (layer == nil ? size.frames : 1),
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
		try? indices.map { layer in
			try image(layer).throwing("Can't make CGImage")
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
