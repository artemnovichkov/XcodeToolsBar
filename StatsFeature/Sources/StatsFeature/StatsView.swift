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
            SummaryView(stats: stats)
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
}

#Preview("Happy path") {
    StatsView(viewModel: StatsViewModel(statsClient: .happyPath))
}
#Preview("Empty") {
    StatsView(viewModel: StatsViewModel(statsClient: .empty))
}
