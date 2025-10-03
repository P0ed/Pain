import Cocoa
import SpriteKit

final class ViewController: NSViewController {

	private var skView: SKView? { view as? SKView }

    override func viewDidLoad() {
        super.viewDidLoad()

		skView?.ignoresSiblingOrder = true
		skView?.showsFPS = true
		new(CanvasSize(width: 32, height: 32))
    }

	override func viewDidLayout() {
		super.viewDidLayout()
		(view as? SKView)?.scene?.size = view.frame.size
	}

	func new(_ canvasSize: CanvasSize) {
		let scene = PainScene(size: view.frame.size, canvasSize: canvasSize)
		skView?.presentScene(scene)
	}

	func open(_ file: String) {

	}

	func save(_ file: String) {

	}
}
