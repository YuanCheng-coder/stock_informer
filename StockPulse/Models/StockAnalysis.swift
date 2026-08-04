import Foundation

enum TrendDirection: String, Codable {
    case bullish = "看涨"
    case bearish = "看跌"
    case neutral = "震荡"

    var emoji: String {
        switch self {
        case .bullish: return "📈"
        case .bearish: return "📉"
        case .neutral: return "➡️"
        }
    }
}

struct StockAnalysis: Codable, Equatable {
    let symbol: String
    let trend: TrendDirection
    let summary: String
    let investmentAdvice: String
    let supportLevel: Double?
    let resistanceLevel: Double?
    let generatedAt: Date

    var briefNotificationText: String {
        "\(symbol) \(trend.emoji) \(trend.rawValue)\n\(investmentAdvice)"
    }
}
