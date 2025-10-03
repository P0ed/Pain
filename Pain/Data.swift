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

struct PxL {
	var x: Int
	var y: Int
}

struct CanvasSize {
	var width: Int
	var height: Int
}

enum Tool {
	case pencil, eraser, bucket, picker
}
