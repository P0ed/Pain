extension Color: ExpressibleByIntegerLiteral {

	init(integerLiteral value: UInt32) {
		red = UInt8(value >> 8 & 0xFF)
		green = UInt8(value >> 16 & 0xFF)
		blue = UInt8(value >> 24 & 0xFF)
		alpha = UInt8(value >> 0 & 0xFF)
	}
}

extension Color {
	static var white: Self { 0xFFFFFFFF }
	static var black: Self { 0x000000FF }
}

extension Palette {

	static var main: Self {
		.init(colors: [
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
			.black,
			.white,
		])
	}

	/// https://lospec.com/palette-list/aragon16
	static var redless: Self {
		.init(colors: [
			0xF9F8DDFF,
			0xD2E291FF,
			0xA8D455FF,
			0x9CAB6CFF,
			0x5C8D58FF,
			0x3B473CFF,
			0x8B8893FF,
			0x54555CFF,
			0xE0BF7AFF,
			0xBA9572FF,
			0x876661FF,
			0x272120FF,
			0xB7C4D0FF,
			0x8DAAD6FF,
			0x9197B6FF,
			0x6B72D4FF,
		])
	}

	/// https://lospec.com/palette-list/jonk-16
	static var jonk: Self {
		.init(colors: [
			0x242E36FF,
			0x455951FF,
			0x798766FF,
			0xB7BCA2FF,
			0xD6D6D6FF,
			0xF4F0EAFF,
			0x6988A1FF,
			0xA1B0BEFF,
			0x595B7CFF,
			0x95819DFF,
			0xC9A5A9FF,
			0xF4DEC2FF,
			0x704F4FFF,
			0xB7635BFF,
			0xE39669FF,
			0xEBC790FF,
		])
	}
}
