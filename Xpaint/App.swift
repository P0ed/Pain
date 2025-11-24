import SwiftUI

@main
struct PaintApp: App {
	@UserDefault(key: "palette", default: .warm)
	var palette: Palette

	var body: some Scene {
		DocumentGroup(
			newDocument: Document<PXD>(),
			editor: { cfg in
				EditorView(palette: $palette, file: cfg.$document)
			}
		)
		.windowToolbarStyle(.unified)

		DocumentGroup(
			newDocument: Document<PNG>(),
			editor: { cfg in
				EditorView(palette: $palette, file: cfg.$document)
			}
		)
		.windowToolbarStyle(.unified)
	}
}
