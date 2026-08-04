import WidgetKit
import SwiftUI

struct StockPulseEntry: TimelineEntry {
    let date: Date
    let quote: StockQuote?
    let analysis: StockAnalysis?
}

struct StockPulseProvider: TimelineProvider {
    func placeholder(in context: Context) -> StockPulseEntry {
        StockPulseEntry(date: Date(), quote: .placeholder, analysis: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (StockPulseEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StockPulseEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date().addingTimeInterval(900)
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    private func currentEntry() -> StockPulseEntry {
        StockPulseEntry(
            date: Date(),
            quote: SharedSettings.loadQuote(),
            analysis: SharedSettings.loadAnalysis()
        )
    }

    private func fetchEntry() async -> StockPulseEntry {
        let symbol = SharedSettings.primarySymbol
        do {
            let quote = try await StockService.shared.fetchQuote(symbol: symbol)
            let analysis = AnalysisEngine.analyze(quote: quote)
            SharedSettings.saveQuote(quote)
            SharedSettings.saveAnalysis(analysis)
            return StockPulseEntry(date: Date(), quote: quote, analysis: analysis)
        } catch {
            return currentEntry()
        }
    }
}

struct StockPulseWidgetEntryView: View {
    var entry: StockPulseEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.quote?.symbol ?? "StockPulse")
                    .font(.caption.weight(.semibold))
                Spacer()
                if let analysis = entry.analysis {
                    Text(analysis.trend.emoji)
                }
            }

            if let quote = entry.quote, quote.price > 0 {
                Text(formatPrice(quote.price))
                    .font(.title.bold())
                    .monospacedDigit()
                Text("\(quote.isUp ? "+" : "")\(String(format: "%.2f%%", quote.changePercent))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))
            } else {
                Text("点击打开 StockPulse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if let advice = entry.analysis?.investmentAdvice {
                Text(advice)
                    .font(.caption2)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.quote?.symbol ?? "StockPulse")
                    .font(.headline)
                if let quote = entry.quote, quote.price > 0 {
                    Text(formatPrice(quote.price))
                        .font(.title.bold())
                        .monospacedDigit()
                    Text("\(quote.isUp ? "+" : "")\(String(format: "%.2f%%", quote.changePercent))")
                        .foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))
                }
                if let analysis = entry.analysis {
                    Label(analysis.trend.rawValue, systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let quote = entry.quote, !quote.prices.isEmpty {
                MiniChartView(
                    prices: Array(quote.prices.suffix(20)),
                    lineColor: AppTheme.trendColor(isUp: quote.isUp)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.pillRadius))
            }
        }
    }

    private func formatPrice(_ price: Double) -> String {
        String(format: "%.2f", price)
    }
}

struct StockPulseWidget: Widget {
    let kind = "StockPulseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StockPulseProvider()) { entry in
            StockPulseWidgetEntryView(entry: entry)
                .padding(12)
                .background(Color(.secondarySystemBackground))
        }
        .configurationDisplayName("StockPulse")
        .description("桌面随时查看股价走势与投资简报。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct StockPulseWidgetBundle: WidgetBundle {
    var body: some Widget {
        StockPulseWidget()
    }
}
