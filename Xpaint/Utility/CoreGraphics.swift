import CoreGraphics

extension CGSize {

	static func * (_ size: CGSize, _ scale: CGFloat) -> CGSize {
		CGSize(width: size.width * scale, height: size.height * scale)
	}
}

extension FilmSize {

	var cg: CGSize { CGSize(width: width, height: height) }

	var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }

	func zoomToFit(_ size: CGSize) -> CGFloat {
		min(size.width / CGFloat(width), size.height / CGFloat(height))
	}
}
