import Foundation

// Voice safety rails. The Savage tone is funny when she's having a normal day.
// On a hard week, the same tone reads as mean. AdaptiveVoice watches the recent
// mood baseline and softens the user's chosen voice down a notch when she's struggling.
//
// User can override via "always honor my voice setting" in settings, but the default
// is for luna to read the room.
enum AdaptiveVoice {
    // Returns the effective tone after applying safety rails.
    // Rule: if the average of the last 5 check-ins is <= 4 (out of 10),
    // step the tone down one level toward Soft. If the user is already Soft,
    // it stays Soft. Always honor an explicit "always" override.
    static func resolved(userVoice: VoiceTone,
                         recentCheckIns: [CheckIn],
                         alwaysHonorUserVoice: Bool) -> VoiceTone {
        guard !alwaysHonorUserVoice else { return userVoice }

        let recent = recentCheckIns.prefix(5)
        guard recent.count >= 3 else { return userVoice }

        let avg = Double(recent.map(\.mood).reduce(0, +)) / Double(recent.count)
        guard avg <= 4.0 else { return userVoice }

        switch userVoice {
        case .savage:   return .balanced
        case .balanced: return .soft
        case .soft:     return .soft
        }
    }

    // Surface a one-line, optional disclosure when the voice has been adapted —
    // so users don't feel gaslit by an unexpected tone shift.
    static func adaptedDisclosure(userVoice: VoiceTone, effective: VoiceTone) -> String? {
        guard userVoice != effective else { return nil }
        switch userVoice {
        case .savage where effective == .balanced:
            return "softened from savage. you've had a rough stretch. tap to override."
        case .balanced where effective == .soft:
            return "softened from balanced. luna's reading the room. tap to override."
        default:
            return nil
        }
    }
}
