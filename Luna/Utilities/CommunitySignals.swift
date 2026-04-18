import Foundation

// Anonymous, aggregate-only signals. Validation without surveillance.
//
// Today this is fully mocked — no network, no telemetry. The protocol below is
// the seam to plug in a real privacy-preserving aggregator later (homomorphic
// counts, federated math, or just k-anonymous bucketed reads).
//
// Hard rule: never expose anyone's identity, message, or location. Only counts
// of women in the same cycle phase / day with the same broad mood bucket.

protocol CommunitySignalProvider {
    func signal(forCycleDay day: Int, phase: CyclePhase, mood: Int?) async -> CommunitySignal?
}

struct CommunitySignal: Equatable {
    var sameDayCount: Int      // women on same cycle day in last 24h
    var samePhaseCount: Int    // women in same phase right now
    var sameMoodCount: Int     // women with similar mood today
    var generatedAt: Date
}

// Mock provider with tasteful, plausible numbers.
// Numbers vary deterministically by day so the UI feels real, never identical.
final class MockCommunitySignalProvider: CommunitySignalProvider {
    func signal(forCycleDay day: Int, phase: CyclePhase, mood: Int?) async -> CommunitySignal? {
        // Deterministic hash so the same day shows the same number.
        let seed = day * 31 + Calendar.current.component(.day, from: .now)
        let same = 18 + (seed % 47)
        let phaseN = 220 + (seed % 380)
        let moodN: Int = {
            guard let mood else { return 0 }
            return 12 + (mood + day) * 5 % 56
        }()
        return CommunitySignal(sameDayCount: same, samePhaseCount: phaseN, sameMoodCount: moodN, generatedAt: .now)
    }
}

enum CommunityCopy {
    static func line(signal: CommunitySignal, day: Int, mood: Int?, voice: VoicePack) -> String {
        if let mood, signal.sameMoodCount > 0 {
            switch voice.tone {
            case .soft:     return "\(signal.sameMoodCount) other women felt similar today. you're not alone."
            case .balanced: return "\(signal.sameMoodCount) women on luna logged a similar mood today."
            case .savage:   return "\(signal.sameMoodCount) of us. same boat. anonymous, of course."
            }
        }
        if signal.sameDayCount > 0 {
            switch voice.tone {
            case .soft:     return "\(signal.sameDayCount) other women are on day \(day) today. you're in good company."
            case .balanced: return "\(signal.sameDayCount) women are on day \(day) right now. quiet community."
            case .savage:   return "\(signal.sameDayCount) of us also bleeding/about to/recovering. solidarity."
            }
        }
        return ""
    }
}
