import SwiftUI

extension EditorView {

	@ToolbarContentBuilder
	var toolbar: some ToolbarContent {
		if ContentType.type == .pxd {
			ToolbarItemGroup {
				ForEach(0..<4) { idx in
					LayerButton(index: idx, state: $state.layer)
				}
			}
			ToolbarItemGroup {
				Spacer()
			}
		}
		ToolbarItemGroup {
			ToolButton(tool: .pencil, state: $state.tool)
			ToolButton(tool: .eyedropper, state: $state.tool)
			ToolButton(tool: .eraser, state: $state.tool)
			ToolButton(tool: .bucket, state: $state.tool)
			ToolButton(tool: .replace, state: $state.tool)
		}
		ToolbarItemGroup {
			Spacer()
		}
		ToolbarItemGroup {
			ActionButton(
				name: "Make monochrome",
				image: "sum",
				shortcut: "G",
				modifiers: .command,
				action: makeMonochrome
			)
			ActionButton(
				name: "Shift left",
				image: "chevron.left.2",
				shortcut: "<",
				action: shiftLeft
			)
			ActionButton(
				name: "Shift right",
				image: "chevron.right.2",
				shortcut: ">",
				action: shiftRight
			)
			ActionButton(
				name: "Export",
				image: "square.and.arrow.up",
				shortcut: "E",
				modifiers: .command,
				action: exportFile
			)
		}
	}
}

struct ToolButton: View {
	var tool: Tool
	@Binding
	var state: Tool

	var body: some View {
		Button(tool.actionName, systemImage: tool.systemImage, action: { state = tool })
			.foregroundStyle(state == tool ? Color.accent : .primary)
			.keyboardShortcut(KeyEquivalent(tool.shortcutCharacter), modifiers: [])
	}
}

struct ActionButton: View {
	var name: String
	var image: String
	var shortcut: Character
	var modifiers: EventModifiers = []
	var action: () -> Void

	var body: some View {
		Button(name, systemImage: image, action: action)
			.keyboardShortcut(KeyEquivalent(shortcut), modifiers: modifiers)
	}
}

struct LayerButton: View {
	var index: Int
	@Binding
	var state: Int

	static let names: [String] = ["A", "B", "C", "D"]

	var name: String { Self.names[index & 0b11] }

	var body: some View {
		Button("Layer \(name)", systemImage: "\(name.lowercased()).square.fill", action: {
			state = index
		})
		.foregroundStyle(state == index ? Color.accent : .primary)
		.keyboardShortcut(.init(name.first!), modifiers: .shift)
	}
}
