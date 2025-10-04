import SpriteKit
import SwiftUI

final class DrawingScene: SKScene {
	private let canvas: SKSpriteNode
	private let texture: SKMutableTexture

	@Binding
	private var document: Document

	private var palette: Palette = .main
	private var colorIndices: UInt4x2 = .init(primary: 0, secondary: 1)

	private	var tool: Tool = .pencil

	private var zoom: CGFloat = 1.0 {
		didSet { camera?.run(.scale(to: 1.0 / zoom, duration: 0.1)) }
	}

	init(size: CGSize, document: Binding<Document>) {
		_document = document
		texture = SKMutableTexture(size: document.wrappedValue.size.cgSize)
		texture.filteringMode = .nearest
		canvas = SKSpriteNode(texture: texture)
		canvas.anchorPoint = .zero

		zoom = document.wrappedValue.size.zoomToFit(size)

		let cam = SKCameraNode()
		cam.position = document.wrappedValue.size.center
		cam.setScale(1.0 / zoom)

		super.init(size: size)

		scaleMode = .aspectFill
		backgroundColor = .gray

		addChild(canvas)
		addChild(cam)
		camera = cam

		texture.load(document.wrappedValue.contents)
	}

	required init?(coder aDecoder: NSCoder) { fatalError() }

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
		case "0": zoom = document.size.zoomToFit(size)
		case "-": zoom = max(1.0, zoom / 2.0)
		case "=": zoom = min(64.0, zoom * 2.0)
		case "§": camera?.run(.move(to: document.size.center, duration: 0.1))

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
			if let idx = document.size.index(at: pxl) {
				let color = tool == .pencil ? palette[colorIndices.primary] : .clear
				document.contents[idx] = color
				texture.modifyColors(document.contents.count) { ptr in ptr[idx] = color }
			}
		case .bucket:
			break
		case .picker:
			if let idx = document.size.index(at: pxl) {
				palette[colorIndices.primary] = document.contents[idx]
			}
		}
	}
}
