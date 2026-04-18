import SwiftUI
import SwiftData

// Multi-step, conversational onboarding. Every step is its own screen-sized card
// with a smooth cross-fade. No forms — it feels like texting a friend who listens.
struct OnboardingFlow: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var step = 0
    @State private var name = ""
    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -28, to: .now) ?? .now
    @State private var cycleLength: Int = 28
    @State private var currentDay: Int = 1
    @State private var reason: OnboardingReason = .curious
    @State private var voice: VoiceTone = .balanced

    private let lastStep = 7

    var body: some View {
        ZStack {
            appState.theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressBar(value: Double(step) / Double(lastStep))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                ScrollView {
                    VStack(spacing: 28) {
                        // Hero avatar anchors the whole flow so she feels present
                        MoonAvatar(phase: .follicular)
                            .frame(width: 120, height: 120)
                            .padding(.top, 24)

                        Group {
                            switch step {
                            case 0: welcome
                            case 1: askName
                            case 2: askBirthday
                            case 3: askCycleLength
                            case 4: askCurrentDay
                            case 5: askReason
                            case 6: askVoice
                            case 7: instantRead
                            default: EmptyView()
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }

                // Footer action
                footer
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .animation(.easeInOut(duration: 0.35), value: step)
        }
    }

    // MARK: - Steps
    private var voicePack: VoicePack { VoicePack(tone: voice) }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(voicePack.welcomeHeadline)
                .font(LunaType.displayXL)
                .foregroundStyle(LunaColors.textPrimary)
            Text(voicePack.welcomeSub)
                .font(LunaType.bodyL)
                .foregroundStyle(LunaColors.textSecondary)
            Text("2 minutes. no clinical quiz. no shame.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var askName: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("first — what do we call you?")
                .font(LunaType.displayL)
                .foregroundStyle(LunaColors.textPrimary)
            Text("no last names. no emails. just you.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
            TextField("your name", text: $name)
                .font(LunaType.bodyL)
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(LunaColors.bgSecondary))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
        }
    }

    private var askBirthday: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("when's your birthday, \(displayName)?")
                .font(LunaType.displayL)
                .foregroundStyle(LunaColors.textPrimary)
            Text("the stars are optional, but we'll use your age for nothing creepy.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
            DatePicker("", selection: $birthday, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(LunaColors.bgSecondary))
        }
    }

    private var askCycleLength: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("how long is your cycle, usually?")
                .font(LunaType.displayL)
                .foregroundStyle(LunaColors.textPrimary)
            Text("period day 1 to the next period day 1. ballpark is fine.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
            HStack(spacing: 8) {
                ForEach([21, 24, 26, 28, 30, 32, 35], id: \.self) { v in
                    ChipButton(title: "\(v)", isSelected: cycleLength == v) { cycleLength = v }
                }
            }
            Text("not sure? 28 is the textbook average and a fine place to start.")
                .font(LunaType.bodyS)
                .foregroundStyle(LunaColors.textSecondary)
        }
    }

    private var askCurrentDay: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("where are you right now in your cycle?")
                .font(LunaType.displayL)
                .foregroundStyle(LunaColors.textPrimary)
            Text("day 1 is the first day of your last period. best guess counts.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("day \(currentDay)")
                        .font(LunaType.displayM)
                        .foregroundStyle(LunaColors.textPrimary)
                    Spacer()
                    Text(CycleEngine.phase(forDay: currentDay, cycleLength: cycleLength).label)
                        .font(LunaType.bodyS)
                        .foregroundStyle(CycleEngine.phase(forDay: currentDay, cycleLength: cycleLength).color)
                }
                Slider(value: Binding(get: { Double(currentDay) },
                                      set: { currentDay = Int($0) }),
                       in: 1...Double(cycleLength), step: 1)
                    .tint(LunaColors.accentBold)
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(LunaColors.bgSecondary))
        }
    }

    private var askReason: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("what brought you here?")
                .font(LunaType.displayL)
                .foregroundStyle(LunaColors.textPrimary)
            Text("no wrong answer. pick the one that stings the most.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
            VStack(spacing: 10) {
                ForEach(OnboardingReason.allCases) { r in
                    ReasonRow(reason: r, isSelected: r == reason) { reason = r }
                }
            }
        }
    }

    private var askVoice: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("how do you want luna to talk to you?")
                .font(LunaType.displayL)
                .foregroundStyle(LunaColors.textPrimary)
            Text("this changes every word she ever says to you. changeable in settings.")
                .font(LunaType.bodyM)
                .foregroundStyle(LunaColors.textSecondary)
            VStack(spacing: 10) {
                ForEach(VoiceTone.allCases) { v in
                    VoiceRow(voice: v, isSelected: v == voice) { voice = v }
                }
            }
        }
    }

    private var instantRead: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("your instant read")
                .font(LunaType.metaM.weight(.semibold))
                .foregroundStyle(LunaColors.textSecondary)
                .textCase(.uppercase)

            Text(instantReadCopy)
                .font(LunaType.displayM)
                .foregroundStyle(LunaColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            SoftCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("what this week looks like")
                        .font(LunaType.bodyS.weight(.semibold))
                        .foregroundStyle(LunaColors.textSecondary)
                    Text(phaseForecastCopy)
                        .font(LunaType.bodyL)
                        .foregroundStyle(LunaColors.textPrimary)
                }
            }
        }
    }

    private var instantReadCopy: String {
        let phase = CycleEngine.phase(forDay: currentDay, cycleLength: cycleLength)
        switch (phase, voice) {
        case (.menstrual, .soft):     return "\(displayName), you're bleeding this week. be tender. luna's got the rest."
        case (.menstrual, .balanced): return "\(displayName), day \(currentDay). your body is doing actual work. you're not lazy — you're menstruating."
        case (.menstrual, .savage):   return "\(displayName), day \(currentDay). you're bleeding. cancel the plans you dread. the rest can wait."
        case (.follicular, .soft):    return "\(displayName), you're in a rising window. a gentle yes to things."
        case (.follicular, .balanced):return "\(displayName), day \(currentDay). your energy's climbing. make a plan. call her back."
        case (.follicular, .savage):  return "\(displayName), day \(currentDay). follicular. yes you can. yes you should. go."
        case (.ovulation, .soft):     return "\(displayName), you're glowing this week. it counts even when it's chemical."
        case (.ovulation, .balanced): return "\(displayName), day \(currentDay). ovulation. charismatic mode unlocked."
        case (.ovulation, .savage):   return "\(displayName), ovulating. do not text the ex. i will know."
        case (.luteal, .soft):        return "\(displayName), you're in your quiet phase. the world hasn't changed. your perception has."
        case (.luteal, .balanced):    return "\(displayName), day \(currentDay). luteal. the fog is hormonal. you are not the feeling."
        case (.luteal, .savage):      return "\(displayName), luteal. everyone is annoying because your hormones said so. proceed with snacks."
        }
    }

    private var phaseForecastCopy: String {
        let phase = CycleEngine.phase(forDay: currentDay, cycleLength: cycleLength)
        switch phase {
        case .menstrual:  return "rest-first week. lower the bar. hydrate, protein, and the least demanding texts first."
        case .follicular: return "creative and social window. start things. say yes to the things that scare you in a good way."
        case .ovulation:  return "charismatic mode. hard conversations go better now. speak up before the window closes."
        case .luteal:     return "low-demand week. protect your time. don't send the long text. sleep is a love language."
        }
    }

    private var displayName: String { name.isEmpty ? "friend" : name }

    // MARK: - Footer
    private var footer: some View {
        VStack(spacing: 10) {
            SoftButton(title: step == lastStep ? "into the app" : "continue", style: .primary) {
                advance()
            }
            .disabled(step == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(step == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

            if step > 0 && step < lastStep {
                Button("back") { step = max(0, step - 1) }
                    .font(LunaType.bodyS)
                    .foregroundStyle(LunaColors.textSecondary)
            }
        }
    }

    private func advance() {
        if step < lastStep {
            Haptics.soft()
            step += 1
        } else {
            finish()
        }
    }

    private func finish() {
        Haptics.success()

        // Compute last period date from current day.
        let lastPeriod = Calendar.current.date(byAdding: .day, value: -(currentDay - 1), to: .now)

        let profile = UserProfile(
            name: name,
            birthday: birthday,
            averageCycleLength: cycleLength,
            lastPeriodStart: lastPeriod,
            voiceRaw: voice.rawValue,
            themeRaw: appState.theme.rawValue,
            onboardingReasonRaw: reason.rawValue
        )
        modelContext.insert(profile)

        appState.voice = voice
        appState.displayName = name
        appState.hasOnboarded = true
    }
}

private struct ReasonRow: View {
    var reason: OnboardingReason
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: { Haptics.selection(); action() }) {
            HStack {
                Text(reason.label)
                    .font(LunaType.bodyL)
                    .foregroundStyle(LunaColors.textPrimary)
                Spacer()
                if isSelected {
                    Circle().fill(LunaColors.accentBold).frame(width: 12, height: 12)
                } else {
                    Circle().stroke(LunaColors.textSecondary.opacity(0.4), lineWidth: 1.5).frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? LunaColors.accentSoft.opacity(0.4) : LunaColors.bgSecondary))
        }
        .buttonStyle(.plain)
    }
}

private struct VoiceRow: View {
    var voice: VoiceTone
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: { Haptics.selection(); action() }) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(voice.label)
                        .font(LunaType.bodyL.weight(.semibold))
                        .foregroundStyle(LunaColors.textPrimary)
                    Text(voice.subtitle)
                        .font(LunaType.bodyS)
                        .foregroundStyle(LunaColors.textSecondary)
                }
                Spacer()
                if isSelected {
                    Circle().fill(LunaColors.accentBold).frame(width: 12, height: 12).padding(.top, 6)
                } else {
                    Circle().stroke(LunaColors.textSecondary.opacity(0.4), lineWidth: 1.5).frame(width: 12, height: 12).padding(.top, 6)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? LunaColors.accentSoft.opacity(0.4) : LunaColors.bgSecondary))
        }
        .buttonStyle(.plain)
    }
}

private struct ProgressBar: View {
    var value: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(LunaColors.textSecondary.opacity(0.15)).frame(height: 3)
                Capsule().fill(LunaColors.accentBold).frame(width: geo.size.width * value, height: 3)
                    .animation(.easeInOut(duration: 0.4), value: value)
            }
        }
        .frame(height: 3)
    }
}
