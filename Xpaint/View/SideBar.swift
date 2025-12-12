import SwiftUI

extension EditorView {

	var sidebar: some View {
		ScrollView(.vertical) {
			VStack(spacing: 0.0) {
				ColorsView(colors: state.colors) { _, _ in
					state.swapColors()
				}
				Toggle("Dither", isOn: $state.dither)
					.keyboardShortcut(KeyEquivalent("d"), modifiers: [])
					.padding(8.0)
				Spacer(minLength: 4.0)
				ColorsView(colors: palette.colors) { _, color in
					state.primaryColor = color
				}
			}
			.padding(.vertical, 12.0)
		}
		.scrollIndicators(.never)
	}
}

struct ColorsView: View {
	var colors: [Px]
	var didTap: (Int, Px) -> Void = ø

	var body: some View {
		ForEach(
			colors.enumerated(),
			id: \.offset,
			content: { idx, color in
				color.ui
					.frame(width: 128.0, height: 24.0)
					.onTapGesture { didTap(idx, color) }
			}
		)
	}
}
