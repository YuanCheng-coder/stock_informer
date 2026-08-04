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
                        .frame(height: 132)
                        .padding(8)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.pillRadius))
                        .padding(.horizontal)
                    }
                    if let analysis = viewModel.analysis {
                        AnalysisCardView(analysis: analysis)
                            .padding(.horizontal)
                    } else if !viewModel.isLoading {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.largeTitle)
                                .foregroundStyle(AppTheme.accent.opacity(0.55))
                            Text("暂无分析")
                                .font(.headline)
                            Text("输入股票代码并刷新，即可查看走势分析")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        .padding(.horizontal)
                    }
                    watchlistSection
                }
                .padding(.vertical)
            }
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
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .alert("提示", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("好的") { viewModel.errorMessage = nil }
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
        HStack(spacing: 12) {
            TextField("输入代码，如 AAPL、600519.SS", text: $searchSymbol)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .onSubmit { submitSearch() }

            Button("分析") { submitSearch() }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(searchSymbol.isEmpty && viewModel.selectedSymbol.isEmpty)
        }
        .padding(.horizontal)
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
        VStack(spacing: 8) {
            Text(quote.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(formatPrice(quote.price))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .accessibilityLabel("当前价格 \(formatPrice(quote.price))")

            HStack(spacing: 8) {
                Image(systemName: quote.isUp ? "arrow.up.right" : "arrow.down.right")
                    .accessibilityHidden(true)
                Text("\(quote.isUp ? "+" : "")\(String(format: "%.2f", quote.change))")
                Text("(\(quote.isUp ? "+" : "")\(String(format: "%.2f%%", quote.changePercent)))")
            }
            .font(.headline)
            .foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))

            HStack(spacing: 20) {
                labelValue("最高", formatPrice(quote.dayHigh))
                labelValue("最低", formatPrice(quote.dayLow))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var watchlistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("快捷自选", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
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
                                    : Color.gray.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: AppTheme.pillRadius)
                            )
                        }
                        .buttonStyle(.plain)
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
