extension Px: ExpressibleByIntegerLiteral {

	init(integerLiteral value: UInt32) {
		self = Px(rgba: value)
	}
}

extension Px {
	static var white: Self { 0xFFFFFFFF }
	static var black: Self { 0x000000FF }
	static var gray: Self { 0x7F7F7FFF }
	static var clear: Self { 0x00000000 }
}

extension [Palette] {

	static var list: Self {
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
			0x000000FF,
			0x181818FF,
			0x282828FF,
			0x383838FF,
			0x474747FF,
			0x565656FF,
			0x646464FF,
			0x717171FF,
			0x7E7E7EFF,
			0x8C8C8CFF,
			0x9B9B9BFF,
			0xABABABFF,
			0xBDBDBDFF,
			0xD1D1D1FF,
			0xE7E7E7FF,
			0xFFFFFFFF,
		])
	}

	/// https://lospec.com/palette-list/aragon16
	static var vegetation: Self {
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
	static var subdued: Self {
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

	/// https://lospec.com/palette-list/galaxy-flame
	static var warm: Self {
		.init(colors: [
			0x699FADFF,
			0x3A708EFF,
			0x2B454FFF,
			0x111215FF,
			0x151D1AFF,
			0x1D3230FF,
			0x314E3FFF,
			0x4F5D42FF,
			0x9A9F87FF,
			0xEDE6CBFF,
			0xF5D893FF,
			0xE8B26FFF,
			0xB6834CFF,
			0x704D2BFF,
			0x40231EFF,
			0x151015FF,
		])
	}

	/// https://lospec.com/palette-list/pico-8
	static var pico8: Self {
		.init(colors: [
			0x000000FF,
			0x1D2B53FF,
			0x7E2553FF,
			0x008751FF,
			0xAB5236FF,
			0x5F574FFF,
			0xC2C3C7FF,
			0xFFF1E8FF,
			0xFF004DFF,
			0xFFA300FF,
			0xFFEC27FF,
			0x00E436FF,
			0x29ADFFFF,
			0x83769CFF,
			0xFF77A8FF,
			0xFFCCAAFF,
		])
	}

	/// https://lospec.com/palette-list/sweetie-16
	static var sweetie: Self {
		.init(colors: [
			0x1A1C2CFF,
			0x5D275DFF,
			0xB13E53FF,
			0xEF7D57FF,
			0xFFCD75FF,
			0xA7F070FF,
			0x38B764FF,
			0x257179FF,
			0x29366FFF,
			0x3B5DC9FF,
			0x41A6F6FF,
			0x73EFF7FF,
			0xF4F4F4FF,
			0x94B0C2FF,
			0x566C86FF,
			0x333C57FF,
		])
	}

	/// https://lospec.com/palette-list/microsoft-windows
	static var windows: Self {
		.init(colors: [
			0x000000FF,
			0x7E7E7EFF,
			0xBEBEBEFF,
			0xFFFFFFFF,
			0x7E0000FF,
			0xFE0000FF,
			0x047E00FF,
			0x06FF04FF,
			0x7E7E00FF,
			0xFFFF04FF,
			0x00007EFF,
			0x0000FFFF,
			0x7E007EFF,
			0xFE00FFFF,
			0x047E7EFF,
			0x06FFFFFF,
		])
	}

	/// https://lospec.com/palette-list/16-minimalist-color-theory
	static var flat: Self {
		.init(colors: [
			0xB1B865FF,
			0xFCCE2DFF,
			0xFDD9A2FF,
			0xFEFFD4FF,
			0xC37642FF,
			0xE09B63FF,
			0xFFA6B5FF,
			0xB1DDE0FF,
			0x73483DFF,
			0xCD6085FF,
			0x7090C0FF,
			0x61B8DDFF,
			0x000000FF,
			0x503C62FF,
			0x46727CFF,
			0x82A933FF,
		])
	}
}
