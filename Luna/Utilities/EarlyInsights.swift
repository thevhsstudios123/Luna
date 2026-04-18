import Foundation

// Insights designed to land in the first 72 hours, before the deterministic
// PatternEngine has enough data to be confident. These are honest, low-confidence
// reads framed as such — never claimed as fact. Time-to-value > correctness here.
enum EarlyInsights {
    static func generate(checkIns: [CheckIn],
                         passive: PassiveSnapshot,
                         profile: UserProfile?,
                         voice: VoicePack) -> [PatternInsight] {
        guard let profile else { return [] }
        var out: [PatternInsight] = []
        let day = CycleEngine.currentDay(lastPeriod: profile.lastPeriodStart, cycleLength: profile.averageCycleLength) ?? 1
        let phase = CycleEngine.phase(forDay: day, cycleLength: profile.averageCycleLength)

        // Day-1 phase read — works with zero check-ins.
        if checkIns.isEmpty {
            out.append(.init(
                title: "first read",
                body: phaseFirstRead(phase: phase, voice: voice),
                kindRaw: "early_phase",
                severity: .gentle))
        }

        // Sleep + phase combo.
        if let sleep = passive.sleepHoursLastNight, sleep < 6.5, phase == .luteal {
            out.append(.init(
                title: "low-confidence pattern",
                body: lutealSleepLine(hours: sleep, voice: voice),
                kindRaw: "early_sleep",
                severity: .gentle))
        }

        // Sample size warning so users trust the engine.
        if (1...3).contains(checkIns.count) {
            out.append(.init(
                title: "still learning you",
                body: stillLearning(count: checkIns.count, voice: voice),
                kindRaw: "early_meta",
                severity: .note))
        }

        return out
    }

    private static func phaseFirstRead(phase: CyclePhase, voice: VoicePack) -> String {
        switch (phase, voice.tone) {
        case (.menstrual, _): return "you're in your menstrual phase. low energy isn't laziness — it's biology asking for rest."
        case (.follicular, _): return "follicular phase. your brain is the most plastic it'll be all month. start something."
        case (.ovulation, _): return "ovulation. you'll feel more verbal and confident. use it before the window closes."
        case (.luteal, _): return "luteal. expect more critical thoughts about yourself. it's hormonal, not real."
        }
    }

    private static func lutealSleepLine(hours: Double, voice: VoicePack) -> String {
        let h = String(format: "%.1f", hours)
        switch voice.tone {
        case .soft:     return "low sleep + luteal tends to feel heavier. \(h) hours last night — be soft with you."
        case .balanced: return "early read: \(h) hours sleep in luteal usually = harder day. plan accordingly."
        case .savage:   return "\(h) hours of sleep + luteal = villain origin story. cancel something."
        }
    }

    private static func stillLearning(count: Int, voice: VoicePack) -> String {
        switch voice.tone {
        case .soft:     return "luna has \(count) check-ins so far. patterns get more honest with time."
        case .balanced: return "\(count) check-ins in. read these as low-confidence — luna's still meeting you."
        case .savage:   return "\(count) data points. don't trust me yet."
        }
    }
}
