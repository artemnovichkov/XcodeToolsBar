import SwiftUI

@main
struct XcodeToolsBarApp: App {
    var body: some Scene {
        MenuBarExtra("XcodeToolsBar", systemImage: "hammer.fill") {
            StatsView()
        }
        .menuBarExtraStyle(.window)
    }
}
