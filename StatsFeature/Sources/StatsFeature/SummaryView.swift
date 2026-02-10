import SwiftUI
import StatsClient

struct SummaryView: View {
    let stats: StatsCache

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                sectionHeader("All Time")
                VStack(spacing: 3) {
                    row("Sessions", value: "\(stats.totalSessions)")
                    row("Messages", value: "\(stats.totalMessages)")
                    if let days = daysSinceFirstSession {
                        row("Days", value: "\(days)")
                    }
                    if let peakHour = peakHourDate {
                        row("Peak", value: Text(peakHour, format: .dateTime.hour().minute()))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .padding(.horizontal, 10)

            VStack(alignment: .leading, spacing: 6) {
                sectionHeader("Longest Session")
                VStack(spacing: 3) {
                    row("Duration", value: Text(Duration.milliseconds(stats.longestSession.duration), format: .units(allowed: [.hours, .minutes, .seconds], width: .narrow, maximumUnitCount: 2)))
                    row("Messages", value: "\(stats.longestSession.messageCount)")
                    row("Date", value: Text(stats.longestSession.timestamp, format: .dateTime.day().month().year()))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Computed Properties

    private var daysSinceFirstSession: Int? {
        Calendar.current.dateComponents([.day], from: stats.firstSessionDate, to: .now).day
    }

    private var peakHourDate: Date? {
        guard let maxEntry = stats.hourCounts.max(by: { $0.value < $1.value }),
              let hour = Int(maxEntry.key) else { return nil }
        return Calendar.current.date(from: DateComponents(hour: hour))
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func row(_ label: String, value: String) -> some View {
        row(label, value: Text(value))
    }

    private func row(_ label: String, value: Text) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            value
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    SummaryView(stats: .mock)
        .padding()
}
