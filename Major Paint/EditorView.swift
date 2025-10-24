import SwiftUI

struct EditorState: Hashable {
	var primaryColor: Px = .black
	var secondaryColor: Px = .white
	var tool: Tool = .pencil
	var dither: Bool = false
	var magnification: CGFloat = 8.0
	var magnifyGestureState: CGFloat?
	var size: CGSize = .zero
	var drawing: Set<PxL> = []
	var pointer: CGPoint?
}

struct EditorView: View {
	@State var state: EditorState = .init()
	@Binding var palette: Palette
	@Binding var file: Document

	@FocusState private(set) var focused: Bool
	@Environment(\.undoManager) var undoManager
	@Environment(\.dismiss) var dismiss

	init(palette: Binding<Palette>, file: Binding<Document>) {
		_palette = palette
		_file = file
	}

	var body: some View {
		NavigationSplitView(
			sidebar: { toolBar },
			detail: {
				ZStack {
					Image(.backround)
						.resizable(resizingMode: .tile)

					GeometryReader { geo in
						ScrollView([.vertical, .horizontal]) {
							Canvas { ctx, _ in
								guard let image = file.image else { return }
								state.size = geo.size

								ctx.draw(
									image,
									in: .init(origin: .zero, size: size)
								)
							}
							.frame(width: size.width, height: size.height)
							.gesture(drawingController)
							.onContinuousHover { phase in state.pointer = phase.location }
						}
					}
				}
				.gesture(zoomingController)
			}
		)
		.focusable()
		.focused($focused)
		.focusEffectDisabled()
		.onAppear { focused = true }
		.onKeyPress(action: keyboardController)
	}
}
