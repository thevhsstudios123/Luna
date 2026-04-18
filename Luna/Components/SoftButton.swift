import SwiftUI

struct SoftButton: View {
    enum Style { case primary, secondary, ghost }

    var title: String
    var style: Style = .primary
    var action: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button {
            Haptics.soft()
            action()
        } label: {
            Text(title)
                .font(LunaType.bodyL.weight(.medium))
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(fg)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(bg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var fg: Color {
        switch style {
        case .primary: return appState.theme == .midnight ? LunaColors.midnightBg : Color.white
        case .secondary: return appState.theme.accent
        case .ghost: return appState.theme.textSecondary
        }
    }
    private var bg: Color {
        switch style {
        case .primary: return appState.theme.accent
        case .secondary: return appState.theme.bgSecondary
        case .ghost: return Color.clear
        }
    }
    private var border: Color {
        switch style {
        case .ghost: return LunaColors.textPrimary.opacity(0.12)
        default: return Color.clear
        }
    }
}

struct ChipButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(LunaType.bodyS.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(isSelected ? fg : appState.theme.textPrimary)
                .background(
                    Capsule().fill(isSelected ? appState.theme.accent : appState.theme.bgSecondary)
                )
                .overlay(
                    Capsule().stroke(LunaColors.textPrimary.opacity(isSelected ? 0 : 0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var fg: Color {
        appState.theme == .midnight ? LunaColors.midnightBg : Color.white
    }
}
