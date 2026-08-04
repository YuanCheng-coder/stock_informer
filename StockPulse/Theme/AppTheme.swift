import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.22, green: 0.48, blue: 0.96)
    static let bullish = Color(red: 0.18, green: 0.78, blue: 0.44)
    static let bearish = Color(red: 0.95, green: 0.32, blue: 0.32)
    static let neutral = Color(red: 0.98, green: 0.62, blue: 0.18)
    static let cardRadius: CGFloat = 20
    static let pillRadius: CGFloat = 14
    static let sectionSpacing: CGFloat = 18
    static let chartHeight: CGFloat = 132
    static let cardShadowOpacity: Double = 0.06
    static let cardShadowOpacity: Double = 0.06

    static func trendColor(isUp: Bool) -> Color {
        isUp ? bullish : bearish
    }
}
