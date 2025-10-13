import SwiftUI

struct EditorState {
	var primaryColor: Px = .black
	var secondaryColor: Px = .white
	var tool: Tool = .pencil
	var zoom: Double = 8.0
	var size: CGSize = .zero
	var modifiers: EventModifiers = []
}

struct EditorView: View {
	@State
	var state: EditorState = .init()
	@Binding
	var palette: Palette
	@Binding
	var document: Document
	@Environment(\.undoManager)
	var undoManager

	var size: CGSize {
		document.size.cgSize.zoomed(state.zoom)
	}

	var body: some View {
		NavigationSplitView(
			sidebar: { toolBar },
			detail: {
				GeometryReader { geo in
					ScrollView([.vertical, .horizontal]) {
						Canvas { ctx, _ in
							guard let image = document.image else { return }
							state.size = geo.size

							ctx.draw(
								image,
								in: .init(origin: .zero, size: size)
							)
						}
						.frame(width: size.width, height: size.height)
						.gesture(dragController)
					}
				}
			}
		)
		.onKeyPress(action: keyboardController)
	}
}
