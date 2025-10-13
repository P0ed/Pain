import SwiftUI

extension EditorView {

	var keyboardController: (KeyPress) -> KeyPress.Result {
		{ keys in
			state.modifiers = keys.modifiers
			let chars = keys.characters

			func numAction(_ num: Int) {
				let idx = num + (state.modifiers.contains(.option) ? 8 : 0)
				if state.modifiers.contains(.command) {
					palette = [Palette].list[idx & 0x7]
				} else if state.modifiers.contains(.control) {
					palette[idx] = state.primaryColor
				} else {
					state.primaryColor = palette[idx]
				}
			}

			switch chars {
			case "1": numAction(0)
			case "2": numAction(1)
			case "3": numAction(2)
			case "4": numAction(3)
			case "5": numAction(4)
			case "6": numAction(5)
			case "7": numAction(6)
			case "8": numAction(7)

			case "9": state.zoom = 1.0
			case "0": state.zoom = document.size.zoomToFit(state.size)
			case "-": state.zoom = max(1.0, state.zoom / 2.0)
			case "=": state.zoom = min(64.0, state.zoom * 2.0)

			case "x": state.swapColors()

			default: return .ignored
			}

			return .handled
		}
	}
}
