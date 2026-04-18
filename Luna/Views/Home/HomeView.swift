import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @Query(sort: \Interaction.date, order: .reverse) private var interactions: [Interaction]

    @State private var showCheckIn = false
    @State private var tappedAvatar: AvatarTap? = nil
    @State private var reactCount = 0
    @State private var heartReactKind: HeartReact = .none
    @State private var passive: PassiveSnapshot = .empty
    @State private var community: CommunitySignal? = nil
    @State private var showPaywall = false

    private let passiveProvider: PassiveProvider = MockPassiveProvider()
    private let communityProvider: CommunitySignalProvider = MockCommunitySignalProvider()

    private var profile: UserProfile? { profiles.first }
    private var voice: VoicePack { VoicePack(tone: effectiveVoice) }

    // Adaptive voice — softens automatically when recent moods are low.
    private var effectiveVoice: VoiceTone {
        AdaptiveVoice.resolved(userVoice: appState.voice,
                               recentCheckIns: Array(checkIns),
                               alwaysHonorUserVoice: appState.alwaysHonorVoice)
    }

    private var currentDay: Int {
        CycleEngine.currentDay(lastPeriod: profile?.lastPeriodStart,
                               cycleLength: profile?.averageCycleLength ?? 28) ?? 1
    }
    private var phase: CyclePhase {
        CycleEngine.phase(forDay: currentDay, cycleLength: profile?.averageCycleLength ?? 28)
    }
    private var brainState: BrainState {
        BrainState.from(hours: passive.screenTimeHours ?? 4.0)
    }
    private var heartState: HeartState {
        let recent = interactions.prefix(5).map(\.moodDelta)
        guard !recent.isEmpty else { return .neutral }
        let avg = Double(recent.reduce(0, +)) / Double(recent.count)
        if avg <= -1.5 { return .armored }
        if avg < 0 { return .drained }
        if avg >= 1 { return .full }
        return .neutral
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                greeting
                if let line = AdaptiveVoice.adaptedDisclosure(userVoice: appState.voice, effective: effectiveVoice) {
                    voiceAdaptedNotice(line)
                }
                avatars
                forecastCard
                if let passiveLine = PassiveRead.headline(passive, voice: voice) {
                    passiveCard(passiveLine)
                }
                quickTiles
                if let community {
                    communityCard(community)
                }
                if !checkIns.isEmpty {
                    recentStrip
                }
                Spacer(minLength: 120)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(appState)
        }
        .sheet(item: $tappedAvatar) { tap in
            NavigationStack {
                switch tap.kind {
                case .moon: CycleView()
                case .brain: BrainDetailView()
                case .heart: RelationshipsView()
                }
            }
            .environmentObject(appState)
        }
        .onChange(of: interactions.count) { old, new in
            // Heart reacts based on the LAST interaction's delta.
            guard new > old, let latest = interactions.first else { return }
            heartReactKind = latest.moodDelta >= 1 ? .blush : (latest.moodDelta <= -1 ? .sideEye : .none)
            reactCount += 1
        }
        .onChange(of: checkIns.count) { _, count in
            appState.recomputeSeason(checkInCount: count)
        }
        .task { await refreshPassive() }
        .task { community = await communityProvider.signal(forCycleDay: currentDay, phase: phase, mood: checkIns.first?.mood) }
        .navigationBarHidden(true)
    }

    private func refreshPassive() async {
        passive = await passiveProvider.snapshot()
    }

    private var greeting: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Date.now.weekdayName.lowercased())
                    .font(LunaType.metaM)
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.lowercase)
                Text(voice.greeting(name: profile?.name ?? appState.displayName))
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(Date.now.monthDay.lowercased())
                    .font(LunaType.metaM)
                    .foregroundStyle(appState.theme.textSecondary)
                if appState.season != .dawn {
                    Text(appState.season.label.lowercased())
                        .font(LunaType.metaS.weight(.semibold))
                        .foregroundStyle(appState.theme.accent)
                }
            }
        }
    }

    private func voiceAdaptedNotice(_ line: String) -> some View {
        Button {
            Haptics.soft()
            appState.alwaysHonorVoice = true
        } label: {
            HStack(spacing: 8) {
                Circle().fill(LunaColors.accentWarm.opacity(0.5)).frame(width: 6, height: 6)
                Text(line)
                    .font(LunaType.metaM)
                    .foregroundStyle(appState.theme.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14).fill(appState.theme.bgSecondary))
        }
        .buttonStyle(.plain)
    }

    private var avatars: some View {
        HStack(alignment: .center, spacing: 12) {
            AvatarTile(title: "moon", sub: phase.label) {
                ZStack {
                    if appState.season != .dawn {
                        SoftGlow(color: appState.season.avatarTint)
                    }
                    MoonAvatar(phase: phase)
                }
            } onTap: {
                Haptics.tap()
                tappedAvatar = AvatarTap(kind: .moon)
            }

            AvatarTile(title: "brain", sub: brainState.label) {
                BrainAvatar(state: brainState)
            } onTap: {
                Haptics.tap()
                tappedAvatar = AvatarTap(kind: .brain)
            }

            AvatarTile(title: "heart", sub: heartState.label) {
                HeartAvatar(state: heartState, reactTrigger: reactCount, reactKind: heartReactKind)
            } onTap: {
                Haptics.tap()
                tappedAvatar = AvatarTap(kind: .heart)
            }
        }
        .frame(height: 180)
    }

    @ViewBuilder
    private var forecastCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("today's forecast")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                Text(forecastLine)
                    .font(LunaType.displayS)
                    .foregroundStyle(appState.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    PhaseBadge(phase: phase)
                    Text("day \(currentDay)")
                        .font(LunaType.metaM)
                        .foregroundStyle(appState.theme.textSecondary)
                    Spacer()
                    NavigationLink {
                        ForecastView()
                    } label: {
                        Text("this week")
                            .font(LunaType.bodyS.weight(.semibold))
                            .foregroundStyle(appState.theme.accent)
                    }
                }
            }
        }
    }

    private var forecastLine: String {
        switch phase {
        case .menstrual: return voice.menstrualToday(day: currentDay)
        case .follicular: return voice.follicularToday(day: currentDay)
        case .ovulation: return voice.ovulationToday(day: currentDay)
        case .luteal: return voice.lutealHeadsUp(day: currentDay)
        }
    }

    private func passiveCard(_ line: String) -> some View {
        SoftCard(tint: LunaColors.success.opacity(0.15)) {
            VStack(alignment: .leading, spacing: 6) {
                Text("what luna already knows")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                Text(line)
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func communityCard(_ signal: CommunitySignal) -> some View {
        let line = CommunityCopy.line(signal: signal, day: currentDay, mood: checkIns.first?.mood, voice: voice)
        return Group {
            if !line.isEmpty {
                SoftCard(tint: LunaColors.accentSoft.opacity(0.2)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("the quiet community")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text(line)
                            .font(LunaType.bodyL)
                            .foregroundStyle(appState.theme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("anonymous, aggregate. never your data, never theirs.")
                            .font(LunaType.metaS)
                            .foregroundStyle(appState.theme.textSecondary)
                    }
                }
            }
        }
    }

    private var quickTiles: some View {
        HStack(spacing: 12) {
            QuickTile(title: "check in", subtitle: "30 seconds", accent: LunaColors.accentSoft) {
                showCheckIn = true
            }
            NavigationLink {
                PatternsView()
            } label: {
                QuickTilePreview(title: "patterns", subtitle: "your mirror", accent: LunaColors.accentBold)
            }
            .buttonStyle(.plain)
        }
    }

    private var recentStrip: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("recent check-ins")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                HStack(spacing: 10) {
                    ForEach(checkIns.prefix(5)) { ci in
                        VStack(spacing: 6) {
                            MorphFace(value: ci.mood).frame(width: 34, height: 34)
                            Text(ci.date.monthDay.lowercased())
                                .font(LunaType.metaS)
                                .foregroundStyle(appState.theme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

struct AvatarTap: Identifiable {
    enum Kind { case moon, brain, heart }
    let id = UUID()
    let kind: Kind
}

struct AvatarTile<Content: View>: View {
    var title: String
    var sub: String
    @ViewBuilder var content: () -> Content
    var onTap: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 2) {
                    Text(title)
                        .font(LunaType.metaS.weight(.semibold))
                        .foregroundStyle(appState.theme.textSecondary)
                        .textCase(.lowercase)
                    Text(sub)
                        .font(LunaType.bodyS.weight(.medium))
                        .foregroundStyle(appState.theme.textPrimary)
                }
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(appState.theme.bgSecondary)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PhaseBadge: View {
    var phase: CyclePhase
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(phase.color).frame(width: 8, height: 8)
            Text(phase.label)
                .font(LunaType.metaM)
                .foregroundStyle(phase.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(phase.color.opacity(0.15)))
    }
}

struct QuickTile: View {
    var title: String
    var subtitle: String
    var accent: Color
    var action: () -> Void
    var body: some View {
        Button {
            Haptics.soft()
            action()
        } label: {
            QuickTilePreview(title: title, subtitle: subtitle, accent: accent)
        }
        .buttonStyle(.plain)
    }
}

struct QuickTilePreview: View {
    var title: String
    var subtitle: String
    var accent: Color
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Circle().fill(accent).frame(width: 10, height: 10)
            Text(title)
                .font(LunaType.displayS)
                .foregroundStyle(appState.theme.textPrimary)
            Text(subtitle)
                .font(LunaType.bodyS)
                .foregroundStyle(appState.theme.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(appState.theme.bgSecondary))
    }
}
