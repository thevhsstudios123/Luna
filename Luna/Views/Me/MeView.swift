import SwiftUI
import SwiftData

struct MeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }
    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .center, spacing: 14) {
                    MoonAvatar(phase: .ovulation).frame(width: 64, height: 64)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile?.name ?? "friend")
                            .font(LunaType.displayL)
                            .foregroundStyle(appState.theme.textPrimary)
                        if let bday = profile?.birthday {
                            Text("since \(bday.monthDay.lowercased())")
                                .font(LunaType.bodyS)
                                .foregroundStyle(appState.theme.textSecondary)
                        }
                    }
                }

                if !appState.isPremium {
                    NavigationLink(destination: PaywallView()) {
                        SoftCard(tint: LunaColors.accentBold.opacity(0.15)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(voice.paywallHeadline).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                                    Text("unlock the full mirror").font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "sparkle").foregroundStyle(appState.theme.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                header("voice & look")
                NavigationLink("voice preference") { VoiceSettingsView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)
                NavigationLink("theme") { ThemeSettingsView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)
                NavigationLink("seasons") { SeasonsView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)

                header("data")
                NavigationLink("cycle info") { ProfileSettingsView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)
                NavigationLink("export data") { ExportView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)

                header("privacy")
                Toggle("app lock", isOn: Binding(get: { appState.appLockEnabled }, set: { appState.appLockEnabled = $0 }))
                    .font(LunaType.bodyL)
                    .padding(16).background(sectionBG)
                Toggle("stealth mode (calculator disguise)", isOn: Binding(get: { appState.stealthMode }, set: { appState.stealthMode = $0 }))
                    .font(LunaType.bodyL)
                    .padding(16).background(sectionBG)
                NavigationLink("panic delete") { PanicDeleteView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)

                header("notifications")
                NavigationLink("notification preferences") { NotificationSettingsView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)

                header("share")
                NavigationLink("shareable outputs") { ShareView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)

                header("about")
                NavigationLink("about luna") { AboutView() }
                    .foregroundStyle(appState.theme.textPrimary)
                    .font(LunaType.bodyL)
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(sectionBG)

                Spacer(minLength: 120)
            }
            .padding(20)
        }
        .navigationTitle("me")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func header(_ title: String) -> some View {
        Text(title)
            .font(LunaType.metaM.weight(.semibold))
            .foregroundStyle(appState.theme.textSecondary)
            .textCase(.uppercase)
            .padding(.top, 10)
    }

    private var sectionBG: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous).fill(appState.theme.bgSecondary)
    }
}

struct ProfileSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let p = profiles.first {
                    SoftCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("name").font(LunaType.metaM).foregroundStyle(appState.theme.textSecondary)
                            TextField("name", text: Binding(get: { p.name }, set: { p.name = $0; appState.displayName = $0 }))
                                .font(LunaType.bodyL)
                        }
                    }
                    SoftCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("cycle length").font(LunaType.metaM).foregroundStyle(appState.theme.textSecondary)
                            HStack {
                                Text("\(p.averageCycleLength) days").font(LunaType.bodyL)
                                Spacer()
                                Stepper("", value: Binding(get: { p.averageCycleLength }, set: { p.averageCycleLength = $0 }), in: 21...45)
                                    .labelsHidden()
                            }
                        }
                    }
                    SoftCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("last period start").font(LunaType.metaM).foregroundStyle(appState.theme.textSecondary)
                            DatePicker("",
                                       selection: Binding(get: { p.lastPeriodStart ?? .now },
                                                          set: { p.lastPeriodStart = $0 }),
                                       displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("cycle info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VoiceSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("base voice")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                ForEach(VoiceTone.allCases) { v in
                    Button {
                        Haptics.selection()
                        appState.voice = v
                    } label: {
                        SoftCard(tint: appState.voice == v ? LunaColors.accentSoft.opacity(0.35) : nil) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(v.label).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                                Text(v.subtitle).font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text("intensity")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                    .padding(.top, 12)

                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("how loud is the voice")
                            .font(LunaType.bodyL.weight(.semibold))
                            .foregroundStyle(appState.theme.textPrimary)
                        // 5-level intensity dial. Doesn't change which voice — only how loud.
                        HStack(spacing: 8) {
                            ForEach(VoiceIntensity.allCases) { vi in
                                ChipButton(title: vi.label,
                                           isSelected: appState.voiceIntensity == vi) {
                                    appState.voiceIntensity = vi
                                }
                            }
                        }
                        Text("intensity changes how punchy each line lands. doesn't change which voice you picked.")
                            .font(LunaType.bodyS)
                            .foregroundStyle(appState.theme.textSecondary)
                    }
                }

                Text("safety rails")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                    .padding(.top, 12)

                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: Binding(get: { !appState.alwaysHonorVoice },
                                             set: { appState.alwaysHonorVoice = !$0 })) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("let luna read the room")
                                    .font(LunaType.bodyL.weight(.semibold))
                                    .foregroundStyle(appState.theme.textPrimary)
                                Text("when your recent moods are low, luna softens her tone automatically. you can override on the home screen.")
                                    .font(LunaType.bodyS)
                                    .foregroundStyle(appState.theme.textSecondary)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("voice")
    }
}

