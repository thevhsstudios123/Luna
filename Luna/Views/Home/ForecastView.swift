import SwiftUI
import SwiftData

// Weekly + monthly emotional forecast.
struct ForecastView: View {
    @EnvironmentObject var appState: AppState
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    private var cycleLength: Int { profile?.averageCycleLength ?? 28 }
    private var currentDay: Int {
        CycleEngine.currentDay(lastPeriod: profile?.lastPeriodStart, cycleLength: cycleLength) ?? 1
    }
    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("this week")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)

                ForEach(0..<7, id: \.self) { offset in
                    let day = ((currentDay - 1 + offset) % cycleLength) + 1
                    let phase = CycleEngine.phase(forDay: day, cycleLength: cycleLength)
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: .now) ?? .now
                    SoftCard(tint: phase.color.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(date.weekdayName.lowercased())
                                    .font(LunaType.bodyS.weight(.semibold))
                                    .foregroundStyle(appState.theme.textSecondary)
                                Spacer()
                                PhaseBadge(phase: phase)
                            }
                            Text(line(for: phase, day: day))
                                .font(LunaType.bodyL)
                                .foregroundStyle(appState.theme.textPrimary)
                        }
                    }
                }

                Text("this cycle")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)
                    .padding(.top, 12)

                ForEach(CyclePhase.allCases) { phase in
                    SoftCard(tint: phase.color.opacity(0.12)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(phase.label)
                                    .font(LunaType.displayS)
                                    .foregroundStyle(phase.color)
                                Spacer()
                                Text(range(for: phase))
                                    .font(LunaType.metaM)
                                    .foregroundStyle(appState.theme.textSecondary)
                            }
                            Text(recommendation(for: phase))
                                .font(LunaType.bodyM)
                                .foregroundStyle(appState.theme.textPrimary)
                        }
                    }
                }
                Spacer(minLength: 60)
            }
            .padding(20)
        }
        .navigationTitle("forecast")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func line(for phase: CyclePhase, day: Int) -> String {
        switch (phase, appState.voice) {
        case (.menstrual, _): return voice.menstrualToday(day: day)
        case (.follicular, _): return voice.follicularToday(day: day)
        case (.ovulation, _): return voice.ovulationToday(day: day)
        case (.luteal, _): return voice.lutealHeadsUp(day: day)
        }
    }

    private func range(for phase: CyclePhase) -> String {
        switch phase {
        case .menstrual: return "days 1–5"
        case .follicular: return "days 6–\(max(11, cycleLength - 15))"
        case .ovulation: return "days \(max(12, cycleLength - 14))–\(max(14, cycleLength - 12))"
        case .luteal: return "days \(max(15, cycleLength - 11))–\(cycleLength)"
        }
    }

    private func recommendation(for phase: CyclePhase) -> String {
        switch (phase, appState.voice) {
        case (.menstrual, .soft): return "eat warm things. wear the soft pants. hold your own hand."
        case (.menstrual, .balanced): return "iron-heavy meals. short walks. protect your inbox."
        case (.menstrual, .savage): return "ibuprofen, heating pad, and nothing you didn't already commit to."
        case (.follicular, .soft): return "try one new thing. your creative window is open."
        case (.follicular, .balanced): return "strength training, big ideas, schedule your best work."
        case (.follicular, .savage): return "go do the thing you've been avoiding. it's gonna be fine."
        case (.ovulation, .soft): return "connect deeply. beautiful days to be seen."
        case (.ovulation, .balanced): return "pitch, ask, negotiate. your charisma is at peak."
        case (.ovulation, .savage): return "hottest week of your cycle. do not waste it on him."
        case (.luteal, .soft): return "soft food, early sleep, gentle people."
        case (.luteal, .balanced): return "magnesium, less caffeine, say no to things."
        case (.luteal, .savage): return "do not schedule anything important. i'm begging."
        }
    }
}
