import SwiftUI
import SwiftData

struct PatternsView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \CheckIn.date) private var checkIns: [CheckIn]
    @Query(sort: \CycleEvent.date) private var events: [CycleEvent]
    @Query(sort: \Interaction.date) private var interactions: [Interaction]
    @Query private var profiles: [UserProfile]
    @State private var passive: PassiveSnapshot = .empty

    private let passiveProvider: PassiveProvider = MockPassiveProvider()

    private var voice: VoicePack {
        VoicePack(tone: AdaptiveVoice.resolved(userVoice: appState.voice,
                                               recentCheckIns: checkIns.reversed(),
                                               alwaysHonorUserVoice: appState.alwaysHonorVoice))
    }

    // Combine deterministic + early + personal-baseline insights into one list.
    private var insights: [PatternInsight] {
        var all = PatternEngine.insights(
            checkIns: checkIns,
            events: events,
            interactions: interactions,
            profile: profiles.first,
            voice: voice)
        all.append(contentsOf: EarlyInsights.generate(
            checkIns: checkIns,
            passive: passive,
            profile: profiles.first,
            voice: voice))
        if let baselineInsight = baselineInsight() { all.append(baselineInsight) }
        return all
    }

    private func baselineInsight() -> PatternInsight? {
        guard let profile = profiles.first, let latest = checkIns.last else { return nil }
        let baseline = PersonalBaselineEngine.compute(
            checkIns: checkIns,
            cycleLength: profile.averageCycleLength,
            lastPeriod: profile.lastPeriodStart)
        guard baseline.isBelowBaseline(mood: latest.mood) else { return nil }
        return PatternInsight(
            title: "below your own baseline",
            body: voice.belowBaseline(today: latest.mood, baseline: baseline.avgMood),
            kindRaw: "personal_baseline",
            severity: .heads_up)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if !appState.isPremium {
                    PremiumTeaser()
                }

                if insights.isEmpty {
                    EmptyStateCard(title: "patterns bloom with time",
                                   message: voice.emptyPatterns)
                } else {
                    VStack(spacing: 14) {
                        ForEach(insights) { insight in
                            InsightCard(insight: insight)
                        }
                    }
                }

                NavigationLink(destination: HealingReceiptsView()) {
                    SoftCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("healing receipts")
                                    .font(LunaType.displayS)
                                    .foregroundStyle(appState.theme.textPrimary)
                                Text("proof you've been showing up")
                                    .font(LunaType.bodyS)
                                    .foregroundStyle(appState.theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right").foregroundStyle(appState.theme.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer(minLength: 120)
            }
            .padding(20)
        }
        .navigationTitle("patterns")
        .navigationBarTitleDisplayMode(.inline)
        .task { passive = await passiveProvider.snapshot() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("patterns")
                .font(LunaType.metaM.weight(.semibold))
                .foregroundStyle(appState.theme.textSecondary)
                .textCase(.uppercase)
            Text("your mirror, over time")
                .font(LunaType.displayL)
                .foregroundStyle(appState.theme.textPrimary)
        }
    }
}

struct InsightCard: View {
    var insight: PatternInsight
    @EnvironmentObject var appState: AppState

    var body: some View {
        SoftCard(tint: tint) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(insight.title)
                        .font(LunaType.metaM.weight(.semibold))
                        .foregroundStyle(appState.theme.textSecondary)
                        .textCase(.uppercase)
                    Spacer()
                    ShareBadge()
                }
                Text(insight.body)
                    .font(LunaType.displayS)
                    .foregroundStyle(appState.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var tint: Color? {
        switch insight.severity {
        case .celebrate: return LunaColors.success.opacity(0.18)
        case .heads_up: return LunaColors.accentSoft.opacity(0.3)
        case .note: return nil
        case .gentle: return LunaColors.accentWarm.opacity(0.15)
        }
    }
}

struct ShareBadge: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        Text("shareable")
            .font(LunaType.metaS.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(appState.theme.textSecondary)
            .background(Capsule().fill(Color.white.opacity(0.4)))
    }
}

struct EmptyStateCard: View {
    var title: String
    var message: String
    @EnvironmentObject var appState: AppState
    var body: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(LunaType.displayS)
                    .foregroundStyle(appState.theme.textPrimary)
                Text(message)
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textSecondary)
            }
        }
    }
}

struct PremiumTeaser: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaywall = false
    var body: some View {
        Button { showPaywall = true } label: {
            SoftCard(tint: LunaColors.accentBold.opacity(0.1)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("unlock the full mirror")
                            .font(LunaType.displayS)
                            .foregroundStyle(appState.theme.textPrimary)
                        Text("forecasts, patterns, relationships, themes.")
                            .font(LunaType.bodyS)
                            .foregroundStyle(appState.theme.textSecondary)
                    }
                    Spacer()
                    Text("see")
                        .font(LunaType.bodyS.weight(.semibold))
                        .foregroundStyle(appState.theme.accent)
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }
}

struct HealingReceiptsView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \CheckIn.date) private var checkIns: [CheckIn]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if checkIns.count < 7 {
                    EmptyStateCard(title: "receipts coming",
                                   message: "a few weeks in, this page will stun you.")
                } else {
                    ReceiptCard(icon: "🌱", title: "showed up \(checkIns.count) times",
                                message: "you chose to know yourself \(checkIns.count) days over.")
                    if checkIns.count >= 30 {
                        ReceiptCard(icon: "🌕", title: "first cycle logged",
                                    message: "one full lap around your own rhythm. worth marking.")
                    }
                    if checkIns.count >= 60 {
                        ReceiptCard(icon: "📈", title: "two cycles of self-data",
                                    message: "your patterns are now actually patterns.")
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("healing receipts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReceiptCard: View {
    var icon: String
    var title: String
    var message: String
    @EnvironmentObject var appState: AppState
    var body: some View {
        SoftCard {
            HStack(alignment: .top, spacing: 14) {
                Text(icon).font(.system(size: 40))
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                    Text(message).font(LunaType.bodyM).foregroundStyle(appState.theme.textSecondary)
                }
            }
        }
    }
}
