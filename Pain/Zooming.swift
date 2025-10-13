import SwiftUI

extension EditorView {

	var zoomingController: some Gesture {
		MagnifyGesture(minimumScaleDelta: 0)
			.onChanged { gesture in
				if zoom == .none { zoom = state.zoom }
				state.zoom = min(max((zoom ?? 1.0) * gesture.magnification, 1.0), 64.0)
			}
			.onEnded { _ in
				zoom = .none
			}
	}
}
