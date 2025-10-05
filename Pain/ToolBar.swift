import SwiftUI

struct ToolBar: View {
	var palette: Palette

	var body: some View {
		List {
			ForEach(palette.colors.array.enumerated(), id: \.offset, content: \.element.color)
		}
	}
}
