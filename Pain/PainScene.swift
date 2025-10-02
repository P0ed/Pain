import SpriteKit

final class PainScene: SKScene {

	let sprite = SKSpriteNode()
	let texture = SKTexture()

	

	override func sceneDidLoad() {

	}

	func touchDown(at pos: CGPoint) {

	}

	func touchMoved(to pos: CGPoint) {

	}

	func touchUp(at pos: CGPoint) {

	}

	override func mouseDown(with event: NSEvent) {
		self.touchDown(at: event.location(in: self))
	}

	override func mouseDragged(with event: NSEvent) {
		self.touchMoved(to: event.location(in: self))
	}

	override func mouseUp(with event: NSEvent) {
		self.touchUp(at: event.location(in: self))
	}

	override func keyDown(with event: NSEvent) {
		switch event.keyCode {
		default:
			print("keyDown: \(event.characters ?? "") keyCode: \(event.keyCode)")
		}
	}
}
