import SwiftUI

extension Document {

	mutating func shiftLeft() {
		pxs.modifyEach { px in
			px.red <<= 1
			px.green <<= 1
			px.blue <<= 1
		}
	}

	mutating func shiftRight() {
		pxs.modifyEach { px in
			px.red >>= 1
			px.green >>= 1
			px.blue >>= 1
		}
	}

	mutating func makeMonochrome() {
		pxs.modifyEach { px in
			let avg = UInt8(
				clamping: (UInt16(px.red) + UInt16(px.green) + UInt16(px.blue)) / 3
			)
			px.red = avg
			px.green = avg
			px.blue = avg
		}
	}
}
