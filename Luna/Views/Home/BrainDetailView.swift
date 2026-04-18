import SwiftUI

// Screen time / clarity detail — hooks to HealthKit later via HealthProvider.
struct BrainDetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var hours: Double = 4.2

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BrainAvatar(state: BrainState.from(hours: hours))
                    .frame(width: 160, height: 160)
                    .frame(maxWidth: .infinity)

                Text("\(String(format: "%.1f", hours)) hours")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("screen time, today")
                    .font(LunaType.bodyM)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                SoftCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("what this means")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text(copyFor(hours: hours))
                            .font(LunaType.bodyL)
                            .foregroundStyle(appState.theme.textPrimary)
                    }
                }

                SoftCard(tint: LunaColors.accentSoft.opacity(0.25)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("coming soon")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text("plug in screen time for real numbers. until then, this is a hand-wave.")
                            .font(LunaType.bodyM)
                            .foregroundStyle(appState.theme.textPrimary)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("clarity")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func copyFor(hours: Double) -> String {
        switch BrainState.from(hours: hours) {
        case .sharp:  return "sharp. low noise, high signal. stay here if you can."
        case .okay:   return "middling. not bad, not great. go outside for 15."
        case .foggy:  return "you're in the fog. put the phone down and drink water."
        case .melted: return "melted. this is the melted brain of someone who needs sleep, not more content."
        }
    }
}
