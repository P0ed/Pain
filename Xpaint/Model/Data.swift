/// Pixel location
struct PxL: Hashable {
    private var _x: Int16
    private var _y: Int16
	private var _z: Int8

    var x: Int { Int(_x) }
    var y: Int { Int(_y) }
	var z: Int { Int(_z) }

	init(x: Int, y: Int, z: Int) {
        _x = Int16(x)
        _y = Int16(y)
		_z = Int8(z & 0b11)
    }

	var neighbors: [4 of PxL] {
		[
			.init(x: x - 1, y: y, z: z),
			.init(x: x + 1, y: y, z: z),
			.init(x: x, y: y - 1, z: z),
			.init(x: x, y: y + 1, z: z),
		]
	}

	var xy: PxL {
		PxL(x: x, y: y, z: 0)
	}

	var isEven: Bool {
		(x & 1 + y & 1) & 1 == 0
	}
}

struct CanvasSize: Hashable {
	private var _width: UInt16
	private var _height: UInt16
	var hasLayers: Bool

	var width: Int { Int(_width) }
	var height: Int { Int(_height) }
	var layers: Int { hasLayers ? 4 : 1 }
	var filmWidth: Int { width }
	var filmHeight: Int { height * layers }

	init(width: Int, height: Int, hasLayers: Bool) {
		_width = UInt16(width)
		_height = UInt16(height)
		self.hasLayers = hasLayers
	}

	func alloc(color: Px = .clear) -> [Px] {
		.init(repeating: color, count: count * layers)
	}
}

struct Px: Hashable, Codable {
	var alpha: UInt8
	var red: UInt8
	var green: UInt8
	var blue: UInt8
}

extension Px {

	init(rgb: UInt32) {
		red = UInt8(rgb >> 0 & 0xFF)
		green = UInt8(rgb >> 8 & 0xFF)
		blue = UInt8(rgb >> 16 & 0xFF)
		alpha = 0xFF
	}

	init(argb: UInt32) {
		red = UInt8(argb >> 0 & 0xFF)
		green = UInt8(argb >> 8 & 0xFF)
		blue = UInt8(argb >> 16 & 0xFF)
		alpha = UInt8(argb >> 24 & 0xFF)
	}
}

extension Px {
	static var white: Self { 0xFFFFFF }
	static var black: Self { 0x000000 }
	static var clear: Self { .init(argb: 0x0) }
}

struct Palette: Hashable, Codable {
	var colors: [Px]

	subscript(_ idx: Int) -> Px {
		get { colors[idx & 0xF] }
		set { colors[idx & 0xF] = newValue }
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
