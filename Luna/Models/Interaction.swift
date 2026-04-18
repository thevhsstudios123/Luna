import Foundation
import SwiftData

@Model
final class Interaction {
    var date: Date
    var kindRaw: String        // inPerson, text, call, video
    var moodBefore: Int        // 1-10
    var moodAfter: Int         // 1-10
    var note: String
    var person: Person?

    init(date: Date = .now,
         kind: InteractionKind = .text,
         moodBefore: Int = 5,
         moodAfter: Int = 5,
         note: String = "",
         person: Person? = nil) {
        self.date = date
        self.kindRaw = kind.rawValue
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
        self.note = note
        self.person = person
    }

    var kind: InteractionKind {
        get { InteractionKind(rawValue: kindRaw) ?? .text }
        set { kindRaw = newValue.rawValue }
    }

    var moodDelta: Int { moodAfter - moodBefore }
}

enum InteractionKind: String, CaseIterable, Identifiable {
    case inPerson, text, call, video
    var id: String { rawValue }
    var label: String {
        switch self {
        case .inPerson: return "in person"
        case .text: return "text"
        case .call: return "call"
        case .video: return "video"
        }
    }
}
