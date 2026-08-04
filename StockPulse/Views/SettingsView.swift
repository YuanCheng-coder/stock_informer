import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: StockViewModel
    @Environment(\.dismiss) private var dismiss

    private let intervalOptions = [15, 30, 60, 120, 240]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $viewModel.periodicAnalysisEnabled) {
                        Label("定时股价分析", systemImage: "bell.badge")
                    }
                        .onChange(of: viewModel.periodicAnalysisEnabled) { enabled in
                            if enabled {
                                Task { await viewModel.enablePeriodicAnalysis() }
                            } else {
                                viewModel.disablePeriodicAnalysis()
                            }
                        }

                    if viewModel.periodicAnalysisEnabled {
                        Picker("分析间隔", selection: $viewModel.analysisIntervalMinutes) {
                            ForEach(intervalOptions, id: \.self) { minutes in
                                Text(intervalLabel(minutes)).tag(minutes)
                            }
                        }
                    }
                } header: {
                    Text("定时简报")
                } footer: {
                    Text("开启后，会按设定间隔推送股价简报，App 前台时同步刷新。")
                }

                Section("自选股管理") {
                    ForEach(viewModel.watchlist) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.symbol)
                                    .font(.headline)
                                if !item.displayName.isEmpty {
                                    Text(item.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if viewModel.selectedSymbol == item.symbol {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectSymbol(item.symbol)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { viewModel.watchlist[$0] }.forEach(viewModel.removeFromWatchlist)
                    }

                    HStack {
                        TextField("添加代码，如 NVDA", text: $newSymbol)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                        Button("添加") {
                            guard !newSymbol.isEmpty else { return }
                            viewModel.addToWatchlist(symbol: newSymbol)
                            newSymbol = ""
                        }
                        .disabled(newSymbol.isEmpty)
                    }
                }

                Section {
                    Link("在桌面添加小组件", destination: URL(string: "https://support.apple.com/guide/iphone/add-widgets-iphb8f1bf206/ios")!)
                } footer: {
                    Text("长按主屏幕 → 点左上角 + → 搜索 StockPulse，即可添加股价小组件。")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    @State private var newSymbol = ""

    private func intervalLabel(_ minutes: Int) -> String {
        if minutes < 60 { return "每 \(minutes) 分钟" }
        return "每 \(minutes / 60) 小时"
    }
}