// New: the seasons (avatar evolution) view.
struct SeasonsView: View {
    @EnvironmentObject var appState: AppState
    @Query private var checkIns: [CheckIn]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("seasons")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)
                Text("luna evolves with you. seasons unlock by showing up — never by paying.")
                    .font(LunaType.bodyM)
                    .foregroundStyle(appState.theme.textSecondary)

                ForEach(Season.allCases) { season in
                    let unlocked = checkIns.count >= season.unlocksAtCheckIns
                    SoftCard(tint: appState.season == season ? LunaColors.accentSoft.opacity(0.3) : nil) {
                        HStack(spacing: 14) {
                            Circle().fill(season.avatarTint == .clear ? LunaColors.bgSecondary : season.avatarTint)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(LunaColors.textPrimary.opacity(0.08), lineWidth: 1))
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(season.label).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                                    if !unlocked {
                                        Text("locked")
                                            .font(LunaType.metaS.weight(.semibold))
                                            .padding(.horizontal, 7).padding(.vertical, 2)
                                            .background(Capsule().fill(LunaColors.bgSecondary))
                                            .foregroundStyle(LunaColors.textSecondary)
                                    }
                                }
                                Text(season.sub).font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                                Text(progressText(for: season))
                                    .font(LunaType.metaS)
                                    .foregroundStyle(appState.theme.textSecondary)
                            }
                            Spacer()
                            if unlocked {
                                Button(appState.season == season ? "active" : "use") {
                                    appState.season = season
                                    Haptics.selection()
                                }
                                .font(LunaType.bodyS.weight(.semibold))
                                .foregroundStyle(appState.theme.accent)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("seasons")
    }

    private func progressText(for season: Season) -> String {
        if checkIns.count >= season.unlocksAtCheckIns { return "unlocked" }
        let need = season.unlocksAtCheckIns - checkIns.count
        return "\(need) more check-ins to unlock"
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(LunaTheme.allCases) { t in
                    Button {
                        Haptics.selection()
                        appState.theme = t
                    } label: {
                        SoftCard(tint: appState.theme == t ? LunaColors.accentSoft.opacity(0.35) : nil) {
                            HStack(spacing: 12) {
                                HStack(spacing: -10) {
                                    Circle().fill(t.bgPrimary).frame(width: 24, height: 24).overlay(Circle().stroke(LunaColors.textPrimary.opacity(0.1)))
                                    Circle().fill(t.bgSecondary).frame(width: 24, height: 24).overlay(Circle().stroke(LunaColors.textPrimary.opacity(0.1)))
                                    Circle().fill(t.accent).frame(width: 24, height: 24).overlay(Circle().stroke(LunaColors.textPrimary.opacity(0.1)))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t.title).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                                    Text(t.subtitle).font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .navigationTitle("theme")
    }
}

struct NotificationSettingsView: View {
    @EnvironmentObject var appState: AppState
    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("morning forecast", isOn: Binding(get: { appState.notifyMorning }, set: { appState.notifyMorning = $0 }))
                            .font(LunaType.bodyL)
                        Toggle("pattern alerts", isOn: Binding(get: { appState.notifyPatterns }, set: { appState.notifyPatterns = $0 }))
                            .font(LunaType.bodyL)
                        Toggle("relationship nudges", isOn: Binding(get: { appState.notifyRelationships }, set: { appState.notifyRelationships = $0 }))
                            .font(LunaType.bodyL)
                    }
                }
                SoftButton(title: "request permission") {
                    Task {
                        let ok = await LunaNotifications.requestAuth()
                        if ok, appState.notifyMorning {
                            LunaNotifications.scheduleMorningForecast(body: voice.nudgeBigDecision(day: 1))
                        }
                    }
                }
                Text("notification copy matches your voice preference. changeable in settings.")
                    .font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
            }
            .padding(20)
        }
        .navigationTitle("notifications")
    }
}

