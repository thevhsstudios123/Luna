import SwiftUI

// Paywall reframed: leads with the unique value (relationship lens) and an emotional
// scene, not a feature checklist. Features are shown second, as proof, not pitch.
struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var plan: Plan = .yearly
    @State private var heartReact = 0

    enum Plan { case monthly, yearly }

    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                topBar

                // The hero — the relationship lens dramatized in one card.
                heroScene

                // Editorial pitch (relationship lens first, by design).
                VStack(alignment: .leading, spacing: 14) {
                    Text(headlineCopy)
                        .font(LunaType.displayXL)
                        .foregroundStyle(appState.theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subCopy)
                        .font(LunaType.bodyL)
                        .foregroundStyle(appState.theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // What you also get — quiet supporting list, not the main attraction.
                VStack(alignment: .leading, spacing: 10) {
                    Text("you'll also get")
                        .font(LunaType.metaM.weight(.semibold))
                        .foregroundStyle(appState.theme.textSecondary)
                        .textCase(.uppercase)
                    bullet("the full emotional forecast — daily, weekly, monthly")
                    bullet("pattern recognition that compounds over time")
                    bullet("shareable cards and your year in review")
                    bullet("all three aesthetic themes")
                }

                VStack(spacing: 12) {
                    PlanRow(title: "yearly", sub: "$59.99 / year • \u{2248}$5/mo", flag: "save 50%", isSelected: plan == .yearly) { plan = .yearly }
                    PlanRow(title: "monthly", sub: "$9.99 / month", flag: nil, isSelected: plan == .monthly) { plan = .monthly }
                }

                SoftButton(title: ctaCopy) { unlock() }

                Button("not right now") { dismiss() }
                    .font(LunaType.bodyS)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity)

                Text("cancel anytime. your data stays yours, on your device.")
                    .font(LunaType.metaM)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 30)
            }
            .padding(20)
        }
        .themedBackground()
        .onAppear {
            // Stage the heart's react so the hero feels alive.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { heartReact += 1 }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button("close") { dismiss() }
                .font(LunaType.bodyS)
                .foregroundStyle(appState.theme.textSecondary)
        }
    }

    // The hero scene: a Heart avatar with a "drained" state and a faint name
    // beside it — telling the story of a relationship costing the user. Premium
    // is what shows her this pattern instead of letting it stay invisible.
    private var heroScene: some View {
        SoftCard(tint: LunaColors.accentBold.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 14) {
                    HeartAvatar(state: .armored, reactTrigger: heartReact, reactKind: .sideEye)
                        .frame(width: 72, height: 72)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("someone in your life")
                            .font(LunaType.bodyS.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                        Text("costs you, every time")
                            .font(LunaType.displayS)
                            .foregroundStyle(appState.theme.textPrimary)
                    }
                }
                Text(heroLine)
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var heroLine: String {
        switch appState.voice {
        case .soft:     return "luna can show you which relationships drain you and which lift you. gentle data. quietly life-changing."
        case .balanced: return "the relationship lens shows mood deltas per person across cycles. it surfaces the people who consistently lower you — and the ones who lift you. that's the whole point."
        case .savage:   return "the lens is the part that says, with receipts: \"every time you see him, your mood drops for two days.\" you knew. now you know."
        }
    }

    private var headlineCopy: String {
        switch appState.voice {
        case .soft:     return "see who you become around the people in your life."
        case .balanced: return "the relationship lens, fully open."
        case .savage:   return "stop guessing. the lens is the truth."
        }
    }

    private var subCopy: String {
        switch appState.voice {
        case .soft:     return "your cycle, your mood, and the people you love — connected, gently, in one honest picture."
        case .balanced: return "premium unlocks the relationship lens, full forecasts, and pattern recognition that compounds with every check-in."
        case .savage:   return "the data you've already given luna becomes useful when she's allowed to look at all of it. that's premium."
        }
    }

    private var ctaCopy: String {
        switch appState.voice {
        case .soft:     return "begin"
        case .balanced: return "open the lens"
        case .savage:   return "let me see"
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(appState.theme.accent).frame(width: 6, height: 6).padding(.top, 8)
            Text(text)
                .font(LunaType.bodyM)
                .foregroundStyle(appState.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func unlock() {
        // TODO: wire to StoreKit 2. For prototype, flip the flag.
        appState.isPremium = true
        Haptics.success()
        dismiss()
    }
}

struct PlanRow: View {
    var title: String
    var sub: String
    var flag: String?
    var isSelected: Bool
    var action: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: { Haptics.selection(); action() }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                        if let flag {
                            Text(flag)
                                .font(LunaType.metaS.weight(.semibold))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(LunaColors.success.opacity(0.25)))
                                .foregroundStyle(LunaColors.success)
                        }
                    }
                    Text(sub).font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                }
                Spacer()
                Circle().stroke(appState.theme.textSecondary.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle().fill(appState.theme.accent).frame(width: 12, height: 12).opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isSelected ? LunaColors.accentSoft.opacity(0.3) : appState.theme.bgSecondary))
        }
        .buttonStyle(.plain)
    }
}
