import SwiftUI

extension EditorView {

	var sidebar: some View {
		ScrollView(.vertical) {
			VStack(spacing: 0.0) {
				ColorsView(colors: state.colors)
				Toggle("Dither", isOn: $state.dither)
					.keyboardShortcut(KeyEquivalent("d"), modifiers: [])
					.padding(8.0)
				Spacer(minLength: 4.0)
				ColorsView(colors: palette.colors) { color in
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
	var didTap: (Px) -> Void = ø

	var body: some View {
		ForEach(
			colors.enumerated(),
			id: \.offset,
			content: { _, color in
				color.ui
					.frame(width: 128.0, height: 24.0)
					.onTapGesture { didTap(color) }
			}
		)
	}
}
