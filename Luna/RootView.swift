import SwiftUI
import LocalAuthentication

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            LunaColors.bgPrimary.ignoresSafeArea()
            GrainOverlay().ignoresSafeArea()

            Group {
                if !appState.hasOnboarded {
                    OnboardingFlow()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                } else if appState.appLockEnabled && !appState.isUnlocked {
                    AppLockView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: appState.hasOnboarded)
            .animation(.easeInOut(duration: 0.4), value: appState.isUnlocked)
        }
    }
}

// Face ID / passcode gate. Keeps the UI intentional even when locked.
struct AppLockView: View {
    @EnvironmentObject var appState: AppState
    @State private var error: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            MoonAvatar(phase: .luteal)
                .frame(width: 140, height: 140)
            Text("locked for your eyes only")
                .font(LunaType.displayM)
                .foregroundStyle(LunaColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Text(error ?? "tap to unlock")
                .font(LunaType.bodyS)
                .foregroundStyle(LunaColors.textSecondary)
            Spacer()
            SoftButton(title: "unlock", style: .primary) { attempt() }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .onAppear { attempt() }
    }

    private func attempt() {
        let ctx = LAContext()
        var err: NSError?
        if ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) {
            ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "unlock Luna") { ok, _ in
                DispatchQueue.main.async {
                    if ok { appState.unlock() } else { error = "not today, apparently" }
                }
            }
        } else {
            // No biometrics available — for prototype, just unlock.
            appState.unlock()
        }
    }
}
