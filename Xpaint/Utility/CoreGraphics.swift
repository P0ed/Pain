import CoreGraphics

extension CGSize {

	static func * (_ size: CGSize, _ scale: CGFloat) -> CGSize {
		CGSize(width: size.width * scale, height: size.height * scale)
	}
}
