import SwiftUI
import Charts

struct HourlyDistributionChart: View {
    let hourCounts: [(hour: Int, count: Int)]

    var body: some View {
        Chart(hourCounts, id: \.hour) { entry in
            BarMark(
                x: .value("Hour", formatHour(entry.hour)),
                y: .value("Count", entry.count)
            )
            .foregroundStyle(.orange.gradient)
        }
        .frame(height: 120)
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "p" : "a"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour)\(period)"
    }
}
