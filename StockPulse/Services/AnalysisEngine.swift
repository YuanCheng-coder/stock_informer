import Foundation

enum AnalysisEngine {
    static func analyze(quote: StockQuote) -> StockAnalysis {
        let prices = quote.prices.filter { $0 > 0 }
        let trend = detectTrend(prices: prices, quote: quote)
        let summary = buildSummary(quote: quote, prices: prices, trend: trend)
        let advice = buildAdvice(quote: quote, prices: prices, trend: trend)
        let (support, resistance) = supportResistance(prices: prices)

        return StockAnalysis(
            symbol: quote.symbol,
            trend: trend,
            summary: summary,
            investmentAdvice: advice,
            supportLevel: support,
            resistanceLevel: resistance,
            generatedAt: Date()
        )
    }

    private static func detectTrend(prices: [Double], quote: StockQuote) -> TrendDirection {
        guard prices.count >= 5 else {
            if quote.changePercent > 1 { return .bullish }
            if quote.changePercent < -1 { return .bearish }
            return .neutral
        }

        let sma5 = average(prices.suffix(5))
        let sma20 = average(prices.suffix(min(20, prices.count)))
        let momentum = quote.changePercent

        if sma5 > sma20 && momentum > 0.5 { return .bullish }
        if sma5 < sma20 && momentum < -0.5 { return .bearish }
        return .neutral
    }

    private static func buildSummary(quote: StockQuote, prices: [Double], trend: TrendDirection) -> String {
        let direction = quote.isUp ? "上涨" : "下跌"
        let changeText = String(format: "%.2f%%", abs(quote.changePercent))

        var parts: [String] = [
            "\(quote.name) 现价 \(formatPrice(quote.price, currency: quote.currency))，今日\(direction) \(changeText)。"
        ]

        if prices.count >= 10 {
            let recentHigh = prices.suffix(10).max() ?? quote.price
            let recentLow = prices.suffix(10).min() ?? quote.price
            let rangePercent = recentLow > 0 ? ((recentHigh - recentLow) / recentLow) * 100 : 0
            parts.append(String(format: "近10日振幅 %.1f%%，走势偏\(trend.rawValue)。", rangePercent))
        } else {
            parts.append("走势偏\(trend.rawValue)。")
        }

        return parts.joined()
    }

    private static func buildAdvice(quote: StockQuote, prices: [Double], trend: TrendDirection) -> String {
        switch trend {
        case .bullish:
            if quote.changePercent > 3 {
                return "短线涨幅较大，不宜追高，可等回调再考虑。"
            }
            return "趋势向上，可轻仓关注，设好止损。"
        case .bearish:
            if quote.changePercent < -3 {
                return "跌幅较深，勿盲目抄底，等企稳信号。"
            }
            return "趋势偏弱，观望为主，控制仓位。"
        case .neutral:
            if let support = prices.suffix(20).min(), quote.price <= support * 1.02 {
                return "接近近期支撑，可小仓位试探，严格止损。"
            }
            return "横盘震荡，耐心等待方向明朗。"
        }
    }

    private static func supportResistance(prices: [Double]) -> (Double?, Double?) {
        guard prices.count >= 5 else { return (nil, nil) }
        let recent = Array(prices.suffix(20))
        return (recent.min(), recent.max())
    }

    private static func average(_ values: ArraySlice<Double>) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func formatPrice(_ price: Double, currency: String) -> String {
        switch currency {
        case "CNY", "HKD":
            return String(format: "%.2f", price)
        default:
            return String(format: "%.2f", price)
        }
    }
}
