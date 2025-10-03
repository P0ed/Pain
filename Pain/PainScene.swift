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

	init(size: CGSize, pxSize: PxSize, data: [Color]? = .none) {
		self.pxSize = pxSize
		buffer = if let data, data.count == pxSize.count {
			data
		} else {
			.init(repeating: .white, count: pxSize.count)
		}
		texture = SKMutableTexture(size: pxSize.cgSize)
		texture.filteringMode = .nearest
		canvas = SKSpriteNode(texture: texture)
		canvas.anchorPoint = .zero

		zoom = pxSize.zoomToFit(size)

		let cam = SKCameraNode()
		cam.position = pxSize.center
		cam.setScale(1.0 / zoom)

		super.init(size: size)

		scaleMode = .aspectFill
		backgroundColor = .gray

		addChild(canvas)
		addChild(cam)
		camera = cam

		texture.load(buffer)
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

extension PainScene {

	func exportCGImage() throws -> CGImage {
		let width = pxSize.width
		let height = pxSize.height
		let bytesPerRow = width * 4

		let image: CGImage = try buffer.withUnsafeBytes { raw in
			let bytes = raw.bindMemory(to: UInt8.self)
			let cfData = try CFDataCreate(nil, bytes.baseAddress, bytes.count)
				.unwrap("Can't make CFData")
			let provider = try CGDataProvider(data: cfData)
				.unwrap("Can't make CGDataProvider")
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

			return try CGImage(
				width: width,
				height: height,
				bitsPerComponent: 8,
				bitsPerPixel: 32,
				bytesPerRow: bytesPerRow,
				space: colorSpace,
				bitmapInfo: bitmapInfo,
				provider: provider,
				decode: nil,
				shouldInterpolate: false,
				intent: .defaultIntent
			)
			.unwrap("Can't make CGImage")
		}

		return image
	}
}
