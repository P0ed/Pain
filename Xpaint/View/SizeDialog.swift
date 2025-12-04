import SwiftUI

struct SizeDialog: View {
	var initalWidth: Int
	var initalHeight: Int
	var onConfirm: (Int, Int) -> Void

	@State var width: String = ""
	@State var height: String = ""

	private var w: Int? { width.isEmpty ? initalWidth : Int(width) }
	private var h: Int? { height.isEmpty ? initalHeight : Int(height) }

	private var isValidSize: Bool {
		guard let w, let h else { return false }
		return w > 0 && h > 0 && w * h <= CanvasSize.max.count
	}
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: 16.0) {
			HStack {
				TextField("\(initalWidth)", text: $width)
					.frame(width: 64.0)
					.multilineTextAlignment(.trailing)

				Text("x")

				TextField("\(initalHeight)", text: $height)
					.frame(width: 64.0)
					.multilineTextAlignment(.trailing)
			}
			HStack {
				Button("Cancel") {
					dismiss()
				}
				.keyboardShortcut(.cancelAction)

				Button("Resize") {
					guard let w, let h else { return }
					onConfirm(w, h)
					dismiss()
				}
				.disabled(!isValidSize)
				.keyboardShortcut(.defaultAction)
			}
		}
		.padding(24.0)
	}
}
