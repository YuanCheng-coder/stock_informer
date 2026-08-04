import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = StockViewModel()
    @State private var showSettings = false
    @State private var searchSymbol = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {
                    searchSection
                    if let quote = viewModel.quote {
                        quoteHeader(quote)
                        MiniChartView(
                            prices: quote.prices,
                            lineColor: AppTheme.trendColor(isUp: quote.isUp)
                        )
                        .frame(height: AppTheme.chartHeight)
                        .padding(8)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.pillRadius))
                        .padding(.horizontal)
                    }
                    if let analysis = viewModel.analysis {
                        AnalysisCardView(analysis: analysis)
                            .padding(.horizontal)
                            .accessibilityElement(children: .combine)
                    } else if !viewModel.isLoading {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.largeTitle)
                                .foregroundStyle(AppTheme.accent.opacity(0.55))
                            Text("暂无分析")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("输入股票代码并刷新，即可查看走势分析")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        .padding(.horizontal)
                        .accessibilityElement(children: .combine)
                    }
                    watchlistSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("StockPulse")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .accessibilityLabel("设置")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { lightHaptic(); await viewModel.refresh() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(AppTheme.accent)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .accessibilityLabel("刷新")
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .alert("提示", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("知道了") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                if viewModel.quote == nil {
                    await viewModel.refresh()
                }
            }
        }
    }

    private var searchSection: some View {
        HStack(spacing: 10) {
            TextField("输入代码，如 AAPL、600519.SS", text: $searchSymbol)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .accessibilityHint("输入股票代码后点分析或回车")
                .onSubmit { submitSearch() }

            Button { submitSearch() } label: {
                Label("分析", systemImage: "chart.line.uptrend.xyaxis")
            }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(searchSymbol.isEmpty && viewModel.selectedSymbol.isEmpty)
        }
        .padding(.horizontal, 16)
        .onAppear {
            searchSymbol = viewModel.selectedSymbol
        }
    }

    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func submitSearch() {
        lightHaptic()
        let symbol = searchSymbol.isEmpty ? viewModel.selectedSymbol : searchSymbol
        viewModel.selectSymbol(symbol)
    }

    private func quoteHeader(_ quote: StockQuote) -> some View {
        VStack(spacing: 10) {
            Text(quote.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(formatPrice(quote.price))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .accessibilityLabel("当前价格 \(formatPrice(quote.price))")

            HStack(spacing: 6) {
                Image(systemName: quote.isUp ? "arrow.up.right" : "arrow.down.right")
                    .accessibilityHidden(true)
                Text("\(quote.isUp ? "+" : "")\(String(format: "%.2f", quote.change))")
                Text("(\(quote.isUp ? "+" : "")\(String(format: "%.2f%%", quote.changePercent)))")
            }
            .font(.headline)
            .foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))

            HStack(spacing: 24) {
                labelValue("最高", formatPrice(quote.dayHigh))
                labelValue("最低", formatPrice(quote.dayLow))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var watchlistSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("快捷自选", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.watchlist) { item in
                        Button {
                            lightHaptic()
                            searchSymbol = item.symbol
                            viewModel.selectSymbol(item.symbol)
                        } label: {
                            VStack(spacing: 4) {
                                Text(item.symbol)
                                    .font(.subheadline.weight(.semibold))
                                if !item.displayName.isEmpty {
                                    Text(item.displayName)
                                        .font(.caption2)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.selectedSymbol == item.symbol
                                    ? AppTheme.accent.opacity(0.18)
                                    : Color(.tertiarySystemFill),
                                in: RoundedRectangle(cornerRadius: AppTheme.pillRadius)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(item.displayName.isEmpty ? item.symbol : item.displayName)")
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func labelValue(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
            Text(value).monospacedDigit()
        }
    }

    private func formatPrice(_ price: Double) -> String {
        String(format: "%.2f", price)
    }
}
