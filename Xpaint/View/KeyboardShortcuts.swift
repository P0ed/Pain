import SwiftUI

extension EditorView {

	var keyboardController: (KeyPress) -> KeyPress.Result {
		{ keys in
			let modifiers = keys.modifiers
			let chars = keys.characters

			func numAction(_ num: Int) {
				let idx = num + (modifiers.contains(.option) ? 8 : 0)
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

			case "9": setScale(1.0)
			case "0": setScale(file.size.zoomToFit(state.size))
			case "-": setScale(state.magnification / 2.0)
			case "=": setScale(state.magnification * 2.0)

			case "x" where modifiers == .command: cut()
			case "c" where modifiers == .command: copy()
			case "v" where modifiers == .command: paste()

			case "x": state.swapColors()
			case "w" where modifiers == .control: wipeLayer()
			case "r" where modifiers == .control: sizeDialogPresented = true

			default:
				switch keys.key.character {
				case "\t": state.layer = (state.layer + 1) & 0b11
				case "\u{19}": state.layer = (state.layer - 1) & 0b11
				case KeyEquivalent.leftArrow.character: move(dx: -1)
				case KeyEquivalent.downArrow.character: move(dy: 1)
				case KeyEquivalent.upArrow.character: move(dy: -1)
				case KeyEquivalent.rightArrow.character: move(dx: 1)
				default: return .ignored
				}
			}
			return .handled
		}
	}
}
