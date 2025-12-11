import SwiftUI
import UniformTypeIdentifiers

struct EditorView<ContentType: TypeProvider>: View {
	@State var state: EditorState = .init()
	@Binding var palette: Palette
	@Binding var film: Film
	@Heap var global: Film

	@GestureState var magnifyGestureState: CGFloat?
	@FocusState private(set) var focused: Bool
	@Environment(\.undoManager) var undoManager

	init(palette: Binding<Palette>, film: Binding<Film>, global: Heap<Film>) {
		_palette = palette
		_film = film
		_global = global
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
		let magnification = min(max(magnification, 0.25), 64.0)
		let frame = state.frame
		let size = state.size
		let dm = magnification / state.magnification
		let ds = CGVector(
			dx: frame.width - size.width,
			dy: frame.height - size.height
		)
		let progress = CGVector(
			dx: ds.dx > 0.0 ? (size.width * 0.5 - frame.minX) / frame.width : 0.5,
			dy: ds.dy > 0.0 ? (size.height * 0.5 - frame.minY) / frame.height : 0.5,
		)
		let offset = CGPoint(
			x: (frame.width * dm * progress.dx - size.width * 0.5),
			y: (frame.height * dm * progress.dy - size.height * 0.5)
		)
		modify(&state) { state in
			state.magnification = magnification
			state.scrollPosition = .init(point: offset)
		}
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
