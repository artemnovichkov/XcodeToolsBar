import SwiftUI
import Charts

struct StatsView: View {
    @State private var viewModel = StatsViewModel()

    var body: some View {
        Group {
            if let error = viewModel.error, viewModel.stats == nil {
                errorView(error)
            } else if let stats = viewModel.stats {
                statsContent(stats)
            } else {
                ProgressView()
            }
        }
        .frame(width: 320)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.headline)
            Button("Retry") {
                viewModel.loadStats()
            }
        }
        .padding()
    }

    // MARK: - Stats Content

    private func statsContent(_ stats: StatsCache) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection(stats)
            todaySection()
            dailyChartSection()
            HStack(spacing: 8) {
                allTimeSection(stats)
                longestSessionSection(stats)
            }
            modelUsageSection(stats)
            hourlyChartSection()
            footerSection()
        }
        .padding(12)
    }

    // MARK: - Header

    private func headerSection(_ stats: StatsCache) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Claude Agent Stats")
                    .font(.headline)
                Text("Updated: \(stats.lastComputedDate, format: .dateTime.day().month().year())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "hammer.fill")
                .foregroundStyle(.blue)
        }
    }

    // MARK: - Today

    private func todaySection() -> some View {
        GroupBox("Today") {
            if let today = viewModel.todayActivity {
                HStack {
                    statCell("Messages", value: "\(today.messageCount)")
                    Spacer()
                    statCell("Sessions", value: "\(today.sessionCount)")
                    Spacer()
                    statCell("Tool Calls", value: "\(today.toolCallCount)")
                }
            } else {
                Text("No activity today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Daily Chart

    private func dailyChartSection() -> some View {
        GroupBox("Daily Activity") {
            let activities = viewModel.recentDailyActivity
            if activities.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                DailyActivityChart(activities: activities)
            }
        }
    }

    // MARK: - All Time

    private func allTimeSection(_ stats: StatsCache) -> some View {
        GroupBox("All Time") {
            VStack(spacing: 4) {
                row("Sessions", value: "\(stats.totalSessions)")
                row("Messages", value: "\(stats.totalMessages)")
                if let days = viewModel.daysSinceFirstSession {
                    row("Days", value: "\(days)")
                }
                if let peakHour = viewModel.peakHour {
                    row("Peak", value: peakHour)
                }
            }
        }
    }

    // MARK: - Longest Session

    private func longestSessionSection(_ stats: StatsCache) -> some View {
        GroupBox("Best Session") {
            VStack(spacing: 4) {
                if let duration = viewModel.formattedLongestSessionDuration {
                    row("Duration", value: duration)
                }
                row("Messages", value: "\(stats.longestSession.messageCount)")
                if let date = viewModel.longestSessionDate {
                    row("Date", value: date)
                }
            }
        }
    }

    // MARK: - Model Usage

    private func modelUsageSection(_ stats: StatsCache) -> some View {
        GroupBox("Model Usage") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.sortedModelNames, id: \.self) { name in
                    if let usage = stats.modelUsage[name] {
                        HStack {
                            Text(name)
                                .font(.subheadline)
                            Spacer()
                            Text("\(viewModel.formatTokenCount(usage.inputTokens + usage.outputTokens + usage.cacheReadInputTokens))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Hourly Chart

    private func hourlyChartSection() -> some View {
        GroupBox("Hourly Distribution") {
            let hourCounts = viewModel.sortedHourCounts
            if hourCounts.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HourlyDistributionChart(hourCounts: hourCounts)
            }
        }
    }

    // MARK: - Footer

    private func footerSection() -> some View {
        HStack {
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    // MARK: - Helpers

    private func statCell(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

}
#Preview {
    StatsView()
}

