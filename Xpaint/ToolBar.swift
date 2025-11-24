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
			ToolButton(tool: .picker, state: $state.tool)
			ToolButton(tool: .eraser, state: $state.tool)
			ToolButton(tool: .bucket, state: $state.tool)
			ToolButton(tool: .replace, state: $state.tool)
		}
		ToolbarItemGroup {
			Spacer()
		}
		ToolbarItemGroup {
			ActionButton(name: "Make monochrome", image: "sum", shortcut: "G") {
				file.makeMonochrome()
			}
			ActionButton(name: "Shift left", image: "chevron.left.2", shortcut: "<") {
				file.shiftLeft()
			}
			ActionButton(name: "Shift right", image: "chevron.right.2", shortcut: ">") {
				file.shiftRight()
			}
			ActionButton(
				name: "Export",
				image: "square.and.arrow.up",
				shortcut: "E",
				modifiers: .command
			) {
				export.document = Document(converting: file)
				export.exporting = true
			}
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

	static let names: [String] = ["a", "b", "c", "d"]

	var name: String { Self.names[index & 0b11] }

	var body: some View {
		Button("layer \(name.uppercased())", systemImage: "\(name).square.fill", action: {
			state = index
		})
		.foregroundStyle(state == index ? Color.accent : .primary)
		.keyboardShortcut(.init(name.first!), modifiers: .control)
	}
}
