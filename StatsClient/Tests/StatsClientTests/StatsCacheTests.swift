import Testing
import Foundation
import StatsClient

@Suite("StatsCache Parsing Tests")
struct StatsCacheTests {

    @Test("Decodes complete stats cache JSON")
    func decodesCompleteJSON() throws {
        let json = """
        {
          "version": 1,
          "lastComputedDate": "2026-02-06",
          "dailyActivity": [
            {
              "date": "2026-02-03",
              "messageCount": 92,
              "sessionCount": 8,
              "toolCallCount": 16
            }
          ],
          "dailyModelTokens": [
            {
              "date": "2026-02-03",
              "tokensByModel": {
                "claude-sonnet-4-5-20250929": 239
              }
            }
          ],
          "modelUsage": {
            "claude-sonnet-4-5-20250929": {
              "inputTokens": 812,
              "outputTokens": 1642,
              "cacheReadInputTokens": 5847967,
              "cacheCreationInputTokens": 628182,
              "webSearchRequests": 0,
              "costUSD": 0
            }
          },
          "totalSessions": 49,
          "totalMessages": 600,
          "longestSession": {
            "sessionId": "a8e22546-4ece-44b7-adb2-108eca427356",
            "duration": 454137,
            "messageCount": 137,
            "timestamp": "2026-02-04T12:43:16.754Z"
          },
          "firstSessionDate": "2026-02-03T20:00:24.138Z",
          "hourCounts": {
            "1": 8,
            "14": 1
          },
          "totalSpeculationTimeSavedMs": 0
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try StatsCache.decode(from: data)

        #expect(stats.version == 1)
        #expect(stats.totalSessions == 49)
        #expect(stats.totalMessages == 600)
        #expect(stats.dailyActivity.count == 1)
        #expect(stats.dailyActivity[0].messageCount == 92)
        #expect(stats.longestSession.duration == 454137)
    }

    @Test("Decodes date-only format (yyyy-MM-dd)")
    func decodesDateOnlyFormat() throws {
        let json = """
        {
          "version": 1,
          "lastComputedDate": "2026-02-06",
          "dailyActivity": [],
          "dailyModelTokens": [],
          "modelUsage": {},
          "totalSessions": 0,
          "totalMessages": 0,
          "longestSession": {
            "sessionId": "test",
            "duration": 0,
            "messageCount": 0,
            "timestamp": "2026-02-04T12:43:16.754Z"
          },
          "firstSessionDate": "2026-02-03T20:00:24.138Z",
          "hourCounts": {},
          "totalSpeculationTimeSavedMs": 0
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try StatsCache.decode(from: data)

        let calendar = Calendar.current
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: stats.lastComputedDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 6)
    }

    @Test("Decodes ISO8601 with fractional seconds")
    func decodesISO8601WithFractionalSeconds() throws {
        let json = """
        {
          "version": 1,
          "lastComputedDate": "2026-02-06",
          "dailyActivity": [],
          "dailyModelTokens": [],
          "modelUsage": {},
          "totalSessions": 0,
          "totalMessages": 0,
          "longestSession": {
            "sessionId": "test",
            "duration": 0,
            "messageCount": 0,
            "timestamp": "2026-02-04T12:43:16.754Z"
          },
          "firstSessionDate": "2026-02-03T20:00:24.138Z",
          "hourCounts": {},
          "totalSpeculationTimeSavedMs": 0
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try StatsCache.decode(from: data)

        let calendar = Calendar.current
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: stats.firstSessionDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 3)
        #expect(components.hour == 20)
        #expect(components.minute == 0)
    }

    @Test("Decodes daily activity dates")
    func decodesDailyActivityDates() throws {
        let json = """
        {
          "version": 1,
          "lastComputedDate": "2026-02-06",
          "dailyActivity": [
            {"date": "2026-02-03", "messageCount": 10, "sessionCount": 1, "toolCallCount": 5},
            {"date": "2026-02-04", "messageCount": 20, "sessionCount": 2, "toolCallCount": 10}
          ],
          "dailyModelTokens": [],
          "modelUsage": {},
          "totalSessions": 0,
          "totalMessages": 0,
          "longestSession": {"sessionId": "t", "duration": 0, "messageCount": 0, "timestamp": "2026-02-04T00:00:00.000Z"},
          "firstSessionDate": "2026-02-03T00:00:00.000Z",
          "hourCounts": {},
          "totalSpeculationTimeSavedMs": 0
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try StatsCache.decode(from: data)

        #expect(stats.dailyActivity.count == 2)

        let calendar = Calendar.current
        let firstDay = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: stats.dailyActivity[0].date)
        #expect(firstDay.day == 3)

        let secondDay = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: stats.dailyActivity[1].date)
        #expect(secondDay.day == 4)
    }

    @Test("Decodes model usage")
    func decodesModelUsage() throws {
        let json = """
        {
          "version": 1,
          "lastComputedDate": "2026-02-06",
          "dailyActivity": [],
          "dailyModelTokens": [],
          "modelUsage": {
            "claude-sonnet": {"inputTokens": 100, "outputTokens": 200, "cacheReadInputTokens": 300, "cacheCreationInputTokens": 400, "webSearchRequests": 5, "costUSD": 1.5}
          },
          "totalSessions": 0,
          "totalMessages": 0,
          "longestSession": {"sessionId": "t", "duration": 0, "messageCount": 0, "timestamp": "2026-02-04T00:00:00.000Z"},
          "firstSessionDate": "2026-02-03T00:00:00.000Z",
          "hourCounts": {},
          "totalSpeculationTimeSavedMs": 0
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try StatsCache.decode(from: data)

        let usage = stats.modelUsage["claude-sonnet"]
        #expect(usage?.inputTokens == 100)
        #expect(usage?.outputTokens == 200)
        #expect(usage?.cacheReadInputTokens == 300)
        #expect(usage?.cacheCreationInputTokens == 400)
        #expect(usage?.webSearchRequests == 5)
        #expect(usage?.costUSD == 1.5)
    }
}
