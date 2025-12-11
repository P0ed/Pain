import CoreGraphics

extension CGSize {

	static func * (_ size: CGSize, _ scale: CGFloat) -> CGSize {
		CGSize(width: size.width * scale, height: size.height * scale)
	}
}

extension FilmSize {
	var cg: CGSize { CGSize(width: width, height: height) }
	var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }
	var count: Int { width * height }

	func index(at pxl: PxL) -> Int? {
		if pxl.x >= 0 && pxl.x < width && pxl.y >= 0 && pxl.y < height {
			.some(pxl.x + (height - 1 - pxl.y) * width + count * pxl.z)
		} else {
			.none
		}
	}

	func pxl(at index: Int) -> PxL {
		PxL(
			x: index % count % width,
			y: height - 1 - index % count / width,
			z: index / count
		)
	}

	func zoomToFit(_ size: CGSize) -> CGFloat {
		min(size.width / CGFloat(width), size.height / CGFloat(height))
	}
}
