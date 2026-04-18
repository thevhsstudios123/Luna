import Foundation

// Pure functions for phase math. Zero side effects — easy to unit test.
enum CycleEngine {
    // Standard textbook split: menstrual 1-5, follicular 6-13, ovulation 14-16, luteal 17-end.
    static func phase(forDay day: Int, cycleLength: Int) -> CyclePhase {
        let len = max(cycleLength, 21)
        let ovStart = max(len - 14, 12)          // ovulation ~14 days before period
        let ovEnd = ovStart + 2
        if day <= 5 { return .menstrual }
        if day < ovStart { return .follicular }
        if day <= ovEnd { return .ovulation }
        return .luteal
    }

    // Days since last period start (1-indexed). Nil if no period logged.
    static func currentDay(lastPeriod: Date?, cycleLength: Int, now: Date = .now) -> Int? {
        guard let lp = lastPeriod else { return nil }
        let days = Calendar.current.dateComponents([.day], from: startOfDay(lp), to: startOfDay(now)).day ?? 0
        let len = max(cycleLength, 21)
        let mod = ((days % len) + len) % len
        return mod + 1
    }

    // Honest prediction range. Never claim a single date — give a window
    // and a confidence score so the user trusts what we say.
    struct Prediction {
        var early: Date
        var likely: Date
        var late: Date
        var confidence: Double // 0...1, scales with cycle history
    }

    static func nextPeriodPrediction(lastPeriod: Date?, cycleLength: Int, recentLengths: [Int] = []) -> Prediction? {
        guard let lp = lastPeriod else { return nil }
        let len = max(cycleLength, 21)
        let cal = Calendar.current
        // Spread = standard deviation of the last few cycles, defaulting to ±2 days.
        let spread: Int
        if recentLengths.count >= 3 {
            let avg = Double(recentLengths.reduce(0, +)) / Double(recentLengths.count)
            let variance = recentLengths.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(recentLengths.count)
            spread = max(2, min(7, Int(sqrt(variance).rounded())))
        } else {
            spread = 2
        }
        let likely = cal.date(byAdding: .day, value: len, to: lp) ?? lp
        let early = cal.date(byAdding: .day, value: -spread, to: likely) ?? likely
        let late = cal.date(byAdding: .day, value: spread, to: likely) ?? likely
        let confidence = min(1.0, Double(recentLengths.count) / 6.0)
        return Prediction(early: early, likely: likely, late: late, confidence: confidence)
    }

    static func ovulationPrediction(lastPeriod: Date?, cycleLength: Int, recentLengths: [Int] = []) -> Prediction? {
        guard let lp = lastPeriod else { return nil }
        let len = max(cycleLength, 21)
        let offset = max(len - 14, 12)
        let cal = Calendar.current
        let likely = cal.date(byAdding: .day, value: offset - 1, to: lp) ?? lp
        // Ovulation has a natural 24-48h window even for regular cycles.
        let spread = recentLengths.count >= 3 ? 3 : 2
        let early = cal.date(byAdding: .day, value: -spread, to: likely) ?? likely
        let late = cal.date(byAdding: .day, value: spread, to: likely) ?? likely
        let confidence = min(1.0, Double(recentLengths.count) / 6.0)
        return Prediction(early: early, likely: likely, late: late, confidence: confidence)
    }

    static func isIrregular(recentLengths: [Int]) -> Bool {
        guard recentLengths.count >= 3 else { return false }
        let avg = Double(recentLengths.reduce(0, +)) / Double(recentLengths.count)
        let variance = recentLengths.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(recentLengths.count)
        let stddev = sqrt(variance)
        return stddev > 7 // more than a week of drift = flag it
    }

    private static func startOfDay(_ d: Date) -> Date { Calendar.current.startOfDay(for: d) }
}
