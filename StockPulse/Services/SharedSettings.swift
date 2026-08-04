import Foundation

enum SharedSettings {
    static let appGroupID = "group.com.stockpulse.shared"

    enum Keys {
        static let periodicAnalysisEnabled = "periodicAnalysisEnabled"
        static let analysisIntervalMinutes = "analysisIntervalMinutes"
        static let watchlist = "watchlist"
        static let primarySymbol = "primarySymbol"
        static let lastQuote = "lastQuote"
        static let lastAnalysis = "lastAnalysis"
    }

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static var periodicAnalysisEnabled: Bool {
        get { defaults?.bool(forKey: Keys.periodicAnalysisEnabled) ?? false }
        set { defaults?.set(newValue, forKey: Keys.periodicAnalysisEnabled) }
    }

    static var analysisIntervalMinutes: Int {
        get {
            let value = defaults?.integer(forKey: Keys.analysisIntervalMinutes) ?? 0
            return value > 0 ? value : 60
        }
        set { defaults?.set(newValue, forKey: Keys.analysisIntervalMinutes) }
    }

    static var primarySymbol: String {
        get { defaults?.string(forKey: Keys.primarySymbol) ?? "AAPL" }
        set { defaults?.set(newValue.uppercased(), forKey: Keys.primarySymbol) }
    }

    static func saveWatchlist(_ items: [WatchlistItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults?.set(data, forKey: Keys.watchlist)
    }

    static func loadWatchlist() -> [WatchlistItem] {
        guard
            let data = defaults?.data(forKey: Keys.watchlist),
            let items = try? JSONDecoder().decode([WatchlistItem].self, from: data)
        else {
            return [
                WatchlistItem(symbol: "AAPL", displayName: "苹果"),
                WatchlistItem(symbol: "TSLA", displayName: "特斯拉"),
                WatchlistItem(symbol: "600519.SS", displayName: "贵州茅台")
            ]
        }
        return items
    }

    static func saveQuote(_ quote: StockQuote) {
        guard let data = try? JSONEncoder().encode(quote) else { return }
        defaults?.set(data, forKey: Keys.lastQuote)
    }

    static func loadQuote() -> StockQuote? {
        guard
            let data = defaults?.data(forKey: Keys.lastQuote),
            let quote = try? JSONDecoder().decode(StockQuote.self, from: data)
        else { return nil }
        return quote
    }

    static func saveAnalysis(_ analysis: StockAnalysis) {
        guard let data = try? JSONEncoder().encode(analysis) else { return }
        defaults?.set(data, forKey: Keys.lastAnalysis)
    }

    static func loadAnalysis() -> StockAnalysis? {
        guard
            let data = defaults?.data(forKey: Keys.lastAnalysis),
            let analysis = try? JSONDecoder().decode(StockAnalysis.self, from: data)
        else { return nil }
        return analysis
    }
}
