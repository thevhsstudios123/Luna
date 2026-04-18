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

    // Ovulation date prediction for the current or next cycle.
    static func predictOvulation(lastPeriod: Date?, cycleLength: Int) -> Date? {
        guard let lp = lastPeriod else { return nil }
        let len = max(cycleLength, 21)
        let offset = max(len - 14, 12)
        return Calendar.current.date(byAdding: .day, value: offset - 1, to: lp)
    }

    static func nextPeriod(lastPeriod: Date?, cycleLength: Int) -> Date? {
        guard let lp = lastPeriod else { return nil }
        return Calendar.current.date(byAdding: .day, value: max(cycleLength, 21), to: lp)
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
