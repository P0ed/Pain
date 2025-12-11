import SwiftUI

extension FocusedValues {
	@Entry var state: FocusedState?
}

struct MenuCommands: Commands {
	@FocusedValue(\.state) var state

	var body: some Commands {
		CommandGroup(before: .windowSize) {
			ActionButton(
				name: "Size to fit",
				image: "square.resize",
				shortcut: "9",
				disabled: state == nil,
				action: { state?.scaleToFit() }
			)
			ActionButton(
				name: "Actual size",
				image: "square.resize",
				shortcut: "0",
				disabled: state == nil,
				action: { state?.state.setScale(1.0) }
			)
			ActionButton(
				name: "Actual size",
				image: "square.resize",
				shortcut: "+",
				disabled: state == nil,
				action: { state?.state.setScale((state?.state.magnification ?? 1.0) * 2.0) }
			)
			ActionButton(
				name: "Actual size",
				image: "square.resize",
				shortcut: "-",
				disabled: state == nil,
				action: { state?.state.setScale((state?.state.magnification ?? 1.0) / 2.0) }
			)
			Divider()
		}
		CommandMenu("Operations") {
			ActionButton(
				name: "Resize",
				image: "square.resize",
				shortcut: "R",
				modifiers: .command,
				disabled: state == nil,
				action: { state?.state.sizeDialogPresented = true }
			)
			ActionButton(
				name: "Wipe layer",
				image: "windshield.rear.and.wiper",
				shortcut: "W",
				modifiers: .control,
				disabled: state == nil,
				action: { state?.wipeLayer() }
			)
			Divider()
			ActionButton(
				name: "Swap colors",
				image: "rectangle.2.swap",
				shortcut: "x",
				disabled: state == nil,
				action: { state?.state.swapColors() }
			)
			Divider()
			ActionButton(
				name: "Make monochrome",
				image: "sum",
				shortcut: "G",
				modifiers: .command,
				disabled: state == nil,
				action: { state?.makeMonochrome() }
			)
			ActionButton(
				name: "Shift left",
				image: "chevron.left.2",
				shortcut: "<",
				disabled: state == nil,
				action: { state?.shiftLeft() }
			)
			ActionButton(
				name: "Shift right",
				image: "chevron.right.2",
				shortcut: ">",
				disabled: state == nil,
				action: { state?.shiftRight() }
			)
		}
	}
}
