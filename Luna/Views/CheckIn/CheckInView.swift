import SwiftUI
import SwiftData

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState

    @State private var mood: Int = 6
    @State private var energy: Int = 5
    @State private var selfImage: Int = 6
    @State private var tags: Set<MoodTag> = []
    @State private var journal: String = ""
    @State private var savedBanner: Bool = false

    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("check-in")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text(headline)
                            .font(LunaType.displayL)
                            .foregroundStyle(appState.theme.textPrimary)
                    }

                    SoftCard { MoodSlider(title: "mood", value: $mood, labels: ("heavy", "light")) }
                    SoftCard { MoodSlider(title: "energy", value: $energy, labels: ("tired", "wired")) }
                    SoftCard { MoodSlider(title: "how you feel about yourself", value: $selfImage, labels: ("rough", "radiant")) }

                    SoftCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("today, you were")
                                .font(LunaType.displayS)
                                .foregroundStyle(appState.theme.textPrimary)
                            TagGrid(tags: MoodTag.allCases, selected: $tags)
                        }
                    }

                    SoftCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("one sentence. that's it.")
                                .font(LunaType.displayS)
                                .foregroundStyle(appState.theme.textPrimary)
                            TextField("optional. unfiltered.", text: $journal, axis: .vertical)
                                .font(LunaType.bodyL)
                                .lineLimit(3, reservesSpace: true)
                        }
                    }

                    SoftButton(title: "save", style: .primary) { save() }
                    Button(voice.skipLabel) { dismiss() }
                        .font(LunaType.bodyS)
                        .foregroundStyle(appState.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
            .themedBackground()
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if savedBanner {
                    Text(voice.checkInDone)
                        .font(LunaType.bodyM.weight(.semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(LunaColors.success.opacity(0.25)))
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close") { dismiss() }
                        .foregroundStyle(appState.theme.textSecondary)
                }
            }
        }
    }

    private var headline: String {
        switch appState.voice {
        case .soft:     return "how are you, really?"
        case .balanced: return "tell luna the truth."
        case .savage:   return "no vibes. just data."
        }
    }

    private func save() {
        let ci = CheckIn(date: .now, mood: mood, energy: energy, selfImage: selfImage,
                         tagsRaw: tags.map { $0.rawValue }.joined(separator: ","),
                         journal: journal)
        modelContext.insert(ci)
        Haptics.success()
        withAnimation(.easeInOut(duration: 0.3)) { savedBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { dismiss() }
    }
}
