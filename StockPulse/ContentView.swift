import SwiftUI

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
                        .frame(height: 120)
                        .padding(.horizontal)
                    }
                    if let analysis = viewModel.analysis {
                        AnalysisCardView(analysis: analysis)
                            .padding(.horizontal)
                    } else if !viewModel.isLoading {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
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
            TextField("股票代码 AAPL / 600519.SS", text: $searchSymbol)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .onSubmit { submitSearch() }

            Button("分析") { submitSearch() }
                .buttonStyle(.borderedProminent)
                .disabled(searchSymbol.isEmpty && viewModel.selectedSymbol.isEmpty)
        }
        .padding(.horizontal)
        .onAppear {
            searchSymbol = viewModel.selectedSymbol
        }
    }

    private func submitSearch() {
        let symbol = searchSymbol.isEmpty ? viewModel.selectedSymbol : searchSymbol
        viewModel.selectSymbol(symbol)
    }

    private func quoteHeader(_ quote: StockQuote) -> some View {
        VStack(spacing: 8) {
            Text(quote.name)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(formatPrice(quote.price))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 8) {
                Image(systemName: quote.isUp ? "arrow.up.right" : "arrow.down.right")
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
            Text("快捷自选")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.watchlist) { item in
                        Button {
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
                                    ? Color.blue.opacity(0.15)
                                    : Color.gray.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 12)
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
