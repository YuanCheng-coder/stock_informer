import Foundation
import SwiftUI

@MainActor
final class StockViewModel: ObservableObject {
    @Published var quote: StockQuote?
    @Published var analysis: StockAnalysis?
    @Published var watchlist: [WatchlistItem] = []
    @Published var selectedSymbol: String = SharedSettings.primarySymbol
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var periodicAnalysisEnabled: Bool = SharedSettings.periodicAnalysisEnabled {
        didSet {
            SharedSettings.periodicAnalysisEnabled = periodicAnalysisEnabled
            updatePeriodicSchedule()
        }
    }
    @Published var analysisIntervalMinutes: Int = SharedSettings.analysisIntervalMinutes {
        didSet {
            SharedSettings.analysisIntervalMinutes = analysisIntervalMinutes
            updatePeriodicSchedule()
        }
    }

    private var periodicTask: Task<Void, Never>?

    init() {
        watchlist = SharedSettings.loadWatchlist()
        quote = SharedSettings.loadQuote()
        analysis = SharedSettings.loadAnalysis()
        if periodicAnalysisEnabled {
            startPeriodicAnalysisLoop()
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await StockService.shared.fetchQuote(symbol: selectedSymbol)
            let resultAnalysis = AnalysisEngine.analyze(quote: result)

            quote = result
            analysis = resultAnalysis
            SharedSettings.primarySymbol = selectedSymbol
            SharedSettings.saveQuote(result)
            SharedSettings.saveAnalysis(resultAnalysis)

            if periodicAnalysisEnabled {
                await NotificationScheduler.shared.deliverImmediateAnalysis(
                    quote: result,
                    analysis: resultAnalysis
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectSymbol(_ symbol: String) {
        selectedSymbol = symbol.uppercased()
        Task { await refresh() }
    }

    func addToWatchlist(symbol: String, name: String = "") {
        let item = WatchlistItem(symbol: symbol, displayName: name)
        guard !watchlist.contains(where: { $0.symbol == item.symbol }) else { return }
        watchlist.append(item)
        SharedSettings.saveWatchlist(watchlist)
    }

    func removeFromWatchlist(_ item: WatchlistItem) {
        watchlist.removeAll { $0.id == item.id }
        SharedSettings.saveWatchlist(watchlist)
    }

    func enablePeriodicAnalysis() async {
        let granted = await NotificationScheduler.shared.requestPermission()
        guard granted else {
            periodicAnalysisEnabled = false
            errorMessage = "请在系统设置中允许通知，才能开启定时分析。"
            return
        }
        updatePeriodicSchedule()
        startPeriodicAnalysisLoop()
    }

    func disablePeriodicAnalysis() {
        periodicTask?.cancel()
        periodicTask = nil
        NotificationScheduler.shared.cancelPeriodicAnalysis()
    }

    private func updatePeriodicSchedule() {
        if periodicAnalysisEnabled {
            NotificationScheduler.shared.schedulePeriodicAnalysis(
                for: selectedSymbol,
                intervalMinutes: analysisIntervalMinutes
            )
            startPeriodicAnalysisLoop()
        } else {
            disablePeriodicAnalysis()
        }
    }

    private func startPeriodicAnalysisLoop() {
        periodicTask?.cancel()
        periodicTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(analysisIntervalMinutes) * 60 * 1_000_000_000)
                guard !Task.isCancelled, periodicAnalysisEnabled else { break }
                await refresh()
            }
        }
    }
}