struct ExportView: View {
    @Query private var profiles: [UserProfile]
    @Query private var checkIns: [CheckIn]
    @Query private var events: [CycleEvent]
    @Query private var interactions: [Interaction]
    @EnvironmentObject var appState: AppState
    @State private var shareText: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("export all your data as JSON.")
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textPrimary)
                SoftButton(title: "generate export") { shareText = makeJSON() }
                if let shareText {
                    SoftCard {
                        Text(shareText)
                            .font(LunaType.bodyS)
                            .foregroundStyle(appState.theme.textSecondary)
                            .frame(maxHeight: 240)
                            .textSelection(.enabled)
                    }
                    ShareLink(item: shareText) {
                        Text("share")
                            .font(LunaType.bodyL.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 18).fill(appState.theme.accent))
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("export")
    }

    private func makeJSON() -> String {
        struct Export: Codable {
            var profile: ProfileDTO?
            var checkIns: [CheckInDTO]
            var cycleEvents: [CycleEventDTO]
            var interactions: [InteractionDTO]
        }
        struct ProfileDTO: Codable { var name: String; var cycleLength: Int; var lastPeriodStart: Date? }
        struct CheckInDTO: Codable { var date: Date; var mood: Int; var energy: Int; var selfImage: Int; var tags: String; var journal: String }
        struct CycleEventDTO: Codable { var date: Date; var kind: String; var flow: String; var symptoms: String; var notes: String }
        struct InteractionDTO: Codable { var date: Date; var kind: String; var before: Int; var after: Int; var note: String; var personName: String? }

        let exp = Export(
            profile: profiles.first.map { ProfileDTO(name: $0.name, cycleLength: $0.averageCycleLength, lastPeriodStart: $0.lastPeriodStart) },
            checkIns: checkIns.map { CheckInDTO(date: $0.date, mood: $0.mood, energy: $0.energy, selfImage: $0.selfImage, tags: $0.tagsRaw, journal: $0.journal) },
            cycleEvents: events.map { CycleEventDTO(date: $0.date, kind: $0.kindRaw, flow: $0.flowRaw, symptoms: $0.symptomsRaw, notes: $0.notes) },
            interactions: interactions.map { InteractionDTO(date: $0.date, kind: $0.kindRaw, before: $0.moodBefore, after: $0.moodAfter, note: $0.note, personName: $0.person?.name) }
        )
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return (try? String(data: enc.encode(exp), encoding: .utf8)) ?? "{}"
    }
}

struct PanicDeleteView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var people: [Person]
    @Query private var interactions: [Interaction]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var confirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("panic delete")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)
                Text("one tap wipes everyone you've ever logged and every interaction with them. cycle data stays. this cannot be undone.")
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textPrimary)
                SoftCard(tint: LunaColors.alert.opacity(0.15)) {
                    Text("currently: \(people.count) people, \(interactions.count) interactions.")
                        .font(LunaType.bodyM)
                        .foregroundStyle(LunaColors.alert)
                }
                Toggle("i understand", isOn: $confirm).font(LunaType.bodyL)
                Button {
                    for p in people { modelContext.delete(p) }
                    for i in interactions { modelContext.delete(i) }
                    Haptics.warning()
                    dismiss()
                } label: {
                    Text("wipe everything")
                        .font(LunaType.bodyL.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 18).fill(LunaColors.alert))
                }
                .disabled(!confirm)
                .opacity(confirm ? 1 : 0.5)
            }
            .padding(20)
        }
        .navigationTitle("panic delete")
    }
}

struct AboutView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MoonAvatar(phase: .ovulation).frame(width: 100, height: 100).frame(maxWidth: .infinity)

                Text("luna")
                    .font(LunaType.displayXL)
                    .foregroundStyle(appState.theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("a best friend for your inner weather.")
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                SoftCard(tint: LunaColors.success.opacity(0.15)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("we never sell your data.")
                            .font(LunaType.displayS)
                            .foregroundStyle(appState.theme.textPrimary)
                        Text("everything lives on your device. when we add a backend, it will be end-to-end encrypted or it won't exist.")
                            .font(LunaType.bodyM)
                            .foregroundStyle(appState.theme.textSecondary)
                    }
                }

                NavigationLink("privacy policy") { PolicyView(kind: .privacy) }.padding(16).background(RoundedRectangle(cornerRadius: 14).fill(appState.theme.bgSecondary))
                NavigationLink("terms") { PolicyView(kind: .terms) }.padding(16).background(RoundedRectangle(cornerRadius: 14).fill(appState.theme.bgSecondary))

                Text("v0.1 • prototype")
                    .font(LunaType.metaM)
                    .foregroundStyle(appState.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
        }
        .navigationTitle("about")
    }
}

struct PolicyView: View {
    enum Kind { case privacy, terms }
    var kind: Kind
    var body: some View {
        ScrollView {
            Text(kind == .privacy ? "your data lives on your device. placeholder for the legal team." : "use luna with kindness. placeholder for the legal team.")
                .font(LunaType.bodyL)
                .padding(20)
        }
        .navigationTitle(kind == .privacy ? "privacy" : "terms")
    }
}
