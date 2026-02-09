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
