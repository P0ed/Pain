import SpriteKit

final class PainScene: SKScene {
	private let canvas = SKSpriteNode()
	private let texture = SKTexture()

	private var buffer: [UInt8] = []

	private var palette: Palette = .main
	private var colorIndices: UInt4x2 = .init(primary: 0, secondary: 1)
	private	var tool: Tool = .pencil

	override func sceneDidLoad() {
		backgroundColor = .black
		addChild(canvas)
		let cam = SKCameraNode()
		addChild(cam)
		camera = cam
	}

	override func keyDown(with event: NSEvent) {
		switch event.keyCode {
		default:
			print("keyDown: \(event.characters ?? "") keyCode: \(event.keyCode)")
		}
	}

	override func mouseDown(with event: NSEvent) {}
	override func mouseMoved(with event: NSEvent) {}
}
