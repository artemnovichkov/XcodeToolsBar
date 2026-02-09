import Foundation
import Observation
import StatsClient
import StatsClientLive

@Observable
public final class StatsViewModel {
    public private(set) var stats: StatsCache?
    public private(set) var error: String?

    private var fileMonitor: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    private var statsClient: StatsClient

    public init(statsClient: StatsClient = .live) {
        self.statsClient = statsClient
        loadStats()
        startMonitoring()
    }

    // MARK: - Computed Properties

    public var daysSinceFirstSession: Int? {
        guard let firstDate = stats?.firstSessionDate else { return nil }
        return Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day
    }

    public var peakHourDate: Date? {
        guard let hourCounts = stats?.hourCounts,
              let maxEntry = hourCounts.max(by: { $0.value < $1.value }),
              let hour = Int(maxEntry.key) else { return nil }
        return Calendar.current.date(from: DateComponents(hour: hour))
    }

    public var sortedModelNames: [String] {
        stats?.modelUsage.keys.sorted() ?? []
    }

    public var recentDailyActivity: [DailyActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        let activities = stats?.dailyActivity ?? []

        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            if let match = activities.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                return match
            }
            return DailyActivity(date: day, messageCount: 0, sessionCount: 0, toolCallCount: 0)
        }
    }

    public var hasRecentActivity: Bool {
        recentDailyActivity.contains { $0.messageCount > 0 || $0.sessionCount > 0 || $0.toolCallCount > 0 }
    }

    public var sortedHourCounts: [(hour: Int, count: Int)] {
        guard let hourCounts = stats?.hourCounts else { return [] }
        return hourCounts
            .compactMap { key, value in
                guard let hour = Int(key) else { return nil }
                return (hour: hour, count: value)
            }
            .sorted { $0.hour < $1.hour }
    }

    // MARK: - Loading

    public func loadStats() {
        do {
            stats = try statsClient.loadStats()
        } catch {
            self.error = "Unable to read stats"
        }
    }

    // MARK: - File Monitoring

    private func startMonitoring() {
        statsClient.startMonitoring {
            self.loadStats()
        }
    }

    // MARK: - Helpers

    public func shortModelName(_ name: String) -> String {
        let parts = name.split(separator: "-")
        guard parts.count >= 4, parts[0] == "claude" else { return name }
        let family = parts[1].capitalized
        let version = "\(parts[2]).\(parts[3])"
        return "\(family) \(version)"
    }
}
