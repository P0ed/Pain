import SwiftUI

extension EditorView {

	var toolbar: some View {
		HStack {
			ToolButton(tool: .pencil, state: $state.tool)
			ToolButton(tool: .eraser, state: $state.tool)
			ToolButton(tool: .bucket, state: $state.tool)
			ToolButton(tool: .replace, state: $state.tool)
			Spacer(minLength: 48.0)
			ActionButton(name: "Make monochrome", image: "sum", shortcut: "G", action: {
				file.makeMonochrome()
			})
			ActionButton(name: "Shift left", image: "chevron.left.2", shortcut: "<", action: {
				file.shiftLeft()
			})
			ActionButton(name: "Shift right", image: "chevron.right.2", shortcut: ">", action: {
				file.shiftRight()
			})
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
	var action: () -> Void

	var body: some View {
		Button(name, systemImage: image, action: action)
			.keyboardShortcut(KeyEquivalent(shortcut), modifiers: [])
	}
}

extension EditorView {

	var sidebar: some View {
		ScrollView(.vertical) {
			VStack(spacing: 0.0) {
				ColorsView(colors: state.colors)
				Toggle("Dither", isOn: $state.dither)
					.keyboardShortcut(KeyEquivalent("d"), modifiers: [])
					.padding(8.0)
				Spacer(minLength: 4.0)
				ColorsView(colors: palette.colors) { color in
					state.primaryColor = color
				}
			}
			.padding(.vertical, 12.0)
		}
		.scrollIndicators(.never)
	}
}


struct ColorsView: View {
	var colors: [Px]
	var didTap: (Px) -> Void = ø

	var body: some View {
		ForEach(
			colors.enumerated(),
			id: \.offset,
			content: { _, color in
				color.color
					.frame(width: 128.0, height: 24.0)
					.onTapGesture { didTap(color) }
			}
		)
	}
}
