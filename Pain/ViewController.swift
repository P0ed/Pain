import Cocoa
import SpriteKit

final class ViewController: NSViewController {
	var skView: SKView? { view as? SKView }
	var currentFileURL: URL?

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
}
