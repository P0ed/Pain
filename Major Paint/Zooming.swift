import SwiftUI

extension EditorView {

	var magnificationController: some Gesture {
		MagnifyGesture(minimumScaleDelta: 0)
			.onChanged { gesture in
				if state.magnifyGestureState == .none {
					state.magnifyGestureState = state.magnification
				}
				let initial = state.magnifyGestureState ?? state.magnification
				state.magnification = min(max(initial * gesture.magnification, 1.0), 64.0)
			}
			.onEnded { _ in
				state.magnifyGestureState = .none
			}
	}
}
