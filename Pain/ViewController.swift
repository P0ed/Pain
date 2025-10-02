import Cocoa
import SpriteKit

final class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		guard let view = view as? SKView else { return }
		let scene = PainScene(size: view.frame.size)
		scene.scaleMode = .aspectFill
		view.presentScene(scene)
		view.ignoresSiblingOrder = true
		view.showsFPS = true
    }

	override func viewDidLayout() {
		super.viewDidLayout()
		(view as? SKView)?.scene?.size = view.frame.size
	}
}
