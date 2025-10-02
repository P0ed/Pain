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

	var red: UInt8 { rgba[0] }
	var green: UInt8 { rgba[1] }
	var blue: UInt8 { rgba[2] }
	var alpha: UInt8 { rgba[3] }
}

struct Palette {
	var colors: [16 of Color]
}

extension Palette {
	static var main: Self {
		.init(colors: .init(repeating: .init(rgba: [0, 0, 0, .max])))
	}
}
