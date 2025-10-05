import SwiftUI
import SpriteKit

@main
struct PaintApp: App {
	@UserDefault(key: "palette", defaultValue: .warm)
	var palette: Palette

	var body: some Scene {
		DocumentGroup(
			newDocument: Document(),
			editor: { cfg in
				NavigationSplitView(
					sidebar: {
						ToolBar(palette: palette)
					},
					detail: {
						SpriteView(
							scene: DrawingScene(
								size: CGSize(width: 800, height: 600),
								palette: $palette,
								document: cfg.$document
							)
						)
					}
				)
			}
		)
	}
}
