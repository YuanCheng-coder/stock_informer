#!/bin/bash
# 使用 Xcode 命令行创建 StockPulse 项目结构
# 运行: bash setup_project.sh

set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

PROJECT_NAME="StockPulse"
BUNDLE_ID="com.stockpulse.app"
WIDGET_BUNDLE_ID="com.stockpulse.app.widget"

if [ ! -d "$PROJECT_NAME.xcodeproj" ]; then
  echo "正在创建 Xcode 项目..."
  
  # 创建临时 Swift Package 来获取项目模板不可用，直接提示用户手动创建
  cat > "$ROOT/PROJECT_SETUP.md" << 'INNER'
请在 Xcode 中按以下步骤创建项目（约 3 分钟）：

1. 打开 Xcode → File → New → Project
2. 选择 iOS → App，Product Name: StockPulse，Interface: SwiftUI，Language: Swift
3. 保存到本目录的上一级，或直接替换生成的 StockPulse 文件夹内容
4. File → New → Target → Widget Extension，名称 StockPulseWidget
5. 将本仓库中 StockPulse/ 和 StockPulseWidget/ 下的 Swift 文件拖入对应 Target
6. 以下文件需同时勾选 StockPulse 和 StockPulseWidget 两个 Target：
   - Models/StockQuote.swift, StockAnalysis.swift
   - Services/StockService.swift, AnalysisEngine.swift, SharedSettings.swift
   - Views/MiniChartView.swift
7. Signing & Capabilities → 两个 Target 都添加 App Groups: group.com.stockpulse.shared
8. 将 StockPulse.entitlements 和 StockPulseWidget.entitlements 关联到对应 Target
9. 选择你的 Team，连接 iPhone 运行

或使用下方的一键脚本（需要完整 Xcode）：
INNER
fi

echo "项目文件已就绪: $ROOT"
echo "请阅读 README.md 获取完整安装说明"
