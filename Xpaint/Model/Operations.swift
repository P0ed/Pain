import SwiftUI

extension EditorView {

	func shiftLeft() {
		file.layers[state.layer].modifyEach { px in
			px.red <<= 1
			px.green <<= 1
			px.blue <<= 1
		}
	}

	func shiftRight() {
		file.layers[state.layer].modifyEach { px in
			px.red >>= 1
			px.green >>= 1
			px.blue >>= 1
		}
	}

	func makeMonochrome() {
		file.layers[state.layer].modifyEach { px in
			let avg = UInt8(
				clamping: (UInt16(px.red) + UInt16(px.green) + UInt16(px.blue)) / 3
			)
			px.red = avg
			px.green = avg
			px.blue = avg
		}
	}

	func exportFile() {
		export.document = Document(converting: file)
		export.exporting = true
	}
}
