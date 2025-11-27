func id<A>(_ x: A) -> A { x }
func ø<each A>(_ x: repeat each A) {}

func modify<A>(_ value: inout A, _ transform: (inout A) -> Void) {
	transform(&value)
}

func modifying<A>(_ value: A, _ transform: (inout A) -> Void) -> A {
	var value = value
	transform(&value)
	return value
}

extension Optional {

	func throwing(_ fallback: @autoclosure () -> Error) throws -> Wrapped {
		if let self {
			self
		} else {
			throw fallback()
		}
	}

	func throwing(_ fallback: @autoclosure () -> String) throws -> Wrapped {
		try throwing(Err(fallback()))
	}
}

struct Err: Error {
	var description: String

	init(_ description: String) {
		self.description = description
	}
}

extension InlineArray {

	var array: [Element] { map(id) }

	func map<Mapped>(_ transform: (Element) -> Mapped) -> [Mapped] {
		indices.map { i in transform(self[i]) }
	}

	func compactMap<Mapped>(_ transform: (Element) -> Mapped?) -> [Mapped] {
		indices.compactMap { i in transform(self[i]) }
	}

	mutating func modifyEach(_ transform: (inout Element) -> ()) {
		for i in indices { transform(&self[i]) }
	}
}

extension Array {

	func mapInPlace(_ transform: (inout Element) -> Void) -> Self {
		map { x in
			var x = x
			transform(&x)
			return x
		}
	}

	mutating func modifyEach(_ transform: (inout Element) -> Void) {
		for i in indices {
			transform(&self[i])
		}
	}

	@available(*, deprecated, message: "Unused function")
	func chunks(ofCount count: Int) -> [[Element]] {
		stride(from: 0, to: self.count - 1, by: count).map { idx in
			stride(from: idx, to: idx + count, by: 1).map { idx in
				self[idx]
			}
		}
	}

	func inline<let staticCount: Int>() throws -> InlineArray<staticCount, Element> {
		if count == staticCount {
			.init { i in self[i] }
		} else {
			throw Err("Failed to load InlineArray. `count: \(count) != \(staticCount)`")
		}
	}
}

extension InlineArray: @retroactive Codable where Element: Codable {

	public init(from decoder: any Decoder) throws {
		self = try decoder.singleValueContainer().decode([Element].self).inline()
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(array)
	}
}

@propertyWrapper
final class Heap<A> {
	private var storage: A

	init(wrappedValue: A) {
		storage = wrappedValue
	}

	var wrappedValue: A {
		get { storage }
		set { storage = newValue }
	}

	var projectedValue: Heap<A> {
		self
	}
}
