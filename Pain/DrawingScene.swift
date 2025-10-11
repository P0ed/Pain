import SpriteKit
import SwiftUI

final class DrawingScene: SKScene {
	private let canvas: SKSpriteNode
	private let texture: SKMutableTexture

	@Binding
	private var document: Document
	@Binding
	private var palette: Palette
	@Binding
	private var state: EditorState

	private var zoom: CGFloat = 1.0 {
		didSet { camera?.run(.scale(to: 1.0 / zoom, duration: 0.1)) }
	}

	private var stroke: [Int: Px]? = .none
	private var drawing: Bool { stroke != .none }

	private var lifetime: [Any] = []

	init(
		size: CGSize,
		palette: Binding<Palette>,
		document: Binding<Document>,
		state: Binding<EditorState>
	) {
		_palette = palette
		_document = document
		_state = state
		let doc = document.wrappedValue
		texture = SKMutableTexture(size: doc.size.cgSize)
		texture.filteringMode = .nearest
		canvas = SKSpriteNode(texture: texture)
		canvas.anchorPoint = CGPoint(x: 0, y: 1.0)
		canvas.yScale = -1.0

		zoom = doc.size.zoomToFit(size)

		let cam = SKCameraNode()
		cam.position = doc.size.center
		cam.setScale(1.0 / zoom)

		super.init(size: size)

		scaleMode = .aspectFill
		backgroundColor = .gray

		addChild(canvas)
		addChild(cam)
		camera = cam

		texture.load(doc.pxs)

		let reload = { [weak self] n in
			if let self, let um = n.object as? UndoManager, undoManager == um {
				texture.load(self.document.pxs)
			}
		} as (Notification) -> Void
		lifetime = [
			NotificationCenter.default.addObserver(
				forName: .NSUndoManagerDidUndoChange,
				object: nil,
				queue: .main,
				using: reload
			),
			NotificationCenter.default.addObserver(
				forName: .NSUndoManagerDidRedoChange,
				object: nil,
				queue: .main,
				using: reload
			)
		]
	}

	required init?(coder aDecoder: NSCoder) { fatalError() }

	override var undoManager: UndoManager? { view?.window?.undoManager }

	override func keyDown(with event: NSEvent) {
		guard !drawing else { return }

		let flags = event.modifierFlags
		let chars = event.charactersIgnoringModifiers

		switch event.specialKey {
		case .upArrow: camera?.run(.moveBy(x: 0.0, y: 48.0 / zoom, duration: 0.1))
		case .downArrow: camera?.run(.moveBy(x: 0.0, y: -48.0 / zoom, duration: 0.1))
		case .leftArrow: camera?.run(.moveBy(x: -48.0 / zoom, y: 0.0, duration: 0.1))
		case .rightArrow: camera?.run(.moveBy(x: 48.0 / zoom, y: 0.0, duration: 0.1))
		default: break
		}

		func numAction(_ num: Int) {
			let idx = num + (flags.contains(.option) ? 8 : 0)
			if flags.contains(.command) {
				palette = [Palette].list[idx & 0x7]
			} else if flags.contains(.control) {
				palette[idx] = state.primaryColor
			} else {
				state.primaryColor = palette[idx]
			}
		}

		switch chars {
		case "1": numAction(0)
		case "2": numAction(1)
		case "3": numAction(2)
		case "4": numAction(3)
		case "5": numAction(4)
		case "6": numAction(5)
		case "7": numAction(6)
		case "8": numAction(7)

		case "9": zoom = 1.0
		case "0": zoom = document.size.zoomToFit(size)
		case "-": zoom = max(1.0, zoom / 2.0)
		case "=": zoom = min(64.0, zoom * 2.0)
		case "§": camera?.run(.move(to: document.size.center, duration: 0.1))

		case "p": state.tool = .pencil
		case "b": state.tool = .bucket
		case "e": state.tool = .eraser
		case "r": state.tool = .replace

		case "x": state.swapColors()
		default: break
		}
	}

	private func setPixels(_ pxs: [Int: Px]) {
		if pxs.isEmpty { return }

		pxs.forEach { idx, px in document.pxs[idx] = px }

		texture.modifyColors(document.pxs.count) { ptr in
			pxs.forEach { idx, px in ptr[idx] = px }
		}
	}

	func draw(at pxl: PxL) {
		switch state.tool {
		case .pencil, .eraser:
			if let idx = document.size.index(at: pxl), stroke?[idx] == nil {
				let color = state.tool == .pencil ? state.primaryColor : Px.clear
				stroke?[idx] = document.pxs[idx]
				setPixels([idx: color])
			}
		case .bucket:
			if let idx = document.size.index(at: pxl) {
				let c = document.pxs[idx]
				let rc = state.primaryColor

				var stroke = [:] as [Int: Px]
				var front = [pxl] as [PxL]
				while !front.isEmpty {
					front = front.flatMap { pxl in
						pxl.neighbors.compactMap { pxl in
							document.size.index(at: pxl).flatMap { idx in
								if stroke[idx] == .none, document.pxs[idx] == c {
									stroke[idx] = rc
									return pxl
								} else {
									return .none
								}
							}
						}
					}
				}
				setPixels(stroke)
			}
			break
		case .replace:
			if let idx = document.size.index(at: pxl) {
				let c = document.pxs[idx]
				let rc = state.primaryColor
				document.pxs = document.pxs.map { px in px == c ? rc : px }
				texture.load(document.pxs)
			}
		}
	}

	override func mouseDown(with event: NSEvent) {
		let pxl = event.location(in: self).pxl

		if event.modifierFlags.contains(.option) {
			if let idx = document.size.index(at: pxl) {
				state.primaryColor = document.pxs[idx]
			}
		} else {
			undoManager?.beginUndoGrouping()
			stroke = [:]
			draw(at: pxl)
		}
	}

	override func mouseDragged(with event: NSEvent) {
		if state.tool.draggable, stroke != .none {
			draw(at: event.location(in: self).pxl)
		}
	}

	override func mouseUp(with event: NSEvent) {
		if state.tool.draggable {
			draw(at: event.location(in: self).pxl)
		}
		if stroke != .none {
			undoManager?.setActionName(state.tool.actionName)
			undoManager?.endUndoGrouping()
			stroke = .none
		}
	}
}

extension Tool {

	var draggable: Bool {
		switch self {
		case .pencil, .eraser: true
		default: false
		}
	}

	var actionName: String {
		switch self {
		case .pencil: "Draw"
		case .eraser: "Erase"
		case .bucket: "Fill"
		case .replace: "Replace"
		}
	}
}
