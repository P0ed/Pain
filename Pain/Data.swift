struct UInt4x2: Hashable {
	private var rawValue: UInt8

	var primary: Int {
		get { Int(rawValue & 0xF) }
		set { rawValue = rawValue & 0xF0 | UInt8(newValue & 0x0F) }
	}
	var secondary: Int { Int((rawValue >> 4) & 0xF) }

	init(primary: Int, secondary: Int) {
		rawValue = UInt8(primary & 0xF) | UInt8(secondary & 0xF) << 4
	}

	subscript(_ idx: Int) -> Int {
		idx & 1 == 0 ? primary : secondary
	}

	mutating func swap() {
		rawValue = rawValue >> 4 | (rawValue & 0xF) << 4
	}
}

struct PxL: Hashable {
	var x: Int
	var y: Int
}

struct PxSize: Hashable {
	var width: Int
	var height: Int
}

enum Tool {
	case pencil, eraser, bucket, picker
}

struct Px: Hashable, Codable {
	var red: UInt8
	var green: UInt8
	var blue: UInt8
	var alpha: UInt8
}

extension Px {

	init(rgba: UInt32) {
		red = UInt8(rgba >> 8 & 0xFF)
		green = UInt8(rgba >> 16 & 0xFF)
		blue = UInt8(rgba >> 24 & 0xFF)
		alpha = UInt8(rgba >> 0 & 0xFF)
	}

	var rgba: UInt32 {
		UInt32(red) << 0
		| UInt32(green) << 8
		| UInt32(blue) << 16
		| UInt32(alpha) << 24
	}
}

struct Palette: Codable {
	var colors: [16 of Px]

	subscript(_ idx: Int) -> Px {
		get { colors[idx & 0xF] }
		set { colors[idx & 0xF] = newValue }
	}
}
