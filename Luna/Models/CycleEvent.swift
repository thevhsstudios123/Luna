import Foundation
import SwiftData
import SwiftUI

@Model
final class CycleEvent {
    var date: Date
    var kindRaw: String              // period | symptom | spotting | end
    var flowRaw: String              // light, medium, heavy, spotting, none
    var symptomsRaw: String          // comma separated
    var notes: String
    var createdAt: Date

    init(date: Date = .now,
         kind: CycleEventKind = .period,
         flow: FlowIntensity = .none,
         symptoms: [Symptom] = [],
         notes: String = "",
         createdAt: Date = .now) {
        self.date = date
        self.kindRaw = kind.rawValue
        self.flowRaw = flow.rawValue
        self.symptomsRaw = symptoms.map { $0.rawValue }.joined(separator: ",")
        self.notes = notes
        self.createdAt = createdAt
    }

    var kind: CycleEventKind {
        get { CycleEventKind(rawValue: kindRaw) ?? .symptom }
        set { kindRaw = newValue.rawValue }
    }
    var flow: FlowIntensity {
        get { FlowIntensity(rawValue: flowRaw) ?? .none }
        set { flowRaw = newValue.rawValue }
    }
    var symptoms: [Symptom] {
        get { symptomsRaw.split(separator: ",").compactMap { Symptom(rawValue: String($0)) } }
        set { symptomsRaw = newValue.map { $0.rawValue }.joined(separator: ",") }
    }
}

enum CycleEventKind: String, CaseIterable { case period, end, spotting, symptom }

enum FlowIntensity: String, CaseIterable, Identifiable {
    case none, spotting, light, medium, heavy
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none: return "—"
        case .spotting: return "spotting"
        case .light: return "light"
        case .medium: return "medium"
        case .heavy: return "heavy"
        }
    }
}

enum Symptom: String, CaseIterable, Identifiable {
    case cramps, headache, bloating, breastTenderness, acne, nausea, backache, fatigue, insomnia
    var id: String { rawValue }
    var label: String {
        switch self {
        case .cramps: return "cramps"
        case .headache: return "headache"
        case .bloating: return "bloating"
        case .breastTenderness: return "breast tenderness"
        case .acne: return "acne"
        case .nausea: return "nausea"
        case .backache: return "backache"
        case .fatigue: return "fatigue"
        case .insomnia: return "insomnia"
        }
    }
}

enum CyclePhase: String, CaseIterable, Identifiable {
    case menstrual, follicular, ovulation, luteal
    var id: String { rawValue }
    var label: String {
        switch self {
        case .menstrual: return "menstrual"
        case .follicular: return "follicular"
        case .ovulation: return "ovulation"
        case .luteal: return "luteal"
        }
    }
    var color: Color {
        switch self {
        case .menstrual:  return LunaColors.phaseMenstrual
        case .follicular: return LunaColors.phaseFollicular
        case .ovulation:  return LunaColors.phaseOvulation
        case .luteal:     return LunaColors.phaseLuteal
        }
    }
}

