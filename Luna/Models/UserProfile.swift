import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var birthday: Date?
    var averageCycleLength: Int
    var lastPeriodStart: Date?
    var voiceRaw: String
    var themeRaw: String
    var onboardingReasonRaw: String
    var createdAt: Date

    init(
        name: String = "",
        birthday: Date? = nil,
        averageCycleLength: Int = 28,
        lastPeriodStart: Date? = nil,
        voiceRaw: String = VoiceTone.balanced.rawValue,
        themeRaw: String = LunaTheme.soft.rawValue,
        onboardingReasonRaw: String = OnboardingReason.curious.rawValue,
        createdAt: Date = .now
    ) {
        self.name = name
        self.birthday = birthday
        self.averageCycleLength = averageCycleLength
        self.lastPeriodStart = lastPeriodStart
        self.voiceRaw = voiceRaw
        self.themeRaw = themeRaw
        self.onboardingReasonRaw = onboardingReasonRaw
        self.createdAt = createdAt
    }
}

enum OnboardingReason: String, CaseIterable, Identifiable {
    case breakup, understand, tired, curious
    var id: String { rawValue }
    var label: String {
        switch self {
        case .breakup: return "going through a breakup"
        case .understand: return "wanting to understand myself"
        case .tired: return "tired of feeling crazy"
        case .curious: return "just curious"
        }
    }
}
