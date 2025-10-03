import Cocoa
import SpriteKit
import UniformTypeIdentifiers

extension ViewController {

	func new(_ pxSize: PxSize) {
		let scene = PainScene(size: view.frame.size, pxSize: pxSize)
		skView?.presentScene(scene)
		currentFileURL = nil
	}

	func open(_ url: URL) throws {

		guard
			let data = try? Data(contentsOf: url),
			let rep = NSBitmapImageRep(data: data),
			let cgImage = rep.cgImage
		else {
			throw Err("Failed to open image at path: \(url.path)")
		}

		let width = cgImage.width
		let height = cgImage.height
		let bytesPerRow = width * 4
		var raw = [UInt8](repeating: 0, count: height * bytesPerRow)

		raw.withUnsafeMutableBytes { rawPtr in
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			if let ctx = CGContext(
				data: rawPtr.baseAddress,
				width: width,
				height: height,
				bitsPerComponent: 8,
				bytesPerRow: bytesPerRow,
				space: colorSpace,
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
			) {
				// Draw the image into our RGBA8 buffer.
				ctx.interpolationQuality = .none
				ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
			}
		}

		// Pack bytes into [Color].
		var buffer = [Color](repeating: Color(red: 0, green: 0, blue: 0, alpha: 0), count: width * height)
		var j = 0
		for i in 0..<buffer.count {
			buffer[i] = Color(
				red: raw[j + 0],
				green: raw[j + 1],
				blue: raw[j + 2],
				alpha: raw[j + 3]
			)
			j += 4
		}

		let pxSize = PxSize(width: width, height: height)
		let scene = PainScene(size: view.frame.size, pxSize: pxSize, data: buffer)
		skView?.presentScene(scene)

		currentFileURL = url
		NSDocumentController.shared.noteNewRecentDocumentURL(url)
	}

	func save(_ url: URL) throws {

		guard let scene = skView?.scene as? PainScene else {
			throw Err("No PainScene to save.")
		}

		let cgImage = try scene.exportCGImage()
		let rep = NSBitmapImageRep(cgImage: cgImage)

		guard let pngData = rep.representation(using: .png, properties: [:]) else {
			print("Failed to create PNG representation.")
			return
		}

		do {
			try pngData.write(to: url, options: .atomic)
			currentFileURL = url
			NSDocumentController.shared.noteNewRecentDocumentURL(url)
		} catch {
			print("Failed to write PNG to \(url.path): \(error)")
		}
	}

	@objc func newDocument(_ sender: Any?) {
		new(PxSize(width: 32, height: 32))
	}

	@objc func openDocument(_ sender: Any?) {
		let panel = NSOpenPanel()
		panel.allowedContentTypes = [.png]
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canCreateDirectories = false
		panel.title = "Open Image"
		panel.prompt = "Open"

		if let window = view.window {
			panel.beginSheetModal(for: window) { [weak self] response in
				guard response == .OK, let url = panel.url else { return }
				try? self?.open(url)
			}
		} else {
			let response = panel.runModal()
			guard response == .OK, let url = panel.url else { return }
			try? open(url)
		}
	}

	@objc func saveDocument(_ sender: Any?) {
		if let url = currentFileURL {
			try? save(url)
		} else {
			saveDocumentAs(sender)
		}
	}

	@objc func saveDocumentAs(_ sender: Any?) {
		let panel = NSSavePanel()
		panel.allowedContentTypes = [.png]
		panel.canCreateDirectories = true
		panel.title = "Save Image"
		panel.prompt = "Save"
		panel.nameFieldStringValue = currentFileURL?.lastPathComponent ?? "Image.png"
		panel.isExtensionHidden = false

		let completeWithURL: (URL) -> Void = { [weak self] url in
			var finalURL = url
			if finalURL.pathExtension.lowercased() != "png" {
				finalURL.deletePathExtension()
				finalURL.appendPathExtension("png")
			}
			try? self?.save(finalURL)
		}

		if let window = view.window {
			panel.beginSheetModal(for: window) { response in
				guard response == .OK, let url = panel.url else { return }
				completeWithURL(url)
			}
		} else {
			let response = panel.runModal()
			guard response == .OK, let url = panel.url else { return }
			completeWithURL(url)
		}
	}
}
