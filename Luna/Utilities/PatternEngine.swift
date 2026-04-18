import Foundation

// Computes insights from the user's own data. No seed data, no ML yet —
// deterministic aggregations that become meaningful after ~2 cycles.
struct PatternInsight: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let kindRaw: String
    let severity: Severity

    enum Severity { case gentle, note, heads_up, celebrate }
}

enum PatternEngine {
    // Aggregate mood by cycle day across all logged check-ins.
    static func moodByCycleDay(checkIns: [CheckIn], lastPeriod: Date?, cycleLength: Int) -> [Int: Double] {
        guard let _ = lastPeriod else { return [:] }
        var buckets: [Int: [Int]] = [:]
        for ci in checkIns {
            guard let day = CycleEngine.currentDay(lastPeriod: lastPeriod, cycleLength: cycleLength, now: ci.date) else { continue }
            buckets[day, default: []].append(ci.mood)
        }
        return buckets.mapValues { Double($0.reduce(0, +)) / Double($0.count) }
    }

    static func worstMoodDay(checkIns: [CheckIn], lastPeriod: Date?, cycleLength: Int) -> Int? {
        let byDay = moodByCycleDay(checkIns: checkIns, lastPeriod: lastPeriod, cycleLength: cycleLength)
        return byDay.filter { $0.value <= 4 }.min { $0.value < $1.value }?.key
    }

    static func insights(checkIns: [CheckIn],
                         events: [CycleEvent],
                         interactions: [Interaction],
                         profile: UserProfile?,
                         voice: VoicePack) -> [PatternInsight] {
        guard let profile else { return [] }
        var out: [PatternInsight] = []

        if let day = worstMoodDay(checkIns: checkIns, lastPeriod: profile.lastPeriodStart, cycleLength: profile.averageCycleLength) {
            out.append(.init(title: "your villain day",
                             body: voice.sampleWorstDay(day: day),
                             kindRaw: "mood_low",
                             severity: .heads_up))
        }

        // Tag frequency — surfaces what keeps showing up.
        let allTags = checkIns.flatMap { $0.tags }
        if !allTags.isEmpty {
            let counts = Dictionary(grouping: allTags, by: { $0 }).mapValues(\.count)
            if let top = counts.max(by: { $0.value < $1.value }), top.value >= 3 {
                out.append(.init(
                    title: "a word that keeps showing up",
                    body: "\"\(top.key.label)\" appears in \(top.value) of your check-ins. worth sitting with.",
                    kindRaw: "tag_freq",
                    severity: .note))
            }
        }

        // Relationship impact
        let grouped = Dictionary(grouping: interactions, by: { $0.person?.id })
        for (_, list) in grouped where list.count >= 2 {
            let avgDelta = Double(list.map(\.moodDelta).reduce(0, +)) / Double(list.count)
            if avgDelta <= -1.0, let name = list.first?.person?.name {
                out.append(.init(
                    title: "noticed",
                    body: "every time you see \(name), your mood drops after. pattern, not vibes.",
                    kindRaw: "person_drop",
                    severity: .heads_up))
            } else if avgDelta >= 1.0, let name = list.first?.person?.name {
                out.append(.init(
                    title: "healing receipt",
                    body: "\(name) consistently lifts your mood. that's good data.",
                    kindRaw: "person_lift",
                    severity: .celebrate))
            }
        }

        // Streak-adjacent but never shaming: celebrate total check-ins at milestones.
        let milestones = [7, 14, 30, 60, 90]
        if milestones.contains(checkIns.count) {
            out.append(.init(title: "healing receipt",
                             body: "\(checkIns.count) check-ins. you've been showing up for yourself.",
                             kindRaw: "milestone",
                             severity: .celebrate))
        }

        return out
    }
}
