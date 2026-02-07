import SwiftUI
import Charts

enum ActivityMetric: String, CaseIterable {
    case messages = "Messages"
    case sessions = "Sessions"
    case toolCalls = "Tool Calls"
    
    var color: Color {
        switch self {
        case .messages: .blue
        case .sessions: .green
        case .toolCalls: .orange
        }
    }
}

struct DailyActivityChart: View {
    let activities: [DailyActivity]
    @State private var selectedMetric: ActivityMetric = .messages
    @State private var selectedDate: Date?
    
    private var selectedActivity: DailyActivity? {
        guard let selectedDate else { return nil }
        return activities.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Metric", selection: $selectedMetric) {
                ForEach(ActivityMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .controlSize(.small)
            
            Chart(activities) { activity in
                BarMark(
                    x: .value("Date", activity.date, unit: .day),
                    y: .value(selectedMetric.rawValue, value(for: activity))
                )
                .foregroundStyle(selectedMetric.color.gradient)
                .opacity(selectedActivity == nil || selectedActivity?.date == activity.date ? 1.0 : 0.5)
                
                if let selected = selectedActivity, Calendar.current.isDate(selected.date, inSameDayAs: activity.date) {
                    RuleMark(x: .value("Date", activity.date, unit: .day))
                        .foregroundStyle(.gray.opacity(0.3))
                        .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack(spacing: 2) {
                                Text(activity.date, format: .dateTime.month(.abbreviated).day())
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("\(value(for: activity))")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartXSelection(value: $selectedDate)
            .frame(height: 70)
        }
    }
    
    private func value(for activity: DailyActivity) -> Int {
        switch selectedMetric {
        case .messages: activity.messageCount
        case .sessions: activity.sessionCount
        case .toolCalls: activity.toolCallCount
        }
    }
}
#Preview {
    DailyActivityChart(activities: [
        DailyActivity(date: Date().addingTimeInterval(-6 * 86400), messageCount: 45, sessionCount: 3, toolCallCount: 120),
        DailyActivity(date: Date().addingTimeInterval(-5 * 86400), messageCount: 78, sessionCount: 5, toolCallCount: 200),
        DailyActivity(date: Date().addingTimeInterval(-4 * 86400), messageCount: 32, sessionCount: 2, toolCallCount: 85),
        DailyActivity(date: Date().addingTimeInterval(-3 * 86400), messageCount: 91, sessionCount: 6, toolCallCount: 250),
        DailyActivity(date: Date().addingTimeInterval(-2 * 86400), messageCount: 56, sessionCount: 4, toolCallCount: 150),
        DailyActivity(date: Date().addingTimeInterval(-1 * 86400), messageCount: 67, sessionCount: 4, toolCallCount: 180),
        DailyActivity(date: Date(), messageCount: 23, sessionCount: 2, toolCallCount: 60),
    ])
    .padding()
}

