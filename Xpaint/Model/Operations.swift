import SwiftUI

extension EditorView {

	func shiftLeft() {
		file.withMutablePixel(state.layer) { px in
			px.red <<= 1
			px.green <<= 1
			px.blue <<= 1
		}
	}

	func shiftRight() {
		file.withMutablePixel(state.layer) { px in
			px.red >>= 1
			px.green >>= 1
			px.blue >>= 1
		}
	}

	func makeMonochrome() {
		file.withMutablePixel(state.layer) { px in
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

	func wipeLayer() {
		file.withMutablePixel(state.layer) { px in px = .clear }
	}

	func move(dx: Int = 0, dy: Int = 0) {
		file.withMutableLayer(state.layer) { [size = file.size] pxs in
			let xs = dx > 0
			? stride(from: size.width - 1, through: 0, by: -1)
			: stride(from: 0, through: size.width - 1, by: 1)

			let ys = dy > 0
			? stride(from: size.height - 1, through: 0, by: -1)
			: stride(from: 0, through: size.height - 1, by: 1)

			for row in ys {
				for col in xs {
					let x = col + dx
					let y = row + dy

					let src = row * size.width + col
					let dst = y * size.width + x

					if (0..<size.width).contains(x) && (0..<size.height).contains(y) {
						pxs[dst] = pxs[src]
					}
					if x != col || y != row {
						pxs[src] = .clear
					}
				}
			}
		}
	}
}
