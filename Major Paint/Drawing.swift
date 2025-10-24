import SwiftUI

extension EditorView {

	var size: CGSize { file.size.cgSize.zoomed(state.magnification) }

	func pxl(at location: CGPoint) -> PxL {
		CGPoint(
			x: location.x / state.magnification,
			y: file.size.cgSize.height - location.y / state.magnification
		).pxl
	}

	var drawingController: some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { gesture in
				if state.tool.isDraggable || state.drawing.isEmpty {
					draw(at: pxl(at: gesture.location))
				}
			}
			.onEnded { _ in
				state.drawing = []
				undoManager?.beginUndoGrouping()
				undoManager?.setActionName(state.tool.actionName)
				undoManager?.endUndoGrouping()
			}
	}
}

private extension EditorView {

	func draw(at pxl: PxL) {
		switch state.tool {
		case .pencil: pencil(
			state.dither && pxl.isEven ? state.secondaryColor : state.primaryColor,
			at: pxl
		)
		case .eraser: pencil(.clear, at: pxl)
		case .bucket: bucket(at: pxl)
		case .replace: replace(at: pxl)
		}
	}

	private func pencil(_ px: Px, at pxl: PxL) {
		if let idx = file.size.index(at: pxl) {
			file.pxs[idx] = px
		}
	}

	private func bucket(at pxl: PxL) {
		if let idx = file.size.index(at: pxl) {
			let c = file.pxs[idx]
			let pc = state.primaryColor
			let sc = state.dither ? state.secondaryColor : pc

			var stroke = [idx: pxl.isEven ? sc : pc] as [Int: Px]
			var front = [pxl] as [PxL]
			while !front.isEmpty {
				front = front.flatMap { pxl in
					pxl.neighbors.compactMap { pxl in
						file.size.index(at: pxl).flatMap { idx in
							if stroke[idx] == .none, file.pxs[idx] == c {
								stroke[idx] = pxl.isEven ? sc : pc
								return pxl
							} else {
								return .none
							}
						}
					}
				}
			}
			stroke.forEach { idx, px in
				file.pxs[idx] = px
			}
		}
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
