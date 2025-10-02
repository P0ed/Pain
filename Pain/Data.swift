struct UInt4x2 {
	private var rawValue: UInt8

	var primary: Int { Int(rawValue & 0xF) }
	var secondary: Int { Int((rawValue >> 4) & 0xF) }

	init(primary: Int, secondary: Int) {
		rawValue = UInt8(primary & 0xF) | UInt8(secondary & 0xF) << 4
	}
}

enum Tool {
	case pencil, eraser, bucket
}

struct Color {
	var rgba: [4 of UInt8]

	var red: UInt8 { get { rgba[0] } set { rgba[0] = newValue } }
	var green: UInt8 { get { rgba[1] } set { rgba[1] = newValue } }
	var blue: UInt8 { get { rgba[2] } set { rgba[2] = newValue } }
	var alpha: UInt8 { get { rgba[3] } set { rgba[3] = newValue } }
}

extension Color: ExpressibleByIntegerLiteral {

	init(integerLiteral value: UInt32) {
		rgba = [
			UInt8(value >> 0 & 0xFF),
			UInt8(value >> 8 & 0xFF),
			UInt8(value >> 16 & 0xFF),
			UInt8(value >> 24 & 0xFF)
		]
	}
}

extension Color {
	static var white: Self { .init(integerLiteral: ~0x0) }
}

struct Palette {
	var colors: [16 of Color]
}

extension Palette {
	static var main: Self {
		.init(colors: .init(repeating: .init(rgba: [0, 0, 0, .max])))
	}
}
