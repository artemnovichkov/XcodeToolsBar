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
                            Text(formatHourFull(entry.hour))
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
                        Text(formatHour(hour))
                    }
                }
            }
        }
        .chartXScale(domain: 0...23)
        .chartXSelection(value: $selectedHour)
        .frame(height: 80)
    }

    private func formatHour(_ hour: Int) -> String {
        switch hour {
        case 0: "12a"
        case 6: "6a"
        case 12: "12p"
        case 18: "6p"
        default: "\(hour)"
        }
    }
    
    private func formatHourFull(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
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
