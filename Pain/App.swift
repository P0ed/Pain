import SwiftUI

@main
struct PaintApp: App {
	@UserDefault(key: "palette", default: .warm)
	var palette: Palette

	var body: some Scene {
		DocumentGroup(
			newDocument: Document(),
			editor: { cfg in
				EditorView(palette: $palette, document: cfg.$document)
			}
		)
	}
}
