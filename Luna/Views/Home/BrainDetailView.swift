import SwiftUI

// Screen time / clarity detail. Reads from PassiveProvider so it's not faked
// when the user lands here — once HealthProvider is wired, the same UI works.
struct BrainDetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var snapshot: PassiveSnapshot = .empty
    private let passive: PassiveProvider = MockPassiveProvider()

    private var hours: Double { snapshot.screenTimeHours ?? 0 }
    private var sleep: Double? { snapshot.sleepHoursLastNight }
    private var steps: Int? { snapshot.stepsToday }
    private var voice: VoicePack { VoicePack(tone: appState.voice) }

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

                if sleep != nil || steps != nil {
                    SoftCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("the rest of you")
                                .font(LunaType.metaM.weight(.semibold))
                                .foregroundStyle(appState.theme.textSecondary)
                                .textCase(.uppercase)
                            HStack(spacing: 16) {
                                if let s = sleep {
                                    StatTile(label: "sleep", value: "\(String(format: "%.1f", s))h")
                                }
                                if let st = steps {
                                    StatTile(label: "steps", value: "\(st)")
                                }
                            }
                        }
                    }
                }

                SoftCard(tint: LunaColors.accentSoft.opacity(0.25)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("the seam")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text("these numbers come from luna's mock provider for now. plug HealthProvider in and the same view shows your real data.")
                            .font(LunaType.bodyM)
                            .foregroundStyle(appState.theme.textPrimary)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("clarity")
        .navigationBarTitleDisplayMode(.inline)
        .task { snapshot = await passive.snapshot() }
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
