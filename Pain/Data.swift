struct UInt4x2 {
	private var rawValue: UInt8

	var primary: Int { Int(rawValue & 0xF) }
	var secondary: Int { Int((rawValue >> 4) & 0xF) }

	init(primary: Int, secondary: Int) {
		rawValue = UInt8(primary & 0xF) | UInt8(secondary & 0xF) << 4
	}

	subscript(_ idx: Int) -> Int {
		idx == 0 ? primary : secondary
	}

	mutating func swap() {
		rawValue = rawValue >> 4 | (rawValue & 0xF) << 4
	}
}

struct CanvasSize {
	var width: Int
	var height: Int
}

enum Tool {
	case pencil, eraser, bucket, picker
}

struct Color {
	var red: UInt8
	var green: UInt8
	var blue: UInt8
	var alpha: UInt8
}

extension Color: ExpressibleByIntegerLiteral {

	init(integerLiteral value: UInt32) {
		red = UInt8(value >> 8 & 0xFF)
		green = UInt8(value >> 16 & 0xFF)
		blue = UInt8(value >> 24 & 0xFF)
		alpha = UInt8(value >> 0 & 0xFF)
	}
}

extension Color {
	static var white: Self { 0xFFFFFFFF }
	static var black: Self { 0x000000FF }
}

struct Palette {
	var colors: [16 of Color]
}

extension Palette {
	static var main: Self {
		.init(colors: [
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
		])
	}
}
