import SwiftUI

extension Px {

	var color: Color {
		Color(
			.displayP3,
			red: Double(red) / 255.0,
			green: Double(green) / 255.0,
			blue: Double(blue) / 255.0,
			opacity: Double(alpha) / 255.0
		)
	}
}
