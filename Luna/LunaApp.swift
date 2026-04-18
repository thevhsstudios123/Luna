import SwiftUI
import SwiftData

@main
struct LunaApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.theme.colorScheme)
                .tint(LunaColors.accentBold)
        }
        .modelContainer(for: [
            UserProfile.self,
            CheckIn.self,
            CycleEvent.self,
            Person.self,
            Interaction.self
        ])
    }
}
