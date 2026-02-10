import SwiftUI
import Charts
import StatsClient

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
    let stats: StatsCache
    @State private var selectedMetric: ActivityMetric = .messages
    @State private var selectedDate: Date?

    private var activities: [DailyActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }

        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            if let match = stats.dailyActivity.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                return match
            }
            return DailyActivity(date: day, messageCount: 0, sessionCount: 0, toolCallCount: 0)
        }
    }

    private var selectedActivity: DailyActivity? {
        guard let selectedDate else { return nil }
        return activities.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var hasActivity: Bool {
        activities.contains { $0.messageCount > 0 || $0.sessionCount > 0 || $0.toolCallCount > 0 }
    }

    var body: some View {
        if hasActivity {
            content
        } else {
            Text("No activity this week")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 70)
        }
    }

    private var content: some View {
        VStack(spacing: 12) {
            HStack(spacing: 1) {
                ForEach(ActivityMetric.allCases, id: \.self) { metric in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedMetric = metric
                        }
                    } label: {
                        Text(metric.rawValue)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 3)
                            .background(selectedMetric == metric ? .white.opacity(0.1) : .clear, in: RoundedRectangle(cornerRadius: 4))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(2)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))

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
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartXScale(range: .plotDimension(padding: 12))
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
    DailyActivityChart(stats: .mock)
        .padding()
}
