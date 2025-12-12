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
}
