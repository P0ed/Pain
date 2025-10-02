import SpriteKit

final class PainScene: SKScene {
	private let canvas = SKSpriteNode()
	private let texture = SKMutableTexture()

	private var buffer: [Color] = .init(repeating: .white, count: 64 * 64)

	private var palette: Palette = .main
	private var colorIndices: UInt4x2 = .init(primary: 0, secondary: 1)
	private	var tool: Tool = .pencil
	private var zoom: CGFloat = 1.0

	override func sceneDidLoad() {
		backgroundColor = .gray
		addChild(canvas)
		let size = CGSize(width: 64.0, height: 64.0)
		let data = buffer.reduce(into: Data(), { $0.append(contentsOf: $1.data) })
		let texture = SKTexture(data: data, size: size)
		canvas.texture = texture
		canvas.size = size
		let cam = SKCameraNode()
		addChild(cam)
		camera = cam
	}

	override func keyDown(with event: NSEvent) {
		switch event.specialKey {
		case .upArrow: camera?.run(.moveBy(x: 0.0, y: 16.0, duration: 0.1))
		case .downArrow: camera?.run(.moveBy(x: 0.0, y: -16.0, duration: 0.1))
		case .leftArrow: camera?.run(.moveBy(x: -16.0, y: 0.0, duration: 0.1))
		case .rightArrow: camera?.run(.moveBy(x: 16.0, y: 0.0, duration: 0.1))
		default: break
		}
		switch event.characters {
		case "z":
			zoom = zoom == 1.0 ? 16.0 : 1.0
			camera?.run(.scale(to: 1.0 / zoom, duration: 0.1))
		case .some(let chars): print("keyDown: \(chars)")
		default: break
		}
	}

	override func mouseDown(with event: NSEvent) {}
	override func mouseMoved(with event: NSEvent) {}
}

extension Color {
	var data: Data {
		.init([rgba[0], rgba[1], rgba[2], rgba[3]])
	}
}
