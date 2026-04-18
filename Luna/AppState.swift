import SwiftUI
import Combine

// Global, non-persisted app state. Things that belong in SwiftData live in Models/.
// Uses @Published + UserDefaults rather than @AppStorage so SwiftUI observers refresh
// reliably when values change from anywhere in the app.
@MainActor
final class AppState: ObservableObject {
    @Published var hasOnboarded: Bool { didSet { defaults.set(hasOnboarded, forKey: K.hasOnboarded) } }
    @Published var theme: LunaTheme { didSet { defaults.set(theme.rawValue, forKey: K.theme) } }
    @Published var voice: VoiceTone { didSet { defaults.set(voice.rawValue, forKey: K.voice) } }
    @Published var voiceIntensity: VoiceIntensity { didSet { defaults.set(voiceIntensity.rawValue, forKey: K.voiceInt) } }
    @Published var alwaysHonorVoice: Bool { didSet { defaults.set(alwaysHonorVoice, forKey: K.honorVoice) } }
    @Published var appLockEnabled: Bool { didSet { defaults.set(appLockEnabled, forKey: K.lock) } }
    @Published var stealthMode: Bool { didSet { defaults.set(stealthMode, forKey: K.stealth) } }
    @Published var isPremium: Bool { didSet { defaults.set(isPremium, forKey: K.premium) } }
    @Published var displayName: String { didSet { defaults.set(displayName, forKey: K.name) } }
    @Published var isUnlocked: Bool
    @Published var season: Season { didSet { defaults.set(season.rawValue, forKey: K.season) } }

    @Published var notifyMorning: Bool { didSet { defaults.set(notifyMorning, forKey: K.notifyMorning) } }
    @Published var notifyPatterns: Bool { didSet { defaults.set(notifyPatterns, forKey: K.notifyPatterns) } }
    @Published var notifyRelationships: Bool { didSet { defaults.set(notifyRelationships, forKey: K.notifyRel) } }

    private let defaults = UserDefaults.standard

    enum K {
        static let hasOnboarded = "luna.hasOnboarded"
        static let theme = "luna.themeRaw"
        static let voice = "luna.voiceRaw"
        static let voiceInt = "luna.voiceIntensity"
        static let honorVoice = "luna.honorVoice"
        static let lock = "luna.isLocked"
        static let stealth = "luna.stealthMode"
        static let premium = "luna.isPremium"
        static let name = "luna.displayName"
        static let season = "luna.season"
        static let notifyMorning = "luna.notif.morning"
        static let notifyPatterns = "luna.notif.patterns"
        static let notifyRel = "luna.notif.relationships"
    }

    init() {
        let d = UserDefaults.standard
        hasOnboarded = d.bool(forKey: K.hasOnboarded)
        theme = LunaTheme(rawValue: d.string(forKey: K.theme) ?? "") ?? .soft
        voice = VoiceTone(rawValue: d.string(forKey: K.voice) ?? "") ?? .balanced
        voiceIntensity = VoiceIntensity(rawValue: d.integer(forKey: K.voiceInt)) ?? .normal
        alwaysHonorVoice = d.bool(forKey: K.honorVoice)
        appLockEnabled = d.bool(forKey: K.lock)
        stealthMode = d.bool(forKey: K.stealth)
        isPremium = d.bool(forKey: K.premium)
        displayName = d.string(forKey: K.name) ?? ""
        season = Season(rawValue: d.string(forKey: K.season) ?? "") ?? .dawn
        notifyMorning = d.object(forKey: K.notifyMorning) as? Bool ?? true
        notifyPatterns = d.object(forKey: K.notifyPatterns) as? Bool ?? true
        notifyRelationships = d.object(forKey: K.notifyRel) as? Bool ?? true
        isUnlocked = !d.bool(forKey: K.lock)
    }

    func unlock() { isUnlocked = true }
    func lock() { isUnlocked = false }

    // Promote season based on cumulative check-ins. Called from views with the count.
    func recomputeSeason(checkInCount: Int) {
        let earned = Season.allCases.last(where: { checkInCount >= $0.unlocksAtCheckIns }) ?? .dawn
        if earned.unlocksAtCheckIns > season.unlocksAtCheckIns {
            season = earned
        }
    }
}
