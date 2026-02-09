import Foundation
import Observation

@Observable
final class StatsViewModel {

    private(set) var stats: StatsCache?
    private(set) var error: String?

    private var fileMonitor: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    private static let statsPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/stats-cache.json"
    }()

    init() {
        loadStats()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Computed Properties

    var daysSinceFirstSession: Int? {
        guard let firstDate = stats?.firstSessionDate else { return nil }
        return Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day
    }

    var formattedLongestSessionDuration: String? {
        guard let duration = stats?.longestSession.duration else { return nil }
        let totalSeconds = duration / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var longestSessionDate: String? {
        guard let date = stats?.longestSession.timestamp else { return nil }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        return display.string(from: date)
    }

    var peakHour: String? {
        guard let hourCounts = stats?.hourCounts,
              let maxEntry = hourCounts.max(by: { $0.value < $1.value }),
              let hour = Int(maxEntry.key) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(hour: hour))!
        return formatter.string(from: date).lowercased()
    }

    var sortedModelNames: [String] {
        stats?.modelUsage.keys.sorted() ?? []
    }

    var recentDailyActivity: [DailyActivity] {
        let activities = stats?.dailyActivity ?? []
        return Array(activities.suffix(14))
    }

    var sortedHourCounts: [(hour: Int, count: Int)] {
        guard let hourCounts = stats?.hourCounts else { return [] }
        return hourCounts
            .compactMap { key, value in
                guard let hour = Int(key) else { return nil }
                return (hour: hour, count: value)
            }
            .sorted { $0.hour < $1.hour }
    }

    // MARK: - Loading

    func loadStats() {
        let path = Self.statsPath
        guard FileManager.default.fileExists(atPath: path) else {
            stats = nil
            error = "No stats file found"
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            stats = try StatsCache.decode(from: data)
            error = nil
        } catch {
            self.error = "Unable to read stats"
            stats = nil
        }
    }

    // MARK: - File Monitoring

    private func startMonitoring() {
        let path = Self.statsPath
        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.loadStats()
        }

        source.setCancelHandler { [weak self] in
            guard let self else { return }
            close(self.fileDescriptor)
            self.fileDescriptor = -1
        }

        source.resume()
        fileMonitor = source
    }

    private func stopMonitoring() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }

    // MARK: - Helpers

    func shortModelName(_ name: String) -> String {
        let parts = name.split(separator: "-")
        guard parts.count >= 4, parts[0] == "claude" else { return name }
        let family = parts[1].capitalized
        let version = "\(parts[2]).\(parts[3])"
        return "\(family) \(version)"
    }

    func formatTokenCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}
