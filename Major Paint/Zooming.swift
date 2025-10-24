import SwiftUI

extension EditorView {

	var zoomingController: some Gesture {
		MagnifyGesture(minimumScaleDelta: 0)
			.onChanged { gesture in
				if magnifyGestureState == .none { magnifyGestureState = state.magnification }
				let initial = magnifyGestureState ?? state.magnification
				state.magnification = min(max(initial * gesture.magnification, 1.0), 64.0)
			}
			.onEnded { _ in
				magnifyGestureState = .none
			}
	}
}
