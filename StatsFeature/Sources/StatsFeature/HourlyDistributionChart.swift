import SwiftUI
import Charts

struct HourlyDistributionChart: View {
    let hourCounts: [(hour: Int, count: Int)]
    @State private var selectedHour: Int?

    var body: some View {
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
    HourlyDistributionChart(hourCounts: [
        (0, 2), (1, 1), (2, 0), (3, 0), (4, 0), (5, 1),
        (6, 3), (7, 5), (8, 12), (9, 18), (10, 22), (11, 25),
        (12, 20), (13, 15), (14, 28), (15, 32), (16, 35), (17, 30),
        (18, 22), (19, 18), (20, 15), (21, 10), (22, 6), (23, 3)
    ])
    .padding()
}
