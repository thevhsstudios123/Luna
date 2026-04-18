import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selection: Tab = .home

    enum Tab: Hashable { case home, cycle, patterns, me }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home:     NavigationStack { HomeView() }
                case .cycle:    NavigationStack { CycleView() }
                case .patterns: NavigationStack { PatternsView() }
                case .me:       NavigationStack { MeView() }
                }
            }
            .themedBackground()

            LunaTabBar(selection: $selection)
        }
    }
}

struct LunaTabBar: View {
    @Binding var selection: MainTabView.Tab
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            tabItem(.home, icon: HomeIcon(), label: "home")
            tabItem(.cycle, icon: CycleIcon(), label: "cycle")
            tabItem(.patterns, icon: PatternIcon(), label: "patterns")
            tabItem(.me, icon: MeIcon(), label: "me")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(appState.theme.bgSecondary)
                .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func tabItem<I: View>(_ tab: MainTabView.Tab, icon: I, label: String) -> some View {
        Button {
            Haptics.soft()
            selection = tab
        } label: {
            VStack(spacing: 4) {
                icon
                    .frame(width: 22, height: 22)
                    .foregroundStyle(selection == tab ? appState.theme.accent : appState.theme.textSecondary)
                Text(label)
                    .font(LunaType.metaS)
                    .foregroundStyle(selection == tab ? appState.theme.accent : appState.theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// Custom organic icons — no SF symbols, matching the brief.
struct HomeIcon: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                let w = geo.size.width, h = geo.size.height
                p.move(to: CGPoint(x: 0, y: h * 0.5))
                p.addLine(to: CGPoint(x: w / 2, y: 0))
                p.addLine(to: CGPoint(x: w, y: h * 0.5))
                p.addLine(to: CGPoint(x: w, y: h))
                p.addLine(to: CGPoint(x: 0, y: h))
                p.closeSubpath()
            }
            .stroke(lineWidth: 2)
        }
    }
}

struct CycleIcon: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .trim(from: 0.05, to: 0.95)
                .stroke(style: .init(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(90))
        }
    }
}

struct PatternIcon: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                let w = geo.size.width, h = geo.size.height
                p.move(to: CGPoint(x: 0, y: h * 0.7))
                p.addCurve(to: CGPoint(x: w, y: h * 0.3),
                           control1: CGPoint(x: w * 0.25, y: h * 0.1),
                           control2: CGPoint(x: w * 0.75, y: h * 0.9))
            }
            .stroke(style: .init(lineWidth: 2, lineCap: .round))
        }
    }
}

struct MeIcon: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            VStack(spacing: 2) {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: s * 0.45, height: s * 0.45)
                Capsule()
                    .stroke(lineWidth: 2)
                    .frame(width: s * 0.75, height: s * 0.4)
                    .offset(y: 4)
            }
            .frame(width: s, height: s)
        }
    }
}
