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

	var isEven: Bool {
		(x & 1 + y & 1) & 1 == 0
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

extension Px {
	static var white: Self { 0xFFFFFFFF }
	static var black: Self { 0x000000FF }
	static var clear: Self { 0x00000000 }
}

struct Palette: Hashable, Codable {
	var colors: [Px]

	subscript(_ idx: Int) -> Px {
		get { colors[idx & 0xF] }
		set { colors[idx & 0xF] = newValue }
	}
}

extension EditorState {

	mutating func swapColors() {
		swap(&primaryColor, &secondaryColor)
	}

	var colors: [Px] { [primaryColor, secondaryColor] }
}

extension PxSize {

	func forEach(_ fn: (PxL) -> Void) {
		(0..<height).forEach { y in
			(0..<width).forEach { x in
				fn(PxL(x: x, y: y))
			}
		}
	}
}

extension Tool {

	var isDraggable: Bool {
		switch self {
		case .pencil, .eraser: true
		default: false
		}
	}

	var actionName: String {
		switch self {
		case .pencil: "Pencil"
		case .eraser: "Erase"
		case .bucket: "Bucket"
		case .replace: "Replace"
		case .picker: "Pick color"
		}
	}

	var systemImage: String {
		switch self {
		case .pencil: "pencil"
		case .eraser: "eraser"
		case .bucket: "paint.bucket.classic"
		case .replace: "rectangle.2.swap"
		case .picker: "eyedropper"
		}
	}

	var shortcutCharacter: Character {
		switch self {
		case .pencil: "p"
		case .eraser: "e"
		case .bucket: "b"
		case .replace: "r"
		case .picker: "i"
		}
	}
}

struct BitSet {
	private static var width: Int { 8 }

	private(set) var storage: [UInt8]
	private(set) var count: Int

	var indices: Range<Int> {
		0..<count
	}

	init(count: Int) {
		self.count = count
		storage = .init(repeating: 0, count: (count + Self.width - 1) / Self.width)
	}

	subscript(_ index: Int) -> Bool {
		get {
			index >= 0 && index < count
			? storage[index / Self.width] & 1 << (index % Self.width) != 0
			: false
		}
		set {
			if newValue {
				storage[index / Self.width] |= 1 << (index % Self.width)
			} else {
				storage[index / Self.width] &= ~(1 << (index % Self.width))
			}
		}
	}
}
