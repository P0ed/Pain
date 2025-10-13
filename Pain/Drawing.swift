import SwiftUI

extension EditorView {

	var dragController: some Gesture {
		@State var stroke = [:] as [Int: Px]
		return DragGesture(minimumDistance: 0)
			.onChanged { gesture in
				let pxl = CGPoint(
					x: gesture.location.x / state.zoom,
					y: document.size.cgSize.height - gesture.location.y / state.zoom
				).pxl

				if stroke.isEmpty {
					if state.modifiers.contains(.option) {
						if let idx = document.size.index(at: pxl) {
							state.primaryColor = document.pxs[idx]
							return
						}
					}
				}
				if state.tool.isDraggable || stroke == [:] {
					draw(at: pxl)
				}
			}
			.onEnded { _ in
				stroke = [:]
				undoManager?.beginUndoGrouping()
				undoManager?.setActionName(state.tool.actionName)
				undoManager?.endUndoGrouping()
			}
	}
}

private extension EditorView {

	func draw(at pxl: PxL) {
		switch state.tool {
		case .pencil: pencil(state.primaryColor, at: pxl)
		case .eraser: pencil(.clear, at: pxl)
		case .bucket: bucket(at: pxl)
		case .replace: replace(at: pxl)
		}
	}

	private func pencil(_ px: Px, at pxl: PxL) {
		if let idx = document.size.index(at: pxl) {
			document.pxs[idx] = px
		}
	}

	private func bucket(at pxl: PxL) {
		if let idx = document.size.index(at: pxl) {
			let c = document.pxs[idx]
			let rc = state.primaryColor

			var stroke = [:] as [Int: Px]
			var front = [pxl] as [PxL]
			while !front.isEmpty {
				front = front.flatMap { pxl in
					pxl.neighbors.compactMap { pxl in
						document.size.index(at: pxl).flatMap { idx in
							if stroke[idx] == .none, document.pxs[idx] == c {
								stroke[idx] = rc
								return pxl
							} else {
								return .none
							}
						}
					}
				}
			}
			stroke.forEach { idx, px in
				document.pxs[idx] = px
			}
		}
	}

	private func replace(at pxl: PxL) {
		if let idx = document.size.index(at: pxl) {
			let c = document.pxs[idx]
			let rc = state.primaryColor
			document.pxs = document.pxs.map { px in px == c ? rc : px }
		}
	}
}
