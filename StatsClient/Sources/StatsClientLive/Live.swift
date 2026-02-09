import Foundation
import StatsClient

extension StatsClient {
    public static var live: StatsClient {
        StatsClient(
            loadStats: {
                guard FileManager.default.fileExists(atPath: statsPath) else {
                    throw Error.fileNotFound
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: statsPath))
                return try JSONDecoder.statsDecoder.decode(StatsCache.self, from: data)
            },
            startMonitoring: { eventHandler in
                let path = Self.statsPath
                var fileDescriptor = open(path, O_EVTONLY)
                if fileDescriptor == -1 {
                    return
                }

                let source = DispatchSource.makeFileSystemObjectSource(
                    fileDescriptor: fileDescriptor,
                    eventMask: .write,
                    queue: .main
                )

                source.setEventHandler(handler: eventHandler)

                source.setCancelHandler {
                    close(fileDescriptor)
                    fileDescriptor = -1
                }

                source.resume()
            }
        )
    }
}

private extension JSONDecoder {
    public static let statsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            // Fallback to date-only format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(dateString)"
            )
        }
        return decoder
    }()
}
