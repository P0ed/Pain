import SwiftUI

extension EditorView {

	func pxl(at location: CGPoint) -> PxL {
		PxL(
			x: Int(location.x / state.magnification),
			y: Int(file.size.cg.height - location.y / state.magnification),
			z: state.layer
		)
	}

	var drawingController: some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { gesture in
				draw(at: pxl(at: gesture.location))
			}
			.onEnded { _ in
				guard state.tool != .eyedropper else { return }
				undoManager?.beginUndoGrouping()
				undoManager?.setActionName(state.tool.actionName)
				undoManager?.endUndoGrouping()
			}
	}
}

private extension EditorView {

	func draw(at pxl: PxL) {
		switch state.tool {
		case .pencil: pencil(at: pxl)
		case .eraser: pencil(.clear, at: pxl)
		case .bucket: bucket(at: pxl)
		case .replace: replace(at: pxl)
		case .eyedropper: state.primaryColor = file[pxl]
		}
	}

	private func pencil(_ px: Px? = .none, at pxl: PxL) {
		let px = px ?? (state.dither && pxl.isEven ? state.secondaryColor : state.primaryColor)
		if let idx = file.size.index(at: pxl) {
			file.layers[pxl.z].withMutablePixels { pxs in
				pxs[idx] = px
			}
		}
	}

	private func bucket(at pxl: PxL) {
		let size = file.size
		guard let idx = size.index(at: pxl) else { return }

		file.layers[pxl.z].withMutablePixels { pxs in
			let c = pxs[idx]
			let pc = state.primaryColor
			let sc = state.dither ? state.secondaryColor : pc
			pxs[idx] = pxl.isEven ? pc : sc

			var stroke = BitSet(count: size.count)
			stroke[idx] = true
			var front = [pxl] as [PxL]
			while !front.isEmpty {
				front = front.flatMap { pxl in
					pxl.neighbors.compactMap { pxl in
						size.index(at: pxl).flatMap { idx in
							if !stroke[idx], pxs[idx] == c {
								pxs[idx] = pxl.isEven ? pc : sc
								stroke[idx] = true
								return pxl
							} else {
								return .none
							}
						}
					}
				}
			}
		}
	}

	private func replace(at pxl: PxL) {
		guard let idx = file.size.index(at: pxl) else { return }
		let c = file.layers[pxl.z][idx]
		let pc = state.primaryColor
		let sc = state.dither ? state.secondaryColor : pc

		file.layers[state.layer].withMutablePixels { [size = file.size] pxs in
			var span = pxs.mutableSpan
			for idx in span.indices where span[idx] == c {
				let rc = size.pxl(at: idx).isEven ? pc : sc
				span[idx] = rc
			}
		}
	}
}
