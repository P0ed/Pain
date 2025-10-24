import CoreGraphics

extension PxSize {
	var cgSize: CGSize { CGSize(width: width, height: height) }
	var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }
	var count: Int { width * height }

	func index(at pxl: PxL) -> Int? {
		if pxl.x >= 0 && pxl.x < width && pxl.y >= 0 && pxl.y < height {
			.some(pxl.x + (height - 1 - pxl.y) * width)
		} else {
			.none
		}
	}

	func pxl(at index: Int) -> PxL {
		PxL(x: index % width, y: index / width)
	}

    func alloc(color: Px) -> [Px] {
        .init(repeating: color, count: count)
    }

	func zoomToFit(_ size: CGSize) -> CGFloat {
		min(size.width / CGFloat(width), size.height / CGFloat(height))
	}
}

extension CGSize {

	func zoomed(_ scale: CGFloat) -> CGSize {
		.init(width: width * scale, height: height * scale)
	}
}

extension CGPoint {

	var pxl: PxL { PxL(x: Int(x), y: Int(y)) }
}
