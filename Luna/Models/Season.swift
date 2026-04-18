import Foundation
import SwiftUI

// Seasons are small, retention-friendly cosmetic shifts that the app earns
// over time. Avatar accessories, color washes, and idle animations evolve
// as the user sticks around — so the app doesn't feel like the same brand
// poster forever.
//
// Seasons are unlocked by milestones (cycles tracked, days active),
// not by paywall gating. Earned, not bought.

enum Season: String, CaseIterable, Identifiable, Codable {
    case dawn       // default — what you start with
    case bloom      // unlocks at first cycle (~30 days)
    case quiet      // unlocks at 60 days
    case wild       // unlocks at 90 days
    case archived   // unlocks at 180 days

    var id: String { rawValue }
    var label: String {
        switch self {
        case .dawn: return "Dawn"
        case .bloom: return "Bloom"
        case .quiet: return "Quiet"
        case .wild: return "Wild"
        case .archived: return "Archive"
        }
    }
    var sub: String {
        switch self {
        case .dawn: return "where you start. soft, open."
        case .bloom: return "earned in your first cycle. brighter glows, small flowers."
        case .quiet: return "earned at 60 days. muted palette, contemplative."
        case .wild: return "earned at 90 days. saturated, alive."
        case .archived: return "earned at 6 months. textured, considered, vintage."
        }
    }
    var unlocksAtCheckIns: Int {
        switch self {
        case .dawn: return 0
        case .bloom: return 30
        case .quiet: return 60
        case .wild: return 90
        case .archived: return 180
        }
    }

    // Color tints applied on top of the base theme. Subtle, not overpowering.
    var avatarTint: Color {
        switch self {
        case .dawn: return Color.clear
        case .bloom: return LunaColors.accentSoft.opacity(0.18)
        case .quiet: return Color(hex: 0xB8AAB5).opacity(0.2)
        case .wild: return LunaColors.accentWarm.opacity(0.25)
        case .archived: return Color(hex: 0xCDB68F).opacity(0.22)
        }
    }
}

// Voice intensity. The user picks a base voice (Soft/Balanced/Savage) and a
// dial for how loud that voice gets. Lets a Savage user soften a specific
// session without changing their identity, or vice versa.
enum VoiceIntensity: Int, CaseIterable, Identifiable, Codable {
    case whisper = 0
    case quiet = 1
    case normal = 2
    case bold = 3
    case shouted = 4

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .whisper: return "whisper"
        case .quiet: return "quiet"
        case .normal: return "normal"
        case .bold: return "bold"
        case .shouted: return "shouted"
        }
    }
}
