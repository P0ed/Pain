import SwiftUI

struct EditorState: Hashable {
	var primaryColor: Px = .black
	var secondaryColor: Px = .white
	var tool: Tool = .pencil
	var zoom: Double = 8.0
	var size: CGSize = .zero
	var drawing: Set<PxL> = []
	var pointer: CGPoint?
}

struct EditorView: View {
	@State var state: EditorState = .init()
	@Binding var palette: Palette
	@Binding var document: Document
	@Environment(\.undoManager) var undoManager
	@State var zoom: Double?
	@FocusState private var focused: Bool

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
						.focusable()
						.focused($focused)
						.focusEffectDisabled()
						.onAppear { focused = true }
						.onKeyPress(action: keyboardController)
						.gesture(drawingController)
						.gesture(zoomingController)
						.onContinuousHover { phase in state.pointer = phase.location }
					}
				}
			}
		)
	}
}
