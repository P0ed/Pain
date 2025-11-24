import SwiftUI

extension EditorView {

	func pxl(at location: CGPoint) -> PxL {
		CGPoint(
			x: location.x / state.magnification,
			y: file.size.cg.height - location.y / state.magnification
		).pxl
	}

	var drawingController: some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { gesture in
				draw(at: pxl(at: gesture.location))
			}
			.onEnded { _ in
				guard state.tool != .picker else { return }
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
		case .picker: state.primaryColor = file[pxl]
		}
	}

	private func pencil(_ px: Px? = .none, at pxl: PxL) {
		let px = px ?? (state.dither && pxl.isEven ? state.secondaryColor : state.primaryColor)
		if let idx = file.size.index(at: pxl) {
			file.pxs[idx] = px
		}
	}

	private func bucket(at pxl: PxL) {
		let size = file.size
		var pxs = file.pxs

		guard let idx = size.index(at: pxl) else { return }

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
		file.pxs = pxs
	}

	private func replace(at pxl: PxL) {
		if let idx = file.size.index(at: pxl) {
			let c = file.pxs[idx]
			let pc = state.primaryColor
			let sc = state.dither ? state.secondaryColor : pc

			file.pxs = file.pxs.enumerated()
				.map { [size = file.size] idx, px in
					let rc = size.pxl(at: idx).isEven ? pc : sc
					return px == c ? rc : px
				}
		}
	}
}
