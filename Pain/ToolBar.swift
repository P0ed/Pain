import SwiftUI

extension EditorView {

	var toolBar: some View {
		VStack(spacing: 12.0) {
			ToolButton(tool: .pencil, state: $state.tool)
			ToolButton(tool: .eraser, state: $state.tool)
			ToolButton(tool: .bucket, state: $state.tool)
			ToolButton(tool: .replace, state: $state.tool)
			Spacer()
			ColorsView(colors: state.colors)
			Spacer()
			ColorsView(colors: palette.colors)
			Spacer()
		}
	}
}

struct ToolButton: View {
	var tool: Tool
	@Binding
	var state: Tool

	var body: some View {
		Button(action: { state = tool }, label: {
			Text(tool.actionName)
				.frame(width: 96.0 + 12.0, height: 32.0)
				.background(
					RoundedRectangle(cornerRadius: 12.0)
						.fill(state == tool ? .secondary : .tertiary)
				)
		})
		.keyboardShortcut(KeyEquivalent(tool.shortcutCharacter), modifiers: [])
		.buttonStyle(.plain)
	}
}

struct ColorsView: View {
	var colors: [Px]

	var body: some View {
		ForEach(
			colors.chunks(ofCount: 2),
			id: \.hashValue,
			content: { colors in
				HStack(spacing: 12.0) {
					ForEach(colors, id: \.hashValue) { color in
						color.color
							.frame(width: 48.0, height: 32.0)
							.border(.thinMaterial, width: 1.0)
					}
				}
			}
		)
	}
}
