import SwiftUI

extension EditorView {

	private var dispatch: (@escaping () -> Void) -> Void {
		{ f in DispatchQueue.main.async(execute: f) }
	}

	var keyboardController: (KeyPress) -> KeyPress.Result {
		{ keys in
			let modifiers = keys.modifiers
			let chars = keys.characters

			func numAction(_ num: Int) {
				let idx = num + (modifiers.contains(.shift) ? 8 : 0)
				if modifiers.contains(.command) {
					palette = [Palette].builtin[idx & 0x7]
				} else if modifiers.contains(.control) {
					palette[idx] = state.primaryColor
				} else {
					state.primaryColor = palette[idx]
				}
			}

			switch chars {
			case "1", "!": numAction(0)
			case "2", "@": numAction(1)
			case "3", "#": numAction(2)
			case "4", "$": numAction(3)
			case "5", "%": numAction(4)
			case "6", "^": numAction(5)
			case "7", "&": numAction(6)
			case "8", "*": numAction(7)

			case "9": setScale(film.size.zoomToFit(state.size))
			case "0": setScale(1.0)
			case "-": setScale(state.magnification / 2.0)
			case "=": setScale(state.magnification * 2.0)

			case "x" where modifiers == .command: dispatch { focusedState.cut() }
			case "c" where modifiers == .command: dispatch { focusedState.copy() }
			case "v" where modifiers == .command: dispatch { focusedState.paste() }

			default:
				switch keys.key.character {
				case "\u{9}": state.layer = (state.layer + 1) & 0b11
				case "\u{19}": state.layer = (state.layer - 1) & 0b11
				case KeyEquivalent.space.character: state.toggleLayer()
				case KeyEquivalent.leftArrow.character: dispatch { focusedState.move(dx: -1) }
				case KeyEquivalent.downArrow.character: dispatch { focusedState.move(dy: 1) }
				case KeyEquivalent.upArrow.character: dispatch { focusedState.move(dy: -1) }
				case KeyEquivalent.rightArrow.character: dispatch { focusedState.move(dx: 1) }
				default: return .ignored
				}
			}
			return .handled
		}
	}
}
