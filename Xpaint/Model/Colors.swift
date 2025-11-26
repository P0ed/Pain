extension Px: ExpressibleByIntegerLiteral {

	init(integerLiteral value: UInt32) {
		self = Px(rgb: value)
	}
}

extension [Palette] {

	static var builtin: Self {
		[
			.monochrome,
			.vegetation,
			.subdued,
			.warm,
			.pico8,
			.sweetie,
			.windows,
			.flat,
		]
	}
}

extension Palette {

	/// https://lospec.com/palette-list/grayscale-16
	static var monochrome: Self {
		.init(colors: [
			0x000000,
			0x181818,
			0x282828,
			0x383838,
			0x474747,
			0x565656,
			0x646464,
			0x717171,
			0x7E7E7E,
			0x8C8C8C,
			0x9B9B9B,
			0xABABAB,
			0xBDBDBD,
			0xD1D1D1,
			0xE7E7E7,
			0xFFFFFF,
		])
	}

	/// https://lospec.com/palette-list/aragon16
	static var vegetation: Self {
		.init(colors: [
			0xF9F8DD,
			0xD2E291,
			0xA8D455,
			0x9CAB6C,
			0x5C8D58,
			0x3B473C,
			0x8B8893,
			0x54555C,
			0xE0BF7A,
			0xBA9572,
			0x876661,
			0x272120,
			0xB7C4D0,
			0x8DAAD6,
			0x9197B6,
			0x6B72D4,
		])
	}

	/// https://lospec.com/palette-list/jonk-16
	static var subdued: Self {
		.init(colors: [
			0x242E36,
			0x455951,
			0x798766,
			0xB7BCA2,
			0xD6D6D6,
			0xF4F0EA,
			0x6988A1,
			0xA1B0BE,
			0x595B7C,
			0x95819D,
			0xC9A5A9,
			0xF4DEC2,
			0x704F4F,
			0xB7635B,
			0xE39669,
			0xEBC790,
		])
	}

	/// https://lospec.com/palette-list/galaxy-flame
	static var warm: Self {
		.init(colors: [
			0x699FAD,
			0x3A708E,
			0x2B454F,
			0x111215,
			0x151D1A,
			0x1D3230,
			0x314E3F,
			0x4F5D42,
			0x9A9F87,
			0xEDE6CB,
			0xF5D893,
			0xE8B26F,
			0xB6834C,
			0x704D2B,
			0x40231E,
			0x151015,
		])
	}

	/// https://lospec.com/palette-list/pico-8
	static var pico8: Self {
		.init(colors: [
			0x000000,
			0x1D2B53,
			0x7E2553,
			0x008751,
			0xAB5236,
			0x5F574F,
			0xC2C3C7,
			0xFFF1E8,
			0xFF004D,
			0xFFA300,
			0xFFEC27,
			0x00E436,
			0x29ADFF,
			0x83769C,
			0xFF77A8,
			0xFFCCAA,
		])
	}

	/// https://lospec.com/palette-list/sweetie-16
	static var sweetie: Self {
		.init(colors: [
			0x1A1C2C,
			0x5D275D,
			0xB13E53,
			0xEF7D57,
			0xFFCD75,
			0xA7F070,
			0x38B764,
			0x257179,
			0x29366F,
			0x3B5DC9,
			0x41A6F6,
			0x73EFF7,
			0xF4F4F4,
			0x94B0C2,
			0x566C86,
			0x333C57,
		])
	}

	/// https://lospec.com/palette-list/microsoft-windows
	static var windows: Self {
		.init(colors: [
			0x000000,
			0x7E7E7E,
			0xBEBEBE,
			0xFFFFFF,
			0x7E0000,
			0xFE0000,
			0x047E00,
			0x06FF04,
			0x7E7E00,
			0xFFFF04,
			0x00007E,
			0x0000FF,
			0x7E007E,
			0xFE00FF,
			0x047E7E,
			0x06FFFF,
		])
	}

	/// https://lospec.com/palette-list/16-minimalist-color-theory
	static var flat: Self {
		.init(colors: [
			0xB1B865,
			0xFCCE2D,
			0xFDD9A2,
			0xFEFFD4,
			0xC37642,
			0xE09B63,
			0xFFA6B5,
			0xB1DDE0,
			0x73483D,
			0xCD6085,
			0x7090C0,
			0x61B8DD,
			0x000000,
			0x503C62,
			0x46727C,
			0x82A933,
		])
	}
}
