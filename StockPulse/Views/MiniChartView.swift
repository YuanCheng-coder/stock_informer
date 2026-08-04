import SwiftUI

struct MiniChartView: View {
    let prices: [Double]
    var lineColor: Color = .green

    var body: some View {
        GeometryReader { geo in
            if prices.count >= 2, let min = prices.min(), let max = prices.max(), max > min {
                Path { path in
                    let width = geo.size.width
                    let height = geo.size.height
                    let range = max - min

                    for (index, price) in prices.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(prices.count - 1)
                        let y = height - (CGFloat(price - min) / CGFloat(range)) * height
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineJoin: .round, lineCap: .round))
                .drawingGroup()
            } else {
                Text("暂无走势数据")
                    .font(.caption2)
                    .accessibilityLabel("暂无走势数据")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
