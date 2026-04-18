import SwiftUI

// Rounded, tactile card. The default container across the app.
struct SoftCard<Content: View>: View {
    var padding: CGFloat = 20
    var corner: CGFloat = 22
    var tint: Color? = nil
    @ViewBuilder var content: () -> Content
    @EnvironmentObject var appState: AppState

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(tint ?? appState.theme.bgSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(LunaColors.textPrimary.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 14, y: 6)
    }
}
