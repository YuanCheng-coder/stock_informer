import Foundation

enum StockServiceError: LocalizedError {
    case invalidSymbol
    case networkError
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidSymbol: return "股票代码无效"
        case .networkError: return "网络请求失败，请检查网络"
        case .parseError: return "数据解析失败"
        }
    }
}

final class StockService {
    static let shared = StockService()
    private init() {}

    func fetchQuote(symbol: String) async throws -> StockQuote {
        let trimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { throw StockServiceError.invalidSymbol }

        let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? trimmed
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(encoded)?interval=1d&range=3mo"
        guard let url = URL(string: urlString) else { throw StockServiceError.invalidSymbol }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw StockServiceError.networkError
        }

        return try parseYahooResponse(data: data, symbol: trimmed)
    }

    private func parseYahooResponse(data: Data, symbol: String) throws -> StockQuote {
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let chart = json["chart"] as? [String: Any],
            let results = chart["result"] as? [[String: Any]],
            let first = results.first,
            let meta = first["meta"] as? [String: Any]
        else {
            throw StockServiceError.parseError
        }

        let price = meta["regularMarketPrice"] as? Double ?? 0
        let previousClose = meta["previousClose"] as? Double ?? meta["chartPreviousClose"] as? Double ?? price
        let change = price - previousClose
        let changePercent = previousClose != 0 ? (change / previousClose) * 100 : 0
        let dayHigh = meta["regularMarketDayHigh"] as? Double ?? price
        let dayLow = meta["regularMarketDayLow"] as? Double ?? price
        let volume = meta["regularMarketVolume"] as? Int64 ?? 0
        let currency = meta["currency"] as? String ?? "USD"
        let name = meta["longName"] as? String ?? meta["shortName"] as? String ?? symbol

        var prices: [Double] = []
        var timestamps: [Date] = []

        if
            let indicators = first["indicators"] as? [String: Any],
            let quoteList = indicators["quote"] as? [[String: Any]],
            let quote = quoteList.first,
            let closePrices = quote["close"] as? [Double?],
            let ts = first["timestamp"] as? [Int]
        {
            for (index, value) in closePrices.enumerated() {
                guard let value, index < ts.count else { continue }
                prices.append(value)
                timestamps.append(Date(timeIntervalSince1970: TimeInterval(ts[index])))
            }
        }

        return StockQuote(
            symbol: symbol,
            name: name,
            price: price,
            previousClose: previousClose,
            change: change,
            changePercent: changePercent,
            dayHigh: dayHigh,
            dayLow: dayLow,
            volume: volume,
            currency: currency,
            prices: prices,
            timestamps: timestamps
        )
    }
}
