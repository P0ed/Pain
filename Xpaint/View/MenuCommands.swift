import SwiftUI

extension FocusedValues {
	@Entry var operations: Operations?
}

struct MenuCommands: Commands {
	@FocusedValue(\.operations) var operations

	var body: some Commands {
		CommandGroup(replacing: .pasteboard) {
			ActionButton(
				name: "Cut",
				image: "scissors",
				shortcut: "X",
				modifiers: .command,
				disabled: operations == nil,
				action: { operations?.cut() }
			)
			ActionButton(
				name: "Copy",
				image: "document.on.document",
				shortcut: "C",
				modifiers: .command,
				disabled: operations == nil,
				action: { operations?.copy() }
			)
			ActionButton(
				name: "Paste",
				image: "document.on.clipboard",
				shortcut: "V",
				modifiers: .command,
				disabled: operations == nil,
				action: { operations?.paste() }
			)
		}
		CommandGroup(before: .windowSize) {
			ActionButton(
				name: "Size to fit",
				image: "arrow.up.left.and.down.right.magnifyingglass",
				shortcut: "9",
				disabled: operations == nil,
				action: { operations?.scaleToFit() }
			)
			ActionButton(
				name: "Actual size",
				image: "1.magnifyingglass",
				shortcut: "0",
				disabled: operations == nil,
				action: { operations?.state.setScale(1.0) }
			)
			ActionButton(
				name: "Zoom out",
				image: "minus.magnifyingglass",
				shortcut: "-",
				disabled: operations == nil,
				action: { operations?.state.setScale((operations?.state.magnification ?? 1.0) / 2.0) }
			)
			ActionButton(
				name: "Zoom in",
				image: "plus.magnifyingglass",
				shortcut: "=",
				disabled: operations == nil,
				action: { operations?.state.setScale((operations?.state.magnification ?? 1.0) * 2.0) }
			)
			Divider()
		}
		CommandMenu("Operations") {
			ActionButton(
				name: "Resize",
				image: "square.resize",
				shortcut: "R",
				modifiers: .command,
				disabled: operations == nil,
				action: { operations?.state.sizeDialogPresented = true }
			)
			ActionButton(
				name: "Wipe layer",
				image: "windshield.rear.and.wiper",
				shortcut: "W",
				modifiers: .control,
				disabled: operations == nil,
				action: { operations?.wipeLayer() }
			)
			Divider()
			ActionButton(
				name: "Make monochrome",
				image: "sum",
				shortcut: "G",
				modifiers: .command,
				disabled: operations == nil,
				action: { operations?.makeMonochrome() }
			)
			ActionButton(
				name: "Shift left",
				image: "chevron.left.2",
				shortcut: "<",
				disabled: operations == nil,
				action: { operations?.shiftLeft() }
			)
			ActionButton(
				name: "Shift right",
				image: "chevron.right.2",
				shortcut: ">",
				disabled: operations == nil,
				action: { operations?.shiftRight() }
			)
		}
		if operations?.film.size.frames ?? 0 > 1 {
			CommandMenu("Layers") {
				ActionButton(
					name: "Previous layer",
					image: "square.3.layers.3d.bottom.filled",
					shortcut: "\u{19}",
					disabled: operations == nil,
					action: { operations?.state.prevLayer() }
				)
				ActionButton(
					name: "Next layer",
					image: "square.3.layers.3d.top.filled",
					shortcut: "\u{9}",
					disabled: operations == nil,
					action: { operations?.state.nextLayer() }
				)
				ActionButton(
					name: "Toggle layer",
					image: "square.3.layers.3d",
					shortcut: " ",
					disabled: operations == nil,
					action: { operations?.state.toggleLayer() }
				)
			}
		}
		CommandMenu("Colors") {
			ActionButton(
				name: "Swap colors",
				image: "rectangle.2.swap",
				shortcut: "x",
				disabled: operations == nil,
				action: { operations?.state.swapColors() }
			)
			ActionButton(
				name: "Pick color",
				image: "paintpalette",
				shortcut: "§",
				disabled: operations == nil,
				action: { operations?.state.colorDialogPresented = true }
			)
		}
		CommandMenu("Shader") {
			ActionButton(
				name: "Edit",
				image: "record.circle.fill",
				shortcut: "E",
				modifiers: .control,
				action: { operations?.state.shaderDialogPresented = true }
			)
			ActionButton(
				name: "Apply",
				image: "play.fill",
				shortcut: "A",
				modifiers: .control,
				action: { operations?.applyShader() }
			)
		}
	}
}
