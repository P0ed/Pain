struct PxL: Hashable {
    private var _x: Int16
    private var _y: Int16
    
    var x: Int { Int(_x) }
    var y: Int { Int(_y) }
    
    init(x: Int, y: Int) {
        _x = Int16(x)
        _y = Int16(y)
    }

	var neighbors: [PxL] {
		[
			.init(x: x - 1, y: y),
			.init(x: x + 1, y: y),
			.init(x: x, y: y - 1),
			.init(x: x, y: y + 1),
		]
	}
}

struct PxSize: Hashable {
	var width: Int
	var height: Int
}

enum Tool {
	case pencil, eraser, bucket, replace, picker
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

struct Palette: Hashable, Codable {
	var colors: [Px]

	subscript(_ idx: Int) -> Px {
		get { colors[idx & 0xF] }
		set { colors[idx & 0xF] = newValue }
	}
}

struct EditorState: Hashable {
	var primaryColor: Px = .black
	var secondaryColor: Px = .white
	var tool: Tool = .pencil
}

extension EditorState {

	mutating func swapColors() {
		swap(&primaryColor, &secondaryColor)
	}
}

extension PxSize {

	func forEach(_ fn: (Int, Int) -> Void) {
		(0..<height).forEach { y in
			(0..<width).forEach { x in
				fn(x, y)
			}
		}
	}
}
