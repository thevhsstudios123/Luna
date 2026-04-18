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
    @Published var appLockEnabled: Bool { didSet { defaults.set(appLockEnabled, forKey: K.lock) } }
    @Published var stealthMode: Bool { didSet { defaults.set(stealthMode, forKey: K.stealth) } }
    @Published var isPremium: Bool { didSet { defaults.set(isPremium, forKey: K.premium) } }
    @Published var displayName: String { didSet { defaults.set(displayName, forKey: K.name) } }
    @Published var isUnlocked: Bool

    @Published var notifyMorning: Bool { didSet { defaults.set(notifyMorning, forKey: K.notifyMorning) } }
    @Published var notifyPatterns: Bool { didSet { defaults.set(notifyPatterns, forKey: K.notifyPatterns) } }
    @Published var notifyRelationships: Bool { didSet { defaults.set(notifyRelationships, forKey: K.notifyRel) } }

    private let defaults = UserDefaults.standard

    enum K {
        static let hasOnboarded = "luna.hasOnboarded"
        static let theme = "luna.themeRaw"
        static let voice = "luna.voiceRaw"
        static let lock = "luna.isLocked"
        static let stealth = "luna.stealthMode"
        static let premium = "luna.isPremium"
        static let name = "luna.displayName"
        static let notifyMorning = "luna.notif.morning"
        static let notifyPatterns = "luna.notif.patterns"
        static let notifyRel = "luna.notif.relationships"
    }

    init() {
        let d = UserDefaults.standard
        hasOnboarded = d.bool(forKey: K.hasOnboarded)
        theme = LunaTheme(rawValue: d.string(forKey: K.theme) ?? "") ?? .soft
        voice = VoiceTone(rawValue: d.string(forKey: K.voice) ?? "") ?? .balanced
        appLockEnabled = d.bool(forKey: K.lock)
        stealthMode = d.bool(forKey: K.stealth)
        isPremium = d.bool(forKey: K.premium)
        displayName = d.string(forKey: K.name) ?? ""
        notifyMorning = d.object(forKey: K.notifyMorning) as? Bool ?? true
        notifyPatterns = d.object(forKey: K.notifyPatterns) as? Bool ?? true
        notifyRelationships = d.object(forKey: K.notifyRel) as? Bool ?? true
        isUnlocked = !d.bool(forKey: K.lock)
    }

    func unlock() { isUnlocked = true }
    func lock() { isUnlocked = false }
}
