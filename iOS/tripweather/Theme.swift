import SwiftUI

/// overcast sky navy with a sunbreak sky-blue accent
enum Theme {
    static let background = Color(red: 0.051, green: 0.106, blue: 0.165)
    static let accent = Color(red: 0.365, green: 0.757, blue: 0.914)
    static let ink = Color(red: 0.933, green: 0.965, blue: 0.984)
    static let cardBackground = Color(red: 0.122, green: 0.176, blue: 0.235)
    static let secondaryInk = Color(red: 0.776, green: 0.808, blue: 0.827)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 18
}

extension View {
    func themedBackground() -> some View {
        self.background(Theme.background.ignoresSafeArea())
    }
}
