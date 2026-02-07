import SwiftUI
import Charts

struct DailyActivityChart: View {
    let activities: [DailyActivity]

    var body: some View {
        Chart(activities) { activity in
            BarMark(
                x: .value("Date", shortDate(activity.date)),
                y: .value("Messages", activity.messageCount)
            )
            .foregroundStyle(.blue.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel()
            }
        }
        .frame(height: 120)
    }

    private func shortDate(_ dateString: String) -> String {
        let parts = dateString.split(separator: "-")
        guard parts.count == 3 else { return dateString }
        return "\(parts[1])/\(parts[2])"
    }
}
