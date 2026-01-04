import SwiftUI

@main
struct PaintApp: App {
	@UserDefault(default: .warm) var palette: Palette
	@State var global: Film = .global

	var body: some Scene {
		documentGroup(PXD.self)
		documentGroup(PNG.self)
		.commands { MenuCommands() }
	}

	func documentGroup<T: TypeProvider>(_ type: T.Type) -> some Scene {
		let size = global.size
		let isEmpty = size.count == 0
		return DocumentGroup(
			newDocument: Document<T>(
				width: isEmpty ? 32 : size.width,
				height: isEmpty ? 32 : size.height,
			),
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
