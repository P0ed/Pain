import SwiftUI
import SpriteKit

@main
struct PaintApp: App {
	var body: some Scene {
		DocumentGroup(newDocument: Document(), editor: { cfg in
			SpriteView(
				scene: DrawingScene(
					size: CGSize(width: 800, height: 600),
					document: cfg.$document
				)
			)
		})
	}
}
