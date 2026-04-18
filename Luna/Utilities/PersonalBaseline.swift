import Foundation

// Per-user baseline tracking. The deterministic PatternEngine uses cohort-style
// rules ("luteal day 24 = bad mood"). PersonalBaseline learns YOUR baselines and
// flags deviations from them.
//
// Today this is a small in-memory aggregator. The MLBaselineProvider protocol
// below is the seam to swap in CoreML once we have enough data to train.

struct UserBaseline {
    var avgMood: Double
    var avgEnergy: Double
    var avgSelfImage: Double
    var avgMoodByPhase: [CyclePhase: Double]
    var sampleSize: Int

    // A reading is meaningfully off baseline when it's more than 2 points
    // below the user's own average (on the 1-10 scale).
    func isBelowBaseline(mood: Int) -> Bool {
        sampleSize >= 7 && Double(mood) <= avgMood - 2.0
    }
}

enum PersonalBaselineEngine {
    static func compute(checkIns: [CheckIn], cycleLength: Int, lastPeriod: Date?) -> UserBaseline {
        guard !checkIns.isEmpty else {
            return UserBaseline(avgMood: 5, avgEnergy: 5, avgSelfImage: 5,
                                avgMoodByPhase: [:], sampleSize: 0)
        }
        let avgMood = mean(checkIns.map { Double($0.mood) })
        let avgEnergy = mean(checkIns.map { Double($0.energy) })
        let avgSelf = mean(checkIns.map { Double($0.selfImage) })

        var byPhase: [CyclePhase: [Double]] = [:]
        for ci in checkIns {
            guard let day = CycleEngine.currentDay(lastPeriod: lastPeriod, cycleLength: cycleLength, now: ci.date) else { continue }
            let phase = CycleEngine.phase(forDay: day, cycleLength: cycleLength)
            byPhase[phase, default: []].append(Double(ci.mood))
        }
        let avgByPhase = byPhase.mapValues { mean($0) }

        return UserBaseline(avgMood: avgMood, avgEnergy: avgEnergy, avgSelfImage: avgSelf,
                            avgMoodByPhase: avgByPhase, sampleSize: checkIns.count)
    }

    private static func mean(_ xs: [Double]) -> Double {
        xs.isEmpty ? 0 : xs.reduce(0, +) / Double(xs.count)
    }
}

// Future ML hook. When we ship a CoreML model that learns per-user patterns,
// implement this protocol and inject. The PatternEngine reads through the
// protocol so views never need to change.
protocol MLBaselineProvider {
    func predict(forCycleDay day: Int, baseline: UserBaseline) -> MoodPrediction?
}

struct MoodPrediction {
    var expectedMood: Double
    var confidence: Double // 0...1
    var range: ClosedRange<Double>
}

final class HeuristicBaselineProvider: MLBaselineProvider {
    func predict(forCycleDay day: Int, baseline: UserBaseline) -> MoodPrediction? {
        guard baseline.sampleSize >= 7 else { return nil }
        // For the prototype we just return the user's own phase average with
        // a +/- 1.5 honest range and confidence proportional to sample size.
        let phase = CycleEngine.phase(forDay: day, cycleLength: 28)
        guard let avg = baseline.avgMoodByPhase[phase] else { return nil }
        let confidence = min(1.0, Double(baseline.sampleSize) / 30.0)
        return MoodPrediction(
            expectedMood: avg,
            confidence: confidence,
            range: max(1, avg - 1.5)...min(10, avg + 1.5)
        )
    }
}
