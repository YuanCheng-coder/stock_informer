import SwiftUI

struct AnalysisCardView: View {
    let analysis: StockAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("走势分析")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
                Spacer()
                Label(analysis.trend.rawValue, systemImage: trendIcon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(trendColor)
            }

            Text(analysis.summary)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("投资建议")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(analysis.investmentAdvice)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if analysis.supportLevel != nil || analysis.resistanceLevel != nil {
                HStack(spacing: 16) {
                    if let support = analysis.supportLevel {
                        metric(title: "支撑", value: support)
                    }
                    if let resistance = analysis.resistanceLevel {
                        metric(title: "阻力", value: resistance)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Text("更新于 \(analysis.generatedAt.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))
    }

    private var trendColor: Color {
        switch analysis.trend {
        case .bullish: return AppTheme.bullish
        case .bearish: return AppTheme.bearish
        case .neutral: return AppTheme.neutral
        }
    }

    private var trendIcon: String {
        switch analysis.trend {
        case .bullish: return "arrow.up.right"
        case .bearish: return "arrow.down.right"
        case .neutral: return "arrow.left.and.right"
        }
    }

    private func metric(title: String, value: Double) -> some View {
        HStack(spacing: 4) {
            Text("\(title):")
            Text(String(format: "%.2f", value))
                .monospacedDigit()
        }
    }
}
