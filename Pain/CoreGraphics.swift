import SpriteKit

extension SKMutableTexture {

	func modifyColors(_ cnt: Int, _ tfm: @escaping (UnsafeMutablePointer<Color>) -> Void) {
		modifyPixelData { ptr, bytes in
			guard let ptr, cnt * 4 == bytes else { return }
			let ptrc = ptr.assumingMemoryBound(to: Color.self)
			tfm(ptrc)
		}
	}

	func load(_ buffer: [Color]) {
		modifyColors(buffer.count, { ptr in
			buffer.enumerated().forEach { i, c in ptr[i] = c }
		})
	}
}

extension CanvasSize {
	var cgSize: CGSize { CGSize(width: width, height: height) }
	var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }
	var pixelCount: Int { width * height }

	func index(_ x: Int, _ y: Int) -> Int? {
		if x >= 0 && x < width && y >= 0 && y < height {
			.some(x + y * width)
		} else {
			.none
		}
	}

	func zoomToFit(_ size: CGSize) -> CGFloat {
		min(size.width / CGFloat(width), size.height / CGFloat(height))
	}
}

extension CGPoint {
	var int: (Int, Int) { (Int(x), Int(y)) }
}
