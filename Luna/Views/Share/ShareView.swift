import SwiftUI
import SwiftData

// Shareable outputs: weekly recap, monthly recap, year in review.
// Cards render at Instagram Story dimensions (1080x1920 aspect = 9:16).
struct ShareView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("share")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                Text("your year, screenshot-ready")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)

                NavigationLink(destination: WeeklyRecapView()) {
                    ShareOptionCard(title: "weekly recap", sub: "last 7 days, in one card", accent: LunaColors.accentSoft)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: MonthlyRecapView()) {
                    ShareOptionCard(title: "monthly recap", sub: "your cycle, visually", accent: LunaColors.phaseLuteal)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: YearInReviewView()) {
                    ShareOptionCard(title: "year in review", sub: "spotify wrapped, but for your soul", accent: LunaColors.accentBold)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 80)
            }
            .padding(20)
        }
        .navigationTitle("share")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShareOptionCard: View {
    var title: String
    var sub: String
    var accent: Color
    @EnvironmentObject var appState: AppState
    var body: some View {
        SoftCard(tint: accent.opacity(0.18)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(LunaType.displayS).foregroundStyle(appState.theme.textPrimary)
                    Text(sub).font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                }
                Spacer()
                Image(systemName: "square.and.arrow.up").foregroundStyle(appState.theme.accent)
            }
        }
    }
}

struct WeeklyRecapView: View {
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @EnvironmentObject var appState: AppState

    private var thisWeek: [CheckIn] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return checkIns.filter { $0.date >= weekAgo }
    }

    private var avgMood: Double {
        thisWeek.isEmpty ? 0 : Double(thisWeek.map(\.mood).reduce(0, +)) / Double(thisWeek.count)
    }

    var body: some View {
        ScrollView {
            VStack {
                StoryCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("your week")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .textCase(.uppercase)
                        Text(weekHeadline)
                            .font(LunaType.displayXL)
                            .foregroundStyle(.white)
                        HStack(spacing: 12) {
                            MiniStat(value: "\(thisWeek.count)", label: "check-ins")
                            MiniStat(value: String(format: "%.1f", avgMood), label: "avg mood")
                        }
                        Spacer()
                        Text("luna • \(Date.now.monthDay.lowercased())")
                            .font(LunaType.metaS)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(28)
                }
                .padding(.horizontal, 20)

                SoftButton(title: "share", style: .primary) { }
                    .padding(.horizontal, 20).padding(.top, 16)
            }
        }
        .navigationTitle("weekly recap")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var weekHeadline: String {
        switch avgMood {
        case ..<4: return "it was a heavy one."
        case 4..<6: return "a middling week. you showed up."
        case 6..<8: return "a bright stretch."
        default: return "a glowing week."
        }
    }
}

struct MonthlyRecapView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StoryCard(gradient: [LunaColors.phaseMenstrual, LunaColors.phaseLuteal]) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("your cycle, visualized")
                            .font(LunaType.displayL)
                            .foregroundStyle(.white)
                        CycleWheel(currentDay: 14, cycleLength: 28)
                            .frame(height: 280)
                            .colorScheme(.dark)
                        Spacer()
                        Text("luna").font(LunaType.metaM).foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(28)
                }
                .padding(.horizontal, 20)

                SoftButton(title: "share", style: .primary) { }
                    .padding(.horizontal, 20)
            }
        }
        .navigationTitle("monthly recap")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct YearInReviewView: View {
    @State private var step = 0
    let steps = 5

    var body: some View {
        ZStack {
            LinearGradient(colors: [LunaColors.accentBold, LunaColors.phaseMenstrual, LunaColors.accentWarm],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                // Story progress bars
                HStack(spacing: 4) {
                    ForEach(0..<steps, id: \.self) { i in
                        Capsule()
                            .fill(Color.white.opacity(i <= step ? 1.0 : 0.3))
                            .frame(height: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                Group {
                    switch step {
                    case 0: YearSlide(kicker: "your year", headline: "this was the year you started listening.")
                    case 1: YearSlide(kicker: "check-ins", headline: "you showed up 142 times.")
                    case 2: YearSlide(kicker: "your word", headline: "\"tender\" appeared in 38 check-ins.")
                    case 3: YearSlide(kicker: "your hardest day", headline: "day 24 of every cycle. you know now.")
                    default: YearSlide(kicker: "the receipt", headline: "you did the scary, quiet work. that's it. that's the year.")
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.5), value: step)

                Spacer()
            }
            .onTapGesture { next() }
        }
        .navigationBarHidden(true)
        .onAppear { Haptics.soft() }
    }

    private func next() {
        Haptics.selection()
        if step < steps - 1 { step += 1 }
    }
}

struct YearSlide: View {
    var kicker: String
    var headline: String
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(kicker)
                .font(LunaType.metaM.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
                .textCase(.uppercase)
            Text(headline)
                .font(LunaType.displayXL)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(32)
    }
}

// 9:16 story card with a gradient backdrop and padding.
struct StoryCard<Content: View>: View {
    var gradient: [Color] = [LunaColors.accentBold, LunaColors.phaseMenstrual]
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                GrainOverlay()
                content()
            }
            .frame(width: geo.size.width, height: geo.size.width * 16 / 9)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .aspectRatio(9/16, contentMode: .fit)
    }
}

struct MiniStat: View {
    var value: String
    var label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(LunaType.displayM)
                .foregroundStyle(.white)
            Text(label)
                .font(LunaType.metaM)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.15)))
    }
}
