import Foundation
import UserNotifications

final class NotificationScheduler {
    static let shared = NotificationScheduler()
    private let center = UNUserNotificationCenter.current()
    private let identifier = "com.stockpulse.periodic"

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func schedulePeriodicAnalysis(for symbol: String, intervalMinutes: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard SharedSettings.periodicAnalysisEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "StockPulse 股价简报"
        content.subtitle = symbol
        content.body = "正在更新分析，请打开 App 查看最新走势与建议。"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(max(intervalMinutes, 15) * 60),
            repeats: true
        )

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelPeriodicAnalysis() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func deliverImmediateAnalysis(quote: StockQuote, analysis: StockAnalysis) async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(quote.symbol) \(formatPrice(quote.price))"
        content.subtitle = "\(analysis.trend.emoji) \(analysis.trend.rawValue) · \(quote.isUp ? "+" : "")\(String(format: "%.2f%%", quote.changePercent))"
        content.body = analysis.investmentAdvice
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(identifier).immediate.\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }

    private func formatPrice(_ price: Double) -> String {
        String(format: "%.2f", price)
    }
}
