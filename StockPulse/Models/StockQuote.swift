import Foundation

struct StockQuote: Codable, Identifiable, Equatable {
    var id: String { symbol }
    let symbol: String
    let name: String
    let price: Double
    let previousClose: Double
    let change: Double
    let changePercent: Double
    let dayHigh: Double
    let dayLow: Double
    let volume: Int64
    let currency: String
    let prices: [Double]
    let timestamps: [Date]

    var isUp: Bool { change >= 0 }

    static let placeholder = StockQuote(
        symbol: "AAPL",
        name: "Apple Inc.",
        price: 0,
        previousClose: 0,
        change: 0,
        changePercent: 0,
        dayHigh: 0,
        dayLow: 0,
        volume: 0,
        currency: "USD",
        prices: [],
        timestamps: []
    )
}

struct WatchlistItem: Codable, Identifiable, Equatable {
    let id: String
    var symbol: String
    var displayName: String

    init(symbol: String, displayName: String = "") {
        self.id = symbol.uppercased()
        self.symbol = symbol.uppercased()
        self.displayName = displayName
    }
}
