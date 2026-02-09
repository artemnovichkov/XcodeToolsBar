import SwiftUI
import Charts
import StatsClient

public struct StatsView: View {
    @State var viewModel: StatsViewModel

    public init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if let error = viewModel.error, viewModel.stats == nil {
                errorView(error)
            } else if let stats = viewModel.stats {
                statsContent(stats)
            }
        }
        .frame(width: 320)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("No Statistics Yet", systemImage: "chart.bar.xaxis")
        } description: {
            Text("Use Claude Agent in Xcode to generate statistics. Stats update the next day.")
        }
        .padding()
    }

    // MARK: - Stats Content

    private func statsContent(_ stats: StatsCache) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection(stats)
            dailyChartSection()
            summarySection(stats)
            modelUsageSection(stats)
            hourlyChartSection()
            footerSection()
        }
        .padding(16)
    }

    // MARK: - Header

    private func headerSection(_ stats: StatsCache) -> some View {
        HStack(alignment: .center) {
            Image(systemName: "hammer.fill")
                .font(.title2)
                .foregroundStyle(.blue.gradient)
            VStack(alignment: .leading, spacing: 1) {
                Text("Claude Agent")
                    .font(.headline)
                Text(stats.lastComputedDate, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Daily Chart

    private func dailyChartSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Daily Activity")
            if viewModel.hasRecentActivity {
                DailyActivityChart(activities: viewModel.recentDailyActivity)
            } else {
                Text("No activity this week")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 70)
            }
        }
    }

    // MARK: - Summary (All Time + Best Session)

    private func summarySection(_ stats: StatsCache) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                sectionHeader("All Time")
                VStack(spacing: 3) {
                    row("Sessions", value: "\(stats.totalSessions)")
                    row("Messages", value: "\(stats.totalMessages)")
                    if let days = viewModel.daysSinceFirstSession {
                        row("Days", value: "\(days)")
                    }
                    if let peakHour = viewModel.peakHourDate {
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

    // MARK: - Model Usage

    private func modelUsageSection(_ stats: StatsCache) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Models")
            VStack(spacing: 4) {
                ForEach(viewModel.sortedModelNames, id: \.self) { name in
                    if let usage = stats.modelUsage[name] {
                        let totalTokens = usage.inputTokens + usage.outputTokens + usage.cacheReadInputTokens
                        HStack {
                            Text(viewModel.shortModelName(name))
                                .font(.subheadline)
                            Spacer()
                            Text(totalTokens, format: .number.notation(.compactName))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Hourly Chart

    private func hourlyChartSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Hourly Distribution")
            let hourCounts = viewModel.sortedHourCounts
            if hourCounts.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
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
            .buttonStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
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

#Preview("Happy path") {
    StatsView(viewModel: StatsViewModel(statsClient: .happyPath))
}
#Preview("Empty") {
    StatsView(viewModel: StatsViewModel(statsClient: .empty))
}
