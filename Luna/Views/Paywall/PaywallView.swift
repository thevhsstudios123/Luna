import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var plan: Plan = .yearly

    enum Plan { case monthly, yearly }

    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Spacer()
                    Button("close") { dismiss() }
                        .font(LunaType.bodyS)
                        .foregroundStyle(appState.theme.textSecondary)
                }

                HStack(spacing: -8) {
                    MoonAvatar(phase: .follicular).frame(width: 80, height: 80)
                    BrainAvatar(state: .sharp).frame(width: 80, height: 80)
                    HeartAvatar(state: .full).frame(width: 80, height: 80)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    Text(voice.paywallHeadline)
                        .font(LunaType.displayXL)
                        .foregroundStyle(appState.theme.textPrimary)
                    Text(voice.paywallSub)
                        .font(LunaType.bodyL)
                        .foregroundStyle(appState.theme.textSecondary)
                }

                VStack(spacing: 12) {
                    PlanRow(title: "yearly", sub: "$59.99 / year • \u{2248}$5/mo", flag: "save 50%", isSelected: plan == .yearly) { plan = .yearly }
                    PlanRow(title: "monthly", sub: "$9.99 / month", flag: nil, isSelected: plan == .monthly) { plan = .monthly }
                }

                SoftButton(title: "start with luna") { unlock() }
                Button("not right now") { dismiss() }
                    .font(LunaType.bodyS)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity)

                Text("cancel anytime. your data stays yours.")
                    .font(LunaType.metaM)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 30)
            }
            .padding(20)
        }
        .themedBackground()
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
