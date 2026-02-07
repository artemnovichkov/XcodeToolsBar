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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                headerSection(stats)
                Divider()
                todaySection()
                Divider()
                dailyChartSection()
                Divider()
                allTimeSection(stats)
                Divider()
                longestSessionSection(stats)
                Divider()
                modelUsageSection(stats)
                Divider()
                hourlyChartSection()
                Divider()
                footerSection()
            }
            .padding()
        }
    }

    // MARK: - Header

    private func headerSection(_ stats: StatsCache) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Claude Agent Stats")
                    .font(.headline)
                Text("Updated: \(stats.lastComputedDate)")
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
            VStack(spacing: 6) {
                row("Total Sessions", value: "\(stats.totalSessions)")
                row("Total Messages", value: "\(stats.totalMessages)")
                if let days = viewModel.daysSinceFirstSession {
                    row("Days Active", value: "\(days)")
                }
                if let peakHour = viewModel.peakHour {
                    row("Peak Hour", value: peakHour)
                }
            }
        }
    }

    // MARK: - Longest Session

    private func longestSessionSection(_ stats: StatsCache) -> some View {
        GroupBox("Longest Session") {
            VStack(spacing: 6) {
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
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.sortedModelNames, id: \.self) { name in
                    if let usage = stats.modelUsage[name] {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(shortModelName(name))
                                .font(.subheadline.bold())
                            HStack(spacing: 12) {
                                Text("\(viewModel.formatTokenCount(usage.inputTokens)) in")
                                Text("\(viewModel.formatTokenCount(usage.outputTokens)) out")
                                Text("\(viewModel.formatTokenCount(usage.cacheReadInputTokens)) cached")
                            }
                            .font(.caption)
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

    private func shortModelName(_ name: String) -> String {
        name.replacingOccurrences(of: "claude-", with: "")
            .replacingOccurrences(of: "-20250929", with: "")
            .replacingOccurrences(of: "-20251101", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}
