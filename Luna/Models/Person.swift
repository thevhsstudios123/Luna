import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var relationshipRaw: String
    var photoEmoji: String     // keeps the prototype image-light
    var accentHex: UInt32
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var interactions: [Interaction] = []

    init(name: String,
         relationship: RelationshipKind = .friend,
         photoEmoji: String = "🌙",
         accentHex: UInt32 = 0xE8B4BC,
         createdAt: Date = .now) {
        self.name = name
        self.relationshipRaw = relationship.rawValue
        self.photoEmoji = photoEmoji
        self.accentHex = accentHex
        self.createdAt = createdAt
    }

    var relationship: RelationshipKind {
        get { RelationshipKind(rawValue: relationshipRaw) ?? .friend }
        set { relationshipRaw = newValue.rawValue }
    }
}

enum RelationshipKind: String, CaseIterable, Identifiable {
    case partner, situationship, parent, sibling, friend, boss, coworker, ex
    var id: String { rawValue }
    var label: String {
        switch self {
        case .partner: return "partner"
        case .situationship: return "situationship"
        case .parent: return "parent"
        case .sibling: return "sibling"
        case .friend: return "friend"
        case .boss: return "boss"
        case .coworker: return "coworker"
        case .ex: return "ex"
        }
    }
}
