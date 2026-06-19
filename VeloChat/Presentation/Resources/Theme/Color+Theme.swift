import SwiftUI
import UIKit

extension Color {
    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    static let brandPrimary = adaptive(
        light: UIColor(red: 0x16 / 255, green: 0x5D / 255, blue: 0xFF / 255, alpha: 1),
        dark: UIColor(red: 0x23 / 255, green: 0x71 / 255, blue: 0xFF / 255, alpha: 1)
    )

    static let accentHighlight = adaptive(
        light: UIColor(red: 0x00 / 255, green: 0xC4 / 255, blue: 0xFF / 255, alpha: 1),
        dark: UIColor(red: 0x00 / 255, green: 0xD8 / 255, blue: 0xFF / 255, alpha: 1)
    )

    static let bubbleSelf = brandPrimary

    static let bubbleOther = adaptive(
        light: UIColor(red: 0xF2 / 255, green: 0xF3 / 255, blue: 0xF5 / 255, alpha: 1),
        dark: UIColor(red: 0x2A / 255, green: 0x31 / 255, blue: 0x43 / 255, alpha: 1)
    )

    static let systemPillBackground = adaptive(
        light: UIColor(red: 0xE8 / 255, green: 0xEB / 255, blue: 0xF0 / 255, alpha: 1),
        dark: UIColor(red: 0x33 / 255, green: 0x3A / 255, blue: 0x48 / 255, alpha: 1)
    )

    static let unreadBadge = UIColor(red: 0xFF / 255, green: 0x4D / 255, blue: 0x4F / 255, alpha: 1).color

    static let cardBackground = adaptive(
        light: .white,
        dark: UIColor(red: 0x15 / 255, green: 0x1A / 255, blue: 0x26 / 255, alpha: 1)
    )

    static let textPrimary = adaptive(
        light: UIColor(red: 0x1D / 255, green: 0x21 / 255, blue: 0x29 / 255, alpha: 1),
        dark: UIColor(red: 0xF2 / 255, green: 0xF3 / 255, blue: 0xF5 / 255, alpha: 1)
    )

    static let textSecondary = adaptive(
        light: UIColor(red: 0x4E / 255, green: 0x59 / 255, blue: 0x69 / 255, alpha: 1),
        dark: UIColor(red: 0xC9 / 255, green: 0xCD / 255, blue: 0xD4 / 255, alpha: 1)
    )

    static let textTertiary = UIColor(red: 0x86 / 255, green: 0x90 / 255, blue: 0x9C / 255, alpha: 1).color
}

private extension UIColor {
    var color: Color { Color(self) }
}
