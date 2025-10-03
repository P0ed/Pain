import Cocoa
import SpriteKit

final class ViewController: NSViewController {

	private var skView: SKView? { view as? SKView }

    override func viewDidLoad() {
        super.viewDidLoad()

		skView?.ignoresSiblingOrder = true
		skView?.showsFPS = true
		new(PxSize(width: 32, height: 32))
    }

	override func viewDidLayout() {
		super.viewDidLayout()
		(view as? SKView)?.scene?.size = view.frame.size
	}

	func new(_ pxSize: PxSize) {
		let scene = PainScene(size: view.frame.size, pxSize: pxSize)
		skView?.presentScene(scene)
	}

	func open(_ file: String) {

	}

	func save(_ file: String) {

	}
}
