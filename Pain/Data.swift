struct UInt4x2 {
	private var rawValue: UInt8

	var primary: Int { Int(rawValue & 0xF) }
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

struct PxL {
	var x: Int
	var y: Int
}

struct PxSize {
	var width: Int
	var height: Int
}

enum Tool {
	case pencil, eraser, bucket, picker
}

struct Px {
	var red: UInt8
	var green: UInt8
	var blue: UInt8
	var alpha: UInt8
}

struct Palette {
	var colors: [16 of Px]

	subscript(_ idx: Int) -> Px {
		get { colors[idx & 0xF] }
		set { colors[idx & 0xF] = newValue }
	}
}
