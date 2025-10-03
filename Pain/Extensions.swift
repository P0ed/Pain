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
