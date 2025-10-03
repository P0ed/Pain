import SpriteKit

final class PainScene: SKScene {
	private let pxSize: PxSize
	private let canvas: SKSpriteNode
	private let texture: SKMutableTexture

	private var buffer: [Color]

	private var palette: Palette = .main
	private var colorIndices: UInt4x2 = .init(primary: 0, secondary: 1)

	private	var tool: Tool = .pencil

	private var zoom: CGFloat = 1.0 {
		didSet { camera?.run(.scale(to: 1.0 / zoom, duration: 0.1)) }
	}

	init(size: CGSize, pxSize: PxSize) {
		self.pxSize = pxSize
		buffer = .init(repeating: .white, count: pxSize.count)
		texture = SKMutableTexture(size: pxSize.cgSize)
		texture.filteringMode = .nearest
		canvas = SKSpriteNode(texture: texture)
		canvas.anchorPoint = .zero

		super.init(size: size)

		scaleMode = .aspectFill
		texture.load(buffer)
	}

	required init?(coder aDecoder: NSCoder) { fatalError() }

	override func sceneDidLoad() {
		backgroundColor = .gray
		addChild(canvas)

		let cam = SKCameraNode()
		cam.position = pxSize.center
		addChild(cam)
		camera = cam

		zoom = pxSize.zoomToFit(size)
	}

	override func keyDown(with event: NSEvent) {

		switch event.specialKey {
		case .upArrow: camera?.run(.moveBy(x: 0.0, y: 32.0 / zoom, duration: 0.1))
		case .downArrow: camera?.run(.moveBy(x: 0.0, y: -32.0 / zoom, duration: 0.1))
		case .leftArrow: camera?.run(.moveBy(x: -32.0 / zoom, y: 0.0, duration: 0.1))
		case .rightArrow: camera?.run(.moveBy(x: 32.0 / zoom, y: 0.0, duration: 0.1))
		default: break
		}

		switch event.characters {
		case "9": zoom = 1.0
		case "0": zoom = pxSize.zoomToFit(size)
		case "-": zoom = max(1.0, zoom / 2.0)
		case "=": zoom = min(64.0, zoom * 2.0)
		case "§": camera?.run(.move(to: pxSize.center, duration: 0.1))

		case "p", "q": tool = .pencil
		case "b", "w": tool = .bucket
		case "e": tool = .eraser
		case "i": tool = .picker

		case "x": colorIndices.swap()

		case .some(let chars): print("keyDown: \(chars)")
		default: break
		}
	}

	override func mouseDown(with event: NSEvent) {
		let pxl = event.location(in: canvas).pxl

		switch tool {
		case .pencil, .eraser:
			if let idx = pxSize.index(at: pxl) {
				let color = tool == .pencil ? palette[colorIndices.primary] : .clear
				buffer[idx] = color
				texture.modifyColors(buffer.count) { ptr in ptr[idx] = color }
			}
		case .bucket:
			break
		case .picker:
			if let idx = pxSize.index(at: pxl) {
				palette[colorIndices.primary] = buffer[idx]
			}
		}
	}
}
