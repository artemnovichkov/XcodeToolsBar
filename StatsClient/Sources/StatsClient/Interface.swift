//
//  StatsClient.swift
//  StatsClient
//
//  Created by Artem Novichkov on 09.02.2026.
//

import Foundation

public struct StatsClient: Sendable {
    public enum Error: Swift.Error {
        case fileNotFound
    }

    public static var statsPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/stats-cache.json"
    }

    public var loadStats: @Sendable () throws -> StatsCache?
    public var startMonitoring: @Sendable (@escaping @Sendable () -> Void) -> Void

    public init(
        loadStats: @escaping @Sendable () throws -> StatsCache?,
        startMonitoring: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void
    ) {
        self.loadStats = loadStats
        self.startMonitoring = startMonitoring
    }
}

extension StatsClient {
    public static var empty: StatsClient {
        StatsClient(
            loadStats: { throw Error.fileNotFound },
            startMonitoring: { _ in }
        )
    }

    public static var happyPath: StatsClient {
        StatsClient(
            loadStats: { .mock },
            startMonitoring: { _ in }
        )
    }
}

private extension StatsCache {
    static var mock: StatsCache {
        let calendar = Calendar.current
        let today = Date()

        let dailyActivity = (0..<14).map { daysAgo in
            DailyActivity(
                date: calendar.date(byAdding: .day, value: -daysAgo, to: today)!,
                messageCount: Int.random(in: 10...100),
                sessionCount: Int.random(in: 1...10),
                toolCallCount: Int.random(in: 5...50)
            )
        }.reversed()

        let dailyModelTokens = (0..<14).map { daysAgo in
            DailyModelTokens(
                date: calendar.date(byAdding: .day, value: -daysAgo, to: today)!,
                tokensByModel: [
                    "claude-sonnet-4-20250514": Int.random(in: 10000...50000),
                    "claude-haiku-4-20250514": Int.random(in: 5000...20000)
                ]
            )
        }

        var hourCounts: [String: Int] = [:]
        for hour in 0..<24 {
            hourCounts[String(hour)] = Int.random(in: 0...50)
        }

        return StatsCache(
            version: 1,
            lastComputedDate: today,
            dailyActivity: Array(dailyActivity),
            dailyModelTokens: dailyModelTokens,
            modelUsage: [
                "claude-opus-4-5-20251101": ModelUsage(
                    inputTokens: 150000,
                    outputTokens: 45000,
                    cacheReadInputTokens: 80000,
                    cacheCreationInputTokens: 20000,
                    webSearchRequests: 5,
                    costUSD: 2.45,
                    contextWindow: 200000,
                    maxOutputTokens: 16000
                )
            ],
            totalSessions: 42,
            totalMessages: 567,
            longestSession: LongestSession(
                sessionId: "mock-session-123",
                duration: 7200,
                messageCount: 89,
                timestamp: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            firstSessionDate: calendar.date(byAdding: .day, value: -30, to: today)!,
            hourCounts: hourCounts,
            totalSpeculationTimeSavedMs: 125000
        )
    }
}
