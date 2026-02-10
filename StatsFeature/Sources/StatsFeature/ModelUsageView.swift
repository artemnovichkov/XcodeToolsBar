import SwiftUI
import StatsClient

struct ModelUsageView: View {
    let stats: StatsCache

    private var sortedModelNames: [String] {
        stats.modelUsage.keys.sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Models")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            VStack(spacing: 4) {
                ForEach(sortedModelNames, id: \.self) { name in
                    if let usage = stats.modelUsage[name] {
                        let totalTokens = usage.inputTokens + usage.outputTokens + usage.cacheReadInputTokens
                        HStack {
                            Text(shortModelName(name))
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

    private func shortModelName(_ name: String) -> String {
        let parts = name.split(separator: "-")
        guard parts.count >= 4, parts[0] == "claude" else { return name }
        let family = parts[1].capitalized
        let version = "\(parts[2]).\(parts[3])"
        return "\(family) \(version)"
    }
}
