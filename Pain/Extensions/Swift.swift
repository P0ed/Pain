func id<A>(_ x: A) -> A { x }
func ø<each A>(_ x: repeat each A) {}

extension Optional {

	func unwrap(_ fallback: @autoclosure () -> Error) throws -> Wrapped {
		if let self {
			self
		} else {
			throw fallback()
		}
	}

	func unwrap(_ fallback: @autoclosure () -> String) throws -> Wrapped {
		try unwrap(Err(fallback()))
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
		var result = [] as [Mapped]
		result.reserveCapacity(count)
		for i in indices { result.append(transform(self[i])) }

		return result
	}

	mutating func mapInPlace(_ transform: (inout Element) -> ()) {
		for i in indices { transform(&self[i]) }
	}
}
