import SpriteKit

extension SKMutableTexture {

	func modifyColors(_ cnt: Int, _ tfm: @escaping (UnsafeMutablePointer<Px>) -> Void) {
		modifyPixelData { ptr, bytes in
			guard let ptr, cnt * 4 == bytes else { return }
			let ptrc = ptr.assumingMemoryBound(to: Px.self)
			tfm(ptrc)
		}
	}

	func load(_ buffer: [Px]) {
		modifyColors(buffer.count, { ptr in
			buffer.enumerated().forEach { i, c in ptr[i] = c }
		})
	}
}

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

	func zoomToFit(_ size: CGSize) -> CGFloat {
		min(size.width / CGFloat(width), size.height / CGFloat(height))
	}
}

extension CGPoint {
	var pxl: PxL { PxL(x: Int(x), y: Int(y)) }
}
