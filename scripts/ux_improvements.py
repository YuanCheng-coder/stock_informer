# UX/UI improvements for auto-iterate iterations 3–100.
# Each tuple: (num, msg, path, old, new)
# Patches are sequential — each `old` matches state after prior iterations.

UX_IMPROVEMENTS = [
    # ── AppTheme adoption (3–12) ──
    (3, 'ContentView: VStack spacing → AppTheme.sectionSpacing',
     'StockPulse/ContentView.swift',
     'VStack(spacing: 20) {',
     'VStack(spacing: AppTheme.sectionSpacing) {'),

    (4, 'ContentView: chart lineColor → AppTheme.trendColor',
     'StockPulse/ContentView.swift',
     'lineColor: quote.isUp ? .green : .red',
     'lineColor: AppTheme.trendColor(isUp: quote.isUp)'),

    (5, 'ContentView: quote header colors → AppTheme.trendColor',
     'StockPulse/ContentView.swift',
     '.foregroundStyle(quote.isUp ? .green : .red)',
     '.foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))'),

    (6, 'AnalysisCardView: card radius → AppTheme.cardRadius',
     'StockPulse/Views/AnalysisCardView.swift',
     'RoundedRectangle(cornerRadius: 16)',
     'RoundedRectangle(cornerRadius: AppTheme.cardRadius)'),

    (7, 'AnalysisCardView: trend colors → AppTheme palette',
     'StockPulse/Views/AnalysisCardView.swift',
     '        case .bullish: return .green\n        case .bearish: return .red\n        case .neutral: return .orange',
     '        case .bullish: return AppTheme.bullish\n        case .bearish: return AppTheme.bearish\n        case .neutral: return AppTheme.neutral'),

    (8, 'MiniChartView: line width + round cap',
     'StockPulse/Views/MiniChartView.swift',
     'lineWidth: 2, lineJoin: .round',
     'lineWidth: 2.5, lineJoin: .round, lineCap: .round'),

    (9, 'ContentView: watchlist selected tint → AppTheme.accent',
     'StockPulse/ContentView.swift',
     '? Color.blue.opacity(0.15)',
     '? AppTheme.accent.opacity(0.18)'),

    (10, 'ContentView: watchlist pill radius → AppTheme.pillRadius',
     'StockPulse/ContentView.swift',
     'in: RoundedRectangle(cornerRadius: 12)',
     'in: RoundedRectangle(cornerRadius: AppTheme.pillRadius)'),

    (11, 'ContentView: 分析按钮 tint → AppTheme.accent',
     'StockPulse/ContentView.swift',
     '.buttonStyle(.borderedProminent)\n                .disabled(searchSymbol.isEmpty',
     '.buttonStyle(.borderedProminent)\n                .tint(AppTheme.accent)\n                .disabled(searchSymbol.isEmpty'),

    (12, 'AnalysisCardView: 走势分析标题 accent 色',
     'StockPulse/Views/AnalysisCardView.swift',
     'Text("走势分析")\n                    .font(.headline)',
     'Text("走势分析")\n                    .font(.headline)\n                    .foregroundStyle(AppTheme.accent)'),

    # ── Cards & layout (13–22) ──
    (13, 'AnalysisCardView: 内边距 16pt',
     'StockPulse/Views/AnalysisCardView.swift',
     '.padding()\n        .background(.ultraThinMaterial',
     '.padding(16)\n        .background(.ultraThinMaterial'),

    (14, 'AnalysisCardView: 卡片阴影',
     'StockPulse/Views/AnalysisCardView.swift',
     '.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))',
     '.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))\n        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)'),

    (15, 'ContentView: 图表高度 120 → 132',
     'StockPulse/ContentView.swift',
     '.frame(height: 120)',
     '.frame(height: 132)'),

    (16, 'ContentView: 大标题导航栏',
     'StockPulse/ContentView.swift',
     '.navigationTitle("StockPulse")',
     '.navigationTitle("StockPulse")\n            .navigationBarTitleDisplayMode(.large)'),

    (17, 'ContentView: 空态图标 accent 色',
     'StockPulse/ContentView.swift',
     'Image(systemName: "chart.line.uptrend.xyaxis")\n                                .font(.largeTitle)\n                                .foregroundStyle(.secondary)',
     'Image(systemName: "chart.line.uptrend.xyaxis")\n                                .font(.largeTitle)\n                                .foregroundStyle(AppTheme.accent.opacity(0.55))'),

    (18, 'ContentView: 快捷自选 → Label 图标',
     'StockPulse/ContentView.swift',
     'Text("快捷自选")\n                .font(.headline)',
     'Label("快捷自选", systemImage: "star.fill")\n                .font(.headline)\n                .foregroundStyle(AppTheme.accent)'),

    (19, 'AnalysisCardView: 摘要 callout 字体',
     'StockPulse/Views/AnalysisCardView.swift',
     'Text(analysis.summary)\n                .font(.body)',
     'Text(analysis.summary)\n                .font(.callout)\n                .lineSpacing(3)'),

    (20, 'AnalysisCardView: 投资建议区块背景',
     'StockPulse/Views/AnalysisCardView.swift',
     'Text(analysis.investmentAdvice)\n                    .font(.body)',
     'Text(analysis.investmentAdvice)\n                    .font(.callout)\n                    .padding(10)\n                    .frame(maxWidth: .infinity, alignment: .leading)\n                    .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))'),

    (21, 'AnalysisCardView: 支撑阻力 medium 字重',
     'StockPulse/Views/AnalysisCardView.swift',
     '.font(.caption)\n                .foregroundStyle(.secondary)',
     '.font(.caption.weight(.medium))\n                .foregroundStyle(.secondary)'),

    (22, 'ContentView: 搜索框 placeholder 优化',
     'StockPulse/ContentView.swift',
     'TextField("股票代码 AAPL / 600519.SS", text: $searchSymbol)',
     'TextField("输入代码，如 AAPL、600519.SS", text: $searchSymbol)'),

    # ── Charts (23–30) ──
    (23, 'MiniChartView: drawingGroup 渲染优化',
     'StockPulse/Views/MiniChartView.swift',
     '.stroke(lineColor, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round, lineCap: .round))',
     '.stroke(lineColor, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round, lineCap: .round))\n                .drawingGroup()'),

    (24, 'ContentView: 图表卡片背景 (dark mode)',
     'StockPulse/ContentView.swift',
     '.frame(height: 132)\n                        .padding(.horizontal)',
     '.frame(height: 132)\n                        .padding(8)\n                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.pillRadius))\n                        .padding(.horizontal)'),

    (25, 'MiniChartView: 空态 accessibility',
     'StockPulse/Views/MiniChartView.swift',
     'Text("暂无走势数据")\n                    .font(.caption2)',
     'Text("暂无走势数据")\n                    .font(.caption2)\n                    .accessibilityLabel("暂无走势数据")'),

    (26, 'MiniChartView: 线宽增至 3',
     'StockPulse/Views/MiniChartView.swift',
     'lineWidth: 2.5, lineJoin: .round, lineCap: .round',
     'lineWidth: 3, lineJoin: .round, lineCap: .round'),

    (27, 'ContentView: 价格字体 42 → 44',
     'StockPulse/ContentView.swift',
     '.font(.system(size: 42, weight: .bold, design: .rounded))',
     '.font(.system(size: 44, weight: .bold, design: .rounded))'),

    (28, 'ContentView: 股票名称 title2',
     'StockPulse/ContentView.swift',
     '.font(.title3.weight(.semibold))',
     '.font(.title2.weight(.semibold))'),

    (29, 'ContentView: 涨跌箭头 accessibility',
     'StockPulse/ContentView.swift',
     'Image(systemName: quote.isUp ? "arrow.up.right" : "arrow.down.right")',
     'Image(systemName: quote.isUp ? "arrow.up.right" : "arrow.down.right")\n                    .accessibilityHidden(true)'),

    (30, 'ContentView: 价格 accessibilityLabel',
     'StockPulse/ContentView.swift',
     '.monospacedDigit()\n\n            HStack(spacing: 8) {',
     '.monospacedDigit()\n                .accessibilityLabel("当前价格 \\(formatPrice(quote.price))")\n\n            HStack(spacing: 8) {'),

    # ── Settings (31–40) ──
    (31, 'SettingsView: checkmark → AppTheme.accent',
     'StockPulse/Views/SettingsView.swift',
     '.foregroundStyle(.blue)',
     '.foregroundStyle(AppTheme.accent)'),

    (32, 'SettingsView: 定时开关 Label 图标',
     'StockPulse/Views/SettingsView.swift',
     'Toggle("定时股价分析", isOn: $viewModel.periodicAnalysisEnabled)',
     'Toggle(isOn: $viewModel.periodicAnalysisEnabled) {\n                        Label("定时股价分析", systemImage: "bell.badge")\n                    }'),

    (33, 'SettingsView: footer 文案精简',
     'StockPulse/Views/SettingsView.swift',
     '会按设定间隔推送当前股价与简短投资建议。App 在前台时也会自动刷新分析。',
     '会按设定间隔推送股价简报，App 前台时同步刷新。'),

    (34, 'SettingsView: 自选说明 Section',
     'StockPulse/Views/SettingsView.swift',
     'Section("自选股管理") {',
     'Section {\n                    Text("点击自选可切换当前分析标的")\n                        .font(.caption)\n                        .foregroundStyle(.secondary)\n                }\n\n                Section("自选股管理") {'),

    (35, 'SettingsView: 添加按钮 accent tint',
     'StockPulse/Views/SettingsView.swift',
     '.disabled(newSymbol.isEmpty)',
     '.tint(AppTheme.accent)\n                        .disabled(newSymbol.isEmpty)'),

    (36, 'SettingsView: 小组件 Link Label 图标',
     'StockPulse/Views/SettingsView.swift',
     'Link("在桌面添加小组件", destination: URL(string: "https://support.apple.com/guide/iphone/add-widgets-iphb8f1bf206/ios")!)',
     'Link(destination: URL(string: "https://support.apple.com/guide/iphone/add-widgets-iphb8f1bf206/ios")!) {\n                        Label("在桌面添加小组件", systemImage: "square.grid.2x2")\n                    }'),

    (37, 'SettingsView: Form 背景 (dark mode)',
     'StockPulse/Views/SettingsView.swift',
     '.navigationTitle("设置")',
     '.scrollContentBackground(.hidden)\n            .background(Color(.systemGroupedBackground))\n            .navigationTitle("设置")'),

    (38, 'SettingsView: 完成按钮 semibold',
     'StockPulse/Views/SettingsView.swift',
     'Button("完成") { dismiss() }',
     'Button("完成") { dismiss() }\n                        .fontWeight(.semibold)'),

    (39, 'SettingsView: TextField 圆角边框样式',
     'StockPulse/Views/SettingsView.swift',
     'TextField("添加代码，如 NVDA", text: $newSymbol)',
     'TextField("添加代码，如 NVDA", text: $newSymbol)\n                            .textFieldStyle(.roundedBorder)'),

    (40, 'SettingsView: 间隔选项加 5 分钟',
     'StockPulse/Views/SettingsView.swift',
     'private let intervalOptions = [15, 30, 60, 120, 240]',
     'private let intervalOptions = [5, 15, 30, 60, 120, 240]'),

    # ── Widget (41–50) ──
    (41, 'Widget: 小尺寸涨跌色 → AppTheme',
     'StockPulseWidget/StockPulseWidget.swift',
     '.foregroundStyle(quote.isUp ? .green : .red)',
     '.foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))'),

    (42, 'Widget: 中尺寸涨跌色 → AppTheme',
     'StockPulseWidget/StockPulseWidget.swift',
     'Text("\\(quote.isUp ? "+" : "")\\(String(format: "%.2f%%", quote.changePercent))")\n                        .foregroundStyle(quote.isUp ? .green : .red)',
     'Text("\\(quote.isUp ? "+" : "")\\(String(format: "%.2f%%", quote.changePercent))")\n                        .foregroundStyle(AppTheme.trendColor(isUp: quote.isUp))'),

    (43, 'Widget: 迷你图 lineColor → AppTheme',
     'StockPulseWidget/StockPulseWidget.swift',
     'lineColor: quote.isUp ? .green : .red',
     'lineColor: AppTheme.trendColor(isUp: quote.isUp)'),

    (44, 'Widget: padding 12pt',
     'StockPulseWidget/StockPulseWidget.swift',
     '.padding()\n                .background(Color(.systemBackground))',
     '.padding(12)\n                .background(Color(.secondarySystemBackground))'),

    (45, 'Widget: 小尺寸价格字号增大',
     'StockPulseWidget/StockPulseWidget.swift',
     '.font(.title2.bold())',
     '.font(.title.bold())'),

    (46, 'Widget: 空态文案优化',
     'StockPulseWidget/StockPulseWidget.swift',
     'Text("打开 App 刷新")',
     'Text("点击打开 StockPulse")'),

    (47, 'Widget: 刷新间隔 15 → 10 分钟',
     'StockPulseWidget/StockPulseWidget.swift',
     'value: 15, to: Date()',
     'value: 10, to: Date()'),

    (48, 'Widget: 中尺寸 chart 圆角',
     'StockPulseWidget/StockPulseWidget.swift',
     'lineColor: AppTheme.trendColor(isUp: quote.isUp)\n                )\n            }',
     'lineColor: AppTheme.trendColor(isUp: quote.isUp)\n                )\n                .clipShape(RoundedRectangle(cornerRadius: AppTheme.pillRadius))\n            }'),

    (49, 'Widget: 描述文案优化',
     'StockPulseWidget/StockPulseWidget.swift',
     '.description("随时查看股价走势与简短投资分析。")',
     '.description("桌面随时查看股价走势与投资简报。")'),

    (50, 'Widget: 小尺寸 symbol 显示名称',
     'StockPulseWidget/StockPulseWidget.swift',
     'Text(entry.quote?.symbol ?? "StockPulse")',
     'Text(entry.quote?.name ?? entry.quote?.symbol ?? "StockPulse")'),

    # ── Haptics (51–55) ──
    (51, 'ContentView: 添加 UIKit 触觉反馈',
     'StockPulse/ContentView.swift',
     'import SwiftUI',
     'import SwiftUI\nimport UIKit'),

    (52, 'ContentView: lightHaptic 辅助函数',
     'StockPulse/ContentView.swift',
     '    private func submitSearch() {',
     '    private func lightHaptic() {\n        UIImpactFeedbackGenerator(style: .light).impactOccurred()\n    }\n\n    private func submitSearch() {'),

    (53, 'ContentView: 搜索提交触觉反馈',
     'StockPulse/ContentView.swift',
     '    private func submitSearch() {\n        let symbol = searchSymbol.isEmpty ? viewModel.selectedSymbol : searchSymbol',
     '    private func submitSearch() {\n        lightHaptic()\n        let symbol = searchSymbol.isEmpty ? viewModel.selectedSymbol : searchSymbol'),

    (54, 'ContentView: 自选切换触觉反馈',
     'StockPulse/ContentView.swift',
     'searchSymbol = item.symbol\n                            viewModel.selectSymbol(item.symbol)',
     'lightHaptic()\n                            searchSymbol = item.symbol\n                            viewModel.selectSymbol(item.symbol)'),

    (55, 'ContentView: 刷新按钮触觉反馈',
     'StockPulse/ContentView.swift',
     'Task { await viewModel.refresh() }',
     'Task { lightHaptic(); await viewModel.refresh() }'),

    # ── Accessibility (56–65) ──
    (56, 'ContentView: 设置按钮 accessibility',
     'StockPulse/ContentView.swift',
     'Image(systemName: "gearshape")',
     'Image(systemName: "gearshape")\n                            .accessibilityLabel("设置")'),

    (57, 'ContentView: 刷新按钮 accessibility',
     'StockPulse/ContentView.swift',
     'Image(systemName: "arrow.clockwise")',
     'Image(systemName: "arrow.clockwise")\n                                .accessibilityLabel("刷新")'),

    (58, 'ContentView: 分析卡片 accessibility 组合',
     'StockPulse/ContentView.swift',
     'AnalysisCardView(analysis: analysis)\n                            .padding(.horizontal)',
     'AnalysisCardView(analysis: analysis)\n                            .padding(.horizontal)\n                            .accessibilityElement(children: .combine)'),

    (59, 'AnalysisCardView: 趋势 accessibilityLabel',
     'StockPulse/Views/AnalysisCardView.swift',
     'Label(analysis.trend.rawValue, systemImage: trendIcon)',
     'Label(analysis.trend.rawValue, systemImage: trendIcon)\n                    .accessibilityLabel("趋势 \\(analysis.trend.rawValue)")'),

    (60, 'ContentView: 搜索框 accessibilityHint',
     'StockPulse/ContentView.swift',
     '.autocorrectionDisabled()\n                .onSubmit { submitSearch() }',
     '.autocorrectionDisabled()\n                .accessibilityHint("输入股票代码后点分析或回车")\n                .onSubmit { submitSearch() }'),

    (61, 'ContentView: 空态 accessibility 组合',
     'StockPulse/ContentView.swift',
     '.padding(.top, 40)\n                        .padding(.horizontal)',
     '.padding(.top, 40)\n                        .padding(.horizontal)\n                        .accessibilityElement(children: .combine)'),

    (62, 'SettingsView: 定时开关 accessibilityHint',
     'StockPulse/Views/SettingsView.swift',
     'Label("定时股价分析", systemImage: "bell.badge")\n                    }',
     'Label("定时股价分析", systemImage: "bell.badge")\n                    }\n                    .accessibilityHint("开启后将按间隔推送股价简报")'),

    (63, 'Widget: 小尺寸 accessibility 组合',
     'StockPulseWidget/StockPulseWidget.swift',
     '.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)',
     '.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)\n        .accessibilityElement(children: .combine)'),

    (64, 'ContentView: 自选按钮 accessibilityLabel',
     'StockPulse/ContentView.swift',
     '.buttonStyle(.plain)\n                    }',
     '.buttonStyle(.plain)\n                        .accessibilityLabel("\\(item.displayName.isEmpty ? item.symbol : item.displayName)")\n                    }'),

    (65, 'AnalysisCardView: 更新时间 accessibility',
     'StockPulse/Views/AnalysisCardView.swift',
     'Text("更新于 \\(analysis.generatedAt.formatted(date: .omitted, time: .shortened))")',
     'Text("更新于 \\(analysis.generatedAt.formatted(date: .omitted, time: .shortened))")\n                .accessibilityLabel("分析更新于 \\(analysis.generatedAt.formatted(date: .omitted, time: .shortened))")'),

    # ── Dark mode & polish (66–73) ──
    (66, 'ContentView: ScrollView 背景 grouped',
     'StockPulse/ContentView.swift',
     '.refreshable {',
     '.background(Color(.systemGroupedBackground))\n            .refreshable {'),

    (67, 'ContentView: 未选中自选 pill 背景 semantic',
     'StockPulse/ContentView.swift',
     ': Color.gray.opacity(0.12),',
     ': Color(.tertiarySystemFill),'),

    (68, 'AnalysisCardView: Divider 间距',
     'StockPulse/Views/AnalysisCardView.swift',
     'Divider()\n\n            VStack(alignment: .leading, spacing: 6) {',
     'Divider().padding(.vertical, 2)\n\n            VStack(alignment: .leading, spacing: 6) {'),

    (69, 'ContentView: toolbar 刷新 ProgressView tint',
     'StockPulse/ContentView.swift',
     'ProgressView()',
     'ProgressView().tint(AppTheme.accent)'),

    (70, 'AppTheme: cardShadow 常量',
     'StockPulse/Theme/AppTheme.swift',
     'static let sectionSpacing: CGFloat = 18',
     'static let sectionSpacing: CGFloat = 18\n    static let cardShadowOpacity: Double = 0.06'),

    (71, 'AnalysisCardView: 阴影使用 AppTheme 常量',
     'StockPulse/Views/AnalysisCardView.swift',
     '.shadow(color: .black.opacity(0.06), radius: 8, y: 4)',
     '.shadow(color: .black.opacity(AppTheme.cardShadowOpacity), radius: 8, y: 4)'),

    (72, 'ContentView: 搜索区 horizontal padding 16',
     'StockPulse/ContentView.swift',
     '.padding(.horizontal)\n        .onAppear {',
     '.padding(.horizontal, 16)\n        .onAppear {'),

    (73, 'ContentView: watchlist 间距 10 → 8',
     'StockPulse/ContentView.swift',
     'HStack(spacing: 10) {',
     'HStack(spacing: 8) {'),

    # ── Iter 74: Button → Label (specified) ──
    (74, 'ContentView: 分析按钮 → Label 图标',
     'StockPulse/ContentView.swift',
     'Button("分析") { submitSearch() }',
     'Button { submitSearch() } label: {\n                Label("分析", systemImage: "chart.line.uptrend.xyaxis")\n            }'),

    # ── More polish (75–99) ──
    (75, 'ContentView: 涨跌 HStack spacing 8 → 6',
     'StockPulse/ContentView.swift',
     'HStack(spacing: 8) {\n                Image(systemName: quote.isUp',
     'HStack(spacing: 6) {\n                Image(systemName: quote.isUp'),

    (76, 'ContentView: 高低价 spacing 20 → 24',
     'StockPulse/ContentView.swift',
     'HStack(spacing: 20) {\n                labelValue("最高"',
     'HStack(spacing: 24) {\n                labelValue("最高"'),

    (77, 'AnalysisCardView: VStack spacing 12 → 14',
     'StockPulse/Views/AnalysisCardView.swift',
     'VStack(alignment: .leading, spacing: 12) {',
     'VStack(alignment: .leading, spacing: 14) {'),

    (78, 'MiniChartView: 空态 frame center',
     'StockPulse/Views/MiniChartView.swift',
     '.frame(maxWidth: .infinity, maxHeight: .infinity)',
     '.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)'),

    (79, 'Widget: 中尺寸 HStack spacing 12 → 14',
     'StockPulseWidget/StockPulseWidget.swift',
     'HStack(spacing: 12) {',
     'HStack(spacing: 14) {'),

    (80, 'Widget: 小尺寸 VStack spacing 6 → 8',
     'StockPulseWidget/StockPulseWidget.swift',
     'VStack(alignment: .leading, spacing: 6) {\n            HStack {',
     'VStack(alignment: .leading, spacing: 8) {\n            HStack {'),

    (81, 'ContentView: 空态 headline foregroundStyle',
     'StockPulse/ContentView.swift',
     'Text("暂无分析")\n                                .font(.headline)',
     'Text("暂无分析")\n                                .font(.headline)\n                                .foregroundStyle(.primary)'),

    (82, 'ContentView: alert 按钮改「知道了」',
     'StockPulse/ContentView.swift',
     'Button("好的") { viewModel.errorMessage = nil }',
     'Button("知道了") { viewModel.errorMessage = nil }'),

    (83, 'SettingsView: 自选股 symbol headline → subheadline semibold',
     'StockPulse/Views/SettingsView.swift',
     'Text(item.symbol)\n                                    .font(.headline)',
     'Text(item.symbol)\n                                    .font(.subheadline.weight(.semibold))'),

    (84, 'AnalysisCardView: 投资建议标题 accent',
     'StockPulse/Views/AnalysisCardView.swift',
     'Text("投资建议")\n                    .font(.subheadline.weight(.semibold))\n                    .foregroundStyle(.secondary)',
     'Text("投资建议")\n                    .font(.subheadline.weight(.semibold))\n                    .foregroundStyle(AppTheme.accent)'),

    (85, 'ContentView: quoteHeader spacing 8 → 10',
     'StockPulse/ContentView.swift',
     'VStack(spacing: 8) {\n            Text(quote.name)',
     'VStack(spacing: 10) {\n            Text(quote.name)'),

    (86, 'ContentView: watchlistSection spacing 12 → 14',
     'StockPulse/ContentView.swift',
     'VStack(alignment: .leading, spacing: 12) {\n            Label("快捷自选"',
     'VStack(alignment: .leading, spacing: 14) {\n            Label("快捷自选"'),

    (87, 'AppTheme: chartHeight 常量',
     'StockPulse/Theme/AppTheme.swift',
     'static let cardShadowOpacity: Double = 0.06',
     'static let cardShadowOpacity: Double = 0.06\n    static let chartHeight: CGFloat = 132'),

    (88, 'ContentView: 图表高度使用 AppTheme.chartHeight',
     'StockPulse/ContentView.swift',
     '.frame(height: 132)',
     '.frame(height: AppTheme.chartHeight)'),

    (89, 'Widget: configurationDisplayName 优化',
     'StockPulseWidget/StockPulseWidget.swift',
     '.configurationDisplayName("StockPulse")',
     '.configurationDisplayName("StockPulse 股价")'),

    (90, 'ContentView: 搜索 HStack spacing 12 → 10',
     'StockPulse/ContentView.swift',
     'HStack(spacing: 12) {\n            TextField("输入代码',
     'HStack(spacing: 10) {\n            TextField("输入代码'),

    (91, 'AnalysisCardView: trend Label subheadline → callout',
     'StockPulse/Views/AnalysisCardView.swift',
     '.font(.subheadline.weight(.semibold))',
     '.font(.callout.weight(.semibold))'),

    (92, 'ContentView: 自选 pill vertical padding 10 → 12',
     'StockPulse/ContentView.swift',
     '.padding(.vertical, 10)',
     '.padding(.vertical, 12)'),

    (93, 'SettingsView: widget footer 文案优化',
     'StockPulse/Views/SettingsView.swift',
     '长按主屏幕 → 点左上角 + → 搜索 StockPulse，即可添加股价小组件。',
     '长按主屏幕 → 点 + → 搜索 StockPulse，添加小/中尺寸小组件。'),

    (94, 'MiniChartView: 默认 lineColor → AppTheme.bullish',
     'StockPulse/Views/MiniChartView.swift',
     'var lineColor: Color = .green',
     'var lineColor: Color = AppTheme.bullish'),

    (95, 'ContentView: navigationTitle 改 StockPulse 📊',
     'StockPulse/ContentView.swift',
     '.navigationTitle("StockPulse")',
     '.navigationTitle("StockPulse 📊")'),

    (96, 'Widget: 中尺寸 Label 图标色 accent',
     'StockPulseWidget/StockPulseWidget.swift',
     'Label(analysis.trend.rawValue, systemImage: "chart.line.uptrend.xyaxis")\n                        .font(.caption)\n                        .foregroundStyle(.secondary)',
     'Label(analysis.trend.rawValue, systemImage: "chart.line.uptrend.xyaxis")\n                        .font(.caption)\n                        .foregroundStyle(AppTheme.accent)'),

    (97, 'ContentView: 加载态 ProgressView',
     'StockPulse/ContentView.swift',
     'if let quote = viewModel.quote {',
     'if viewModel.isLoading && viewModel.quote == nil {\n                        ProgressView("加载中…")\n                            .padding(.top, 60)\n                    }\n                    if let quote = viewModel.quote {'),

    (98, 'AppTheme: watchlistSelectedOpacity 常量',
     'StockPulse/Theme/AppTheme.swift',
     'static let chartHeight: CGFloat = 132',
     'static let chartHeight: CGFloat = 132\n    static let watchlistSelectedOpacity: Double = 0.18'),

    (99, 'ContentView: 自选选中 opacity 使用 AppTheme 常量',
     'StockPulse/ContentView.swift',
     '? AppTheme.accent.opacity(0.18)',
     '? AppTheme.accent.opacity(AppTheme.watchlistSelectedOpacity)'),

    # ── Iter 100: README completion marker (specified) ──
    (100, 'README: 100 次迭代完成标记',
     'README.md',
     '股市有风险，投资需谨慎。',
     '股市有风险，投资需谨慎。\n\n---\n\n✅ **100 次自动迭代已完成** (nightly auto-iterate)'),
]
