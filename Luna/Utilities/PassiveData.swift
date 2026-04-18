import Foundation

// Passive signals = what we know about the user without asking.
// Day 1 of the app, they should already feel "seen" via passive data,
// even before logging a single check-in.
//
// Protocol seam: HealthKitPassiveProvider plugs in here later without
// touching any view. Until then, MockPassiveProvider returns small,
// believable defaults so the UI has signal to render.
protocol PassiveProvider {
    func snapshot() async -> PassiveSnapshot
}

struct PassiveSnapshot: Equatable {
    var sleepHoursLastNight: Double?
    var stepsToday: Int?
    var screenTimeHours: Double?
    var hrvAverage: Double?
    var generatedAt: Date

    static let empty = PassiveSnapshot(sleepHoursLastNight: nil, stepsToday: nil, screenTimeHours: nil, hrvAverage: nil, generatedAt: .now)
}

// Mock provider — realistic-feeling defaults that vary by day-of-week
// so the prototype feels alive without HealthKit hooked up.
final class MockPassiveProvider: PassiveProvider {
    func snapshot() async -> PassiveSnapshot {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: .now) // 1 = Sunday
        let baseSleep = [7.8, 6.4, 7.0, 6.8, 6.5, 5.9, 8.1][weekday - 1]
        let baseSteps = [4200, 6800, 7100, 6500, 7400, 5800, 3900][weekday - 1]
        let baseScreen = [3.4, 5.2, 4.8, 5.0, 5.6, 6.1, 4.5][weekday - 1]
        return PassiveSnapshot(
            sleepHoursLastNight: baseSleep,
            stepsToday: baseSteps,
            screenTimeHours: baseScreen,
            hrvAverage: 48.0,
            generatedAt: .now
        )
    }
}

// Reads from the snapshot to surface a single "what we already know" line.
// Intentionally short — this is the user's day-1 dopamine.
enum PassiveRead {
    static func headline(_ s: PassiveSnapshot, voice: VoicePack) -> String? {
        if let sleep = s.sleepHoursLastNight {
            if sleep < 6 {
                switch voice.tone {
                case .soft:     return "you slept \(fmt(sleep)) hours. be tender today."
                case .balanced: return "\(fmt(sleep)) hours of sleep. lower the bar today."
                case .savage:   return "\(fmt(sleep)) hours? cancel one thing. now."
                }
            }
            if sleep >= 8 {
                switch voice.tone {
                case .soft:     return "you slept \(fmt(sleep)) hours. your nervous system thanks you."
                case .balanced: return "\(fmt(sleep)) hours of sleep. that's a lot of capital. spend it well."
                case .savage:   return "\(fmt(sleep)) hours of sleep. who is she."
                }
            }
        }
        if let screen = s.screenTimeHours, screen >= 6 {
            switch voice.tone {
            case .soft:     return "screen time has been high. a walk would help."
            case .balanced: return "screen time over 6 hours. your brain is foggy by design."
            case .savage:   return "you're cooked. put the phone down."
            }
        }
        return nil
    }

    private static func fmt(_ d: Double) -> String { String(format: "%.1f", d) }
}
