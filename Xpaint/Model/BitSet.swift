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
