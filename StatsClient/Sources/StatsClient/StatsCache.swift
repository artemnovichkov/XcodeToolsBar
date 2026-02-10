import Foundation

public struct StatsCache: Decodable, Sendable {
    public let version: Int
    public let lastComputedDate: Date
    public let dailyActivity: [DailyActivity]
    public let dailyModelTokens: [DailyModelTokens]
    public let modelUsage: [String: ModelUsage]
    public let totalSessions: Int
    public let totalMessages: Int
    public let longestSession: LongestSession
    public let firstSessionDate: Date
    public let hourCounts: [String: Int]
    public let totalSpeculationTimeSavedMs: Int?
}

public struct DailyActivity: Decodable, Identifiable, Sendable {
    public let date: Date
    public let messageCount: Int
    public let sessionCount: Int
    public let toolCallCount: Int

    public var id: Date { date }

    public init(date: Date, messageCount: Int, sessionCount: Int, toolCallCount: Int) {
        self.date = date
        self.messageCount = messageCount
        self.sessionCount = sessionCount
        self.toolCallCount = toolCallCount
    }
}

public struct DailyModelTokens: Decodable, Sendable {
    public let date: Date
    public let tokensByModel: [String: Int]
}

public struct ModelUsage: Decodable, Sendable {
    public let inputTokens: Int
    public let outputTokens: Int
    public let cacheReadInputTokens: Int
    public let cacheCreationInputTokens: Int
    public let webSearchRequests: Int
    public let costUSD: Double
    public let contextWindow: Int?
    public let maxOutputTokens: Int?
}

public struct LongestSession: Decodable, Sendable {
    public let sessionId: String
    public let duration: Int
    public let messageCount: Int
    public let timestamp: Date
}
