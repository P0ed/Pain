import SwiftUI
import SpriteKit

struct EditorView: View {
	@State
	var state: EditorState = .init(primaryColor: .black, secondaryColor: .white, tool: .pencil)
	@Binding
	var palette: Palette
	@Binding
	var document: Document

	var body: some View {
		NavigationSplitView(
			sidebar: { toolBar },
			detail: {
				SpriteView(
					scene: DrawingScene(
						size: CGSize(width: 800, height: 600),
						palette: $palette,
						document: $document,
						state: $state
					)
				)
			}
		)
	}

	var toolBar: some View {
		List {
			Button("Pencil", action: { state.tool = .pencil })
				.buttonStyle(.glass(state.tool == .pencil ? .regular : .clear))
			Button("Eraser", action: { state.tool = .eraser })
				.buttonStyle(.glass(state.tool == .eraser ? .regular : .clear))
			Button("Bucket", action: { state.tool = .bucket })
				.buttonStyle(.glass(state.tool == .bucket ? .regular : .clear))
			Button("Replace", action: { state.tool = .replace })
				.buttonStyle(.glass(state.tool == .replace ? .regular : .clear))
			Spacer()
			state.primaryColor.color.border(.thinMaterial, width: 1.0)
			state.secondaryColor.color.border(.thinMaterial, width: 1.0)
			Spacer()
			ForEach(
				palette.colors,
				id: \.hashValue,
				content: { $0.color.border(.thinMaterial, width: 1.0) }
			)
		}
		.background(Color.white)
	}
}

