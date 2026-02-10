import SwiftUI
import Charts
import StatsClient

struct HourlyDistributionChart: View {
    let stats: StatsCache
    @State private var selectedHour: Int?

    private var hourCounts: [(hour: Int, count: Int)] {
        stats.hourCounts
            .compactMap { key, value in
                guard let hour = Int(key) else { return nil }
                return (hour: hour, count: value)
            }
            .sorted { $0.hour < $1.hour }
    }

    var body: some View {
        if hourCounts.isEmpty {
            Text("No data")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        } else {
            content
        }
    }

    private var content: some View {
        Chart(hourCounts, id: \.hour) { entry in
            BarMark(
                x: .value("Hour", entry.hour),
                y: .value("Count", entry.count)
            )
            .foregroundStyle(.orange.gradient)
            .opacity(selectedHour == nil || selectedHour == entry.hour ? 1.0 : 0.5)

            if let selected = selectedHour, selected == entry.hour {
                RuleMark(x: .value("Hour", entry.hour))
                    .foregroundStyle(.gray.opacity(0.3))
                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack(spacing: 2) {
                            Text(dateForHour(entry.hour), format: .dateTime.hour().minute())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(entry.count)")
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: [0, 6, 12, 18]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text(dateForHour(hour), format: .dateTime.hour().minute())
                    }
                }
            }
        }
        .chartXScale(domain: 0...23, range: .plotDimension(padding: 12))
        .chartXSelection(value: $selectedHour)
        .frame(height: 80)
    }

    private func dateForHour(_ hour: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour))!
    }
}

#Preview {
    HourlyDistributionChart(stats: .mock)
        .padding()
}
