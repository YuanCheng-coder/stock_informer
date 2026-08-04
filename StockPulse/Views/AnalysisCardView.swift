import SwiftUI

struct AnalysisCardView: View {
    let analysis: StockAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("走势分析")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
                Spacer()
                Label(analysis.trend.rawValue, systemImage: trendIcon)
                    .accessibilityLabel("趋势 \(analysis.trend.rawValue)")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(trendColor)
            }

            Text(analysis.summary)
                .font(.callout)
                .lineSpacing(3)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Divider().padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text("投资建议")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                Text(analysis.investmentAdvice)
                    .font(.callout)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
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
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }

            Text("更新于 \(analysis.generatedAt.formatted(date: .omitted, time: .shortened))")
                .accessibilityLabel("分析更新于 \(analysis.generatedAt.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: .black.opacity(AppTheme.cardShadowOpacity), radius: 8, y: 4)
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
