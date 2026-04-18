import SwiftUI

// Centralized color tokens. Theme-aware variants live in LunaTheme.
// Hex helper at the bottom keeps the palette honest to the spec.
enum LunaColors {
    static let bgPrimary    = Color(hex: 0xFAF6F1)
    static let bgSecondary  = Color(hex: 0xF0E8DD)
    static let accentSoft   = Color(hex: 0xE8B4BC)
    static let accentBold   = Color(hex: 0x6B4E71)
    static let accentWarm   = Color(hex: 0xD4846C)
    static let textPrimary  = Color(hex: 0x2D2A32)
    static let textSecondary = Color(hex: 0x6B6470)
    static let success      = Color(hex: 0x8FA68E)
    static let alert        = Color(hex: 0xC97B63)

    // Cycle phases
    static let phaseMenstrual  = Color(hex: 0xB5556B)
    static let phaseFollicular = Color(hex: 0xE8B4BC)
    static let phaseOvulation  = Color(hex: 0xF0C987)
    static let phaseLuteal     = Color(hex: 0x9A7BA8)

    // Midnight theme accents
    static let midnightBg      = Color(hex: 0x1A1620)
    static let midnightBgTwo   = Color(hex: 0x221D29)
    static let midnightGold    = Color(hex: 0xE8C87A)
    static let midnightMauve   = Color(hex: 0x8A6B92)

    // Earth theme accents
    static let earthBg         = Color(hex: 0xF5EFE6)
    static let earthBgTwo      = Color(hex: 0xE8DCC8)
    static let earthTerra      = Color(hex: 0xD4846C)
    static let earthSage       = Color(hex: 0x8FA68E)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
