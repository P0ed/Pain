import SwiftUI

struct EditorState: Equatable {
	var primaryColor: Px = .black
	var secondaryColor: Px = .white
	var tool: Tool = .pencil
	var dither: Bool = false
	var size: CGSize = .zero
	var frame: CGRect = .zero
	var scrollPosition: ScrollPosition = .init(point: .zero)
	var magnification: CGFloat = 8.0
}

struct EditorView: View {
	@State var state: EditorState = .init()
	@Binding var palette: Palette
	@Binding var file: Document

	@FocusState private(set) var focused: Bool
	@Environment(\.undoManager) var undoManager

	init(palette: Binding<Palette>, file: Binding<Document>) {
		_palette = palette
		_file = file
	}

	var body: some View {
		NavigationSplitView(
			sidebar: { sidebar },
			detail: { canvas }
		)
		.toolbar { toolbar }
		.focusable()
		.focused($focused)
		.focusEffectDisabled()
		.onAppear { focused = true }
		.onKeyPress(action: keyboardController)
	}

	private var canvas: some View {
		ScrollView([.horizontal, .vertical]) {
			GeometryReader { geo in
				Canvas { ctx, size in
					file.render(in: ctx, size: size)
					print("render:", size)
				}
				.gesture(drawingController)
				.onChange(of: geo.frame(in: .scrollView)) { _, new in
					print("frame:", new)
					state.frame = new
				}
			}
			.frame(
				width: file.size.cg.width * state.magnification,
				height: file.size.cg.height * state.magnification
			)
		}
		.scrollPosition($state.scrollPosition)
		.background {
			GeometryReader { geo in
				Image(.background).resizable(resizingMode: .tile)
					.onChange(of: geo.size) { _, new in
						state.size = new
					}
			}
		}
	}

	func setScale(_ magnification: CGFloat) {
		let offset = CGPoint(
			x: state.frame.midX,
			y: state.frame.midY
		)
		print("offset:", offset)
		modify(&state) { state in
			state.magnification = magnification
			state.scrollPosition = .init(point: offset)
		}
	}
}
