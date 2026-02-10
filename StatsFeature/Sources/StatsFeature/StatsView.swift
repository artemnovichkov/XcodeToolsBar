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
            dailyChartSection(stats)
            SummaryView(stats: stats)
            ModelUsageView(stats: stats)
            hourlyChartSection(stats)
            footerSection()
        }
        .padding(16)
    }

    // MARK: - Header

    private func headerSection(_ stats: StatsCache) -> some View {
        HStack(alignment: .center) {
            Image(.claude)
                .resizable()
                .frame(width: 40, height: 40)
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

    private func dailyChartSection(_ stats: StatsCache) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Daily Activity")
            DailyActivityChart(stats: stats)
        }
    }

    // MARK: - Hourly Chart

    private func hourlyChartSection(_ stats: StatsCache) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Hourly Distribution")
            HourlyDistributionChart(stats: stats)
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
