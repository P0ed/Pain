import SwiftUI

@main
struct PaintApp: App {
	@UserDefault(default: .warm)
	var palette: Palette
	@Heap
	var rx: PxBuffer = .rx

	var body: some Scene {
		documentGroup(PXD.self)
		documentGroup(PNG.self)
	}

	func documentGroup<T: TypeProvider>(_ type: T.Type) -> some Scene {
		DocumentGroup(
			newDocument: Document<T>(),
			editor: { cfg in
				EditorView(
					palette: $palette,
					file: cfg.$document,
					rx: $rx
				)
			}
		)
		.windowToolbarStyle(.unified)
	}
}
