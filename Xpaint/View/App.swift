import SwiftUI

@main
struct PaintApp: App {
	@UserDefault(default: .warm)
	var palette: Palette
	@Heap
	var global: Film = .global

	var body: some Scene {
		documentGroup(PXD.self)
		documentGroup(PNG.self)
		.commands { MenuCommands() }
	}

	func documentGroup<T: TypeProvider>(_ type: T.Type) -> some Scene {
		DocumentGroup(
			newDocument: Document<T>(),
			editor: { cfg in
				EditorView<T>(
					palette: $palette,
					film: cfg.$document.film,
					global: $global
				)
			}
		)
		.windowToolbarStyle(.unified)
	}
}
