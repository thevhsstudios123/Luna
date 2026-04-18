import SwiftUI

enum LunaTheme: String, CaseIterable, Identifiable {
    case soft, earth, midnight
    var id: String { rawValue }

    var title: String {
        switch self {
        case .soft: return "Soft"
        case .earth: return "Earth"
        case .midnight: return "Midnight"
        }
    }

    var subtitle: String {
        switch self {
        case .soft: return "pink mauve, default cozy"
        case .earth: return "terracotta and sage"
        case .midnight: return "deep mauve and gold"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .midnight: return .dark
        default: return .light
        }
    }

    var bgPrimary: Color {
        switch self {
        case .soft: return LunaColors.bgPrimary
        case .earth: return LunaColors.earthBg
        case .midnight: return LunaColors.midnightBg
        }
    }

    var bgSecondary: Color {
        switch self {
        case .soft: return LunaColors.bgSecondary
        case .earth: return LunaColors.earthBgTwo
        case .midnight: return LunaColors.midnightBgTwo
        }
    }

    var accent: Color {
        switch self {
        case .soft: return LunaColors.accentBold
        case .earth: return LunaColors.earthTerra
        case .midnight: return LunaColors.midnightGold
        }
    }

    var textPrimary: Color {
        switch self {
        case .midnight: return Color(hex: 0xF3EEE6)
        default: return LunaColors.textPrimary
        }
    }

    var textSecondary: Color {
        switch self {
        case .midnight: return Color(hex: 0xA69FA8)
        default: return LunaColors.textSecondary
        }
    }
}

struct ThemedBackground: ViewModifier {
    @EnvironmentObject var appState: AppState
    func body(content: Content) -> some View {
        content
            .background(appState.theme.bgPrimary.ignoresSafeArea())
    }
}

extension View {
    func themedBackground() -> some View { modifier(ThemedBackground()) }
}
