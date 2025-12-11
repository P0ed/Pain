import SwiftUI
import UniformTypeIdentifiers

struct EditorView<ContentType: TypeProvider>: View {
	@State var state: EditorState = .init()
	@Binding var palette: Palette
	@Binding var film: Film
	@Binding var global: Film

	@GestureState var magnifyGestureState: CGFloat?
	@FocusState private(set) var focused: Bool
	@Environment(\.undoManager) var undoManager

	var body: some View {
		NavigationSplitView(
			sidebar: { sidebar },
			detail: { canvas }
		)
		.toolbar { toolbar }
		.focusable()
		.focused($focused)
		.focusEffectDisabled()
		.focusedSceneValue(\.state, focusedState)
		.onAppear { focused = true }
		.onKeyPress(action: keyboardController)
		.fileExporter(
			isPresented: $state.exporting,
			document: state.exportedFilm.map(Document<ContentType.ExportType>.init(film:)),
			contentType: ContentType.ExportType.type
		) { _ in
			state.exportedFilm = nil
		}
		.sheet(isPresented: $state.sizeDialogPresented) { sizeDialog }
	}

	var sizeDialog: some View {
		SizeDialog(size: film.size) { w, h in
			film.resize(width: w, height: h)
		}
	}

	var focusedState: FocusedState {
		FocusedState(
			film: $film,
			state: $state,
			global: $global
		)
	}

	private var canvas: some View {
		ScrollView([.horizontal, .vertical]) {
			GeometryReader { geo in
				Canvas { ctx, size in
					film.render(mask: state.visibleLayers, in: ctx, size: size)
				}
				.gesture(drawingController)
				.onChange(of: geo.frame(in: .scrollView)) { _, new in
					state.frame = new
				}
			}
			.frame(
				width: film.size.cg.width * state.magnification,
				height: film.size.cg.height * state.magnification
			)
		}
		.scrollPosition($state.scrollPosition)
		.gesture(magnificationController)
		.background { background }
	}

	private var background: some View {
		GeometryReader { geo in
			Image(.background).resizable(resizingMode: .tile)
				.onChange(of: geo.size) { _, new in
					guard new.width != 0.0, new.height != 0.0 else { return }

					let old = state.size
					state.size = new
					if old == .zero {
						setScale(film.size.zoomToFit(state.size))
					}
				}
		}
	}

	func setScale(_ magnification: CGFloat) {
		state.setScale(magnification)
	}

	private var magnificationController: some Gesture {
		MagnifyGesture(minimumScaleDelta: 0)
			.updating($magnifyGestureState) { gesture, initial, _ in
				if initial == .none { initial = state.magnification }
				let initial = initial ?? state.magnification
				setScale(initial * gesture.magnification)
			}
	}
}
