# StockPulse — iPhone 股票走势分析小插件

专为 iPhone 设计的 SwiftUI 应用 + 桌面小组件，随时查看股价走势，并可通过开关开启定时简报推送。

## 功能

- **即时分析**：输入股票代码，一键获取现价、涨跌幅、近 3 个月走势迷你图
- **走势解读**：基于均线与 momentum 判断看涨 / 看跌 / 震荡，并给出简短投资建议
- **定时简报开关**：设置页可开启「定时股价分析」，按 15 分钟 ~ 4 小时间隔推送通知
- **桌面小组件**：小尺寸显示股价 + 建议；中尺寸附带走势迷你图
- **自选股**：预置 AAPL、TSLA、贵州茅台，可自定义添加

## 支持的股票代码示例

| 市场 | 示例代码 |
|------|----------|
| 美股 | `AAPL`、`TSLA`、`NVDA` |
| A 股 | `600519.SS`（茅台）、`000001.SZ`（平安） |
| 港股 | `0700.HK`（腾讯） |

数据来源：Yahoo Finance（免费，无需 API Key）

## 安装到 iPhone

1. 用 Xcode 打开 `StockPulse/StockPulse.xcodeproj`
2. 在 **Signing & Capabilities** 中为 App 和 Widget 两个 Target 选择你的 Apple ID Team
3. 确认两个 Target 都已启用 App Groups：`group.com.stockpulse.shared`
4. 用数据线连接 iPhone，选择设备后点击 Run（▶）

> 免费 Apple ID 可将 App 安装到本机，有效期 7 天，到期后重新 Run 即可。

## 使用说明

### 主界面
- 顶部输入框输入代码，点「分析」或下拉刷新
- 下方快捷自选可快速切换股票
- 右上角刷新按钮手动更新

### 设置（左上角齿轮）
- **定时股价分析**：开关控制是否定期推送
- **分析间隔**：15 分钟 / 30 分钟 / 1 小时 / 2 小时 / 4 小时
- 首次开启会请求通知权限，请允许

### 添加桌面小组件
1. 长按 iPhone 主屏幕 → 点左上角 **+**
2. 搜索 **StockPulse**
3. 选择小或中尺寸，添加到主屏幕

## 项目结构

```
StockPulse/
├── StockPulse/              # 主 App
│   ├── Models/              # 数据模型
│   ├── Services/            # 行情、分析、通知
│   ├── ViewModels/
│   └── Views/
├── StockPulseWidget/        # 桌面小组件
└── StockPulse.xcodeproj
```

## 免责声明

本 App 提供的分析仅供参考，不构成投资建议。股市有风险，投资需谨慎。
