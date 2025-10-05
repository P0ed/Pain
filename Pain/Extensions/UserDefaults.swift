import Foundation
import SwiftUI

extension UserDefaults {

	subscript<A: Codable>(_ key: String) -> A? {
		get { try? data(forKey: key).map(dtoa) }
		set { try? set(newValue.map(atod), forKey: key) }
	}
}

private func atod<A: Encodable>(_ value: A) throws -> Data {
	try JSONEncoder().encode(value)
}

private func dtoa<A: Decodable>(_ data: Data) throws -> A {
	try JSONDecoder().decode(A.self, from: data)
}

@propertyWrapper
struct UserDefault<Value: Codable>: DynamicProperty {
	private var key: String
	private var store: UserDefaults
	private var defaultValue: () -> Value

	init(
		wrappedValue: Value? = .none,
		key: String,
		store: UserDefaults = .standard,
		defaultValue: @escaping @autoclosure () -> Value
	) {
		self.key = key
		self.store = store
		self.defaultValue = defaultValue
		wrappedValue.map { self.wrappedValue = $0 }
	}

	public var wrappedValue: Value {
		get { store[key] ?? defaultValue() }
		nonmutating set { store[key] = newValue }
	}

	public var projectedValue: Binding<Value> {
		Binding(
			get: { wrappedValue },
			set: { value in wrappedValue = value }
		)
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

extension Array {

	func inline<let staticCount: Int>() throws -> InlineArray<staticCount, Element> {
		if count == staticCount {
			.init { i in self[i] }
		} else {
			throw Err("Failed to load InlineArray. `count: \(count) != \(staticCount)`")
		}
	}
}
