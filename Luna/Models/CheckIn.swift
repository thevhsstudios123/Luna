import Foundation
import SwiftData

@Model
final class CheckIn {
    var date: Date
    var mood: Int         // 1-10
    var energy: Int       // 1-10
    var selfImage: Int    // 1-10
    var tagsRaw: String   // comma-separated MoodTag raw values
    var journal: String
    var createdAt: Date

    init(date: Date = .now,
         mood: Int = 5,
         energy: Int = 5,
         selfImage: Int = 5,
         tagsRaw: String = "",
         journal: String = "",
         createdAt: Date = .now) {
        self.date = date
        self.mood = mood
        self.energy = energy
        self.selfImage = selfImage
        self.tagsRaw = tagsRaw
        self.journal = journal
        self.createdAt = createdAt
    }

    var tags: [MoodTag] {
        get { tagsRaw.split(separator: ",").compactMap { MoodTag(rawValue: String($0)) } }
        set { tagsRaw = newValue.map { $0.rawValue }.joined(separator: ",") }
    }
}

enum MoodTag: String, CaseIterable, Identifiable {
    case cried, fought, productive, anxious, confident, lonely
    case horny, dissociated, rage, soft, numb, creative
    case focused, restless, tender, hopeful, spiraling
    case powerful, insecure, grateful, seen, invisible

    var id: String { rawValue }
    var label: String {
        switch self {
        case .cried: return "cried"
        case .fought: return "fought"
        case .productive: return "productive"
        case .anxious: return "anxious"
        case .confident: return "confident"
        case .lonely: return "lonely"
        case .horny: return "horny"
        case .dissociated: return "dissociated"
        case .rage: return "rage-y"
        case .soft: return "soft"
        case .numb: return "numb"
        case .creative: return "creative"
        case .focused: return "focused"
        case .restless: return "restless"
        case .tender: return "tender"
        case .hopeful: return "hopeful"
        case .spiraling: return "spiraling"
        case .powerful: return "powerful"
        case .insecure: return "insecure"
        case .grateful: return "grateful"
        case .seen: return "seen"
        case .invisible: return "invisible"
        }
    }
}
