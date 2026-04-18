import AppIntents
import SwiftData
import Foundation

// Siri / Shortcuts entry points. The 30-second check-in becomes a 3-second one:
// "hey siri, log a 4 in luna" or "hey siri, log a fight with [name]" and we save it.
//
// These run in the main app process — no extension target required.

@available(iOS 17.0, *)
struct LogMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Mood"
    static var description = IntentDescription("Log how you're feeling right now in Luna.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Mood", description: "How you feel, 1 (heavy) to 10 (light).")
    var mood: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: CheckIn.self, UserProfile.self, CycleEvent.self, Person.self, Interaction.self)
        let context = container.mainContext
        let ci = CheckIn(date: .now, mood: clamp(mood), energy: 5, selfImage: 5)
        context.insert(ci)
        try? context.save()
        let confirm = quipFor(mood: clamp(mood))
        return .result(dialog: IntentDialog(stringLiteral: confirm))
    }

    private func clamp(_ x: Int) -> Int { min(10, max(1, x)) }

    private func quipFor(mood: Int) -> String {
        switch mood {
        case ...3: return "logged. that's a hard one — be kind to yourself."
        case 4...5: return "logged. middling is honest."
        case 6...8: return "logged. nice."
        default: return "logged. glow."
        }
    }
}

@available(iOS 17.0, *)
struct QuickInteractionIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a person interaction"
    static var description = IntentDescription("Log a quick interaction with someone you've added to Luna.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Person name")
    var personName: String

    @Parameter(title: "How you felt before, 1-10")
    var moodBefore: Int

    @Parameter(title: "How you felt after, 1-10")
    var moodAfter: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: CheckIn.self, UserProfile.self, CycleEvent.self, Person.self, Interaction.self)
        let context = container.mainContext
        let descriptor = FetchDescriptor<Person>()
        let people = (try? context.fetch(descriptor)) ?? []
        let target = people.first(where: { $0.name.lowercased() == personName.lowercased() })

        let i = Interaction(date: .now, kind: .text, moodBefore: moodBefore, moodAfter: moodAfter, note: "via siri", person: target)
        context.insert(i)
        try? context.save()

        let delta = moodAfter - moodBefore
        let line: String = {
            switch delta {
            case ...(-2): return "logged. \(personName) cost you. luna noticed."
            case -1: return "logged. small dip after \(personName)."
            case 0: return "logged. neutral with \(personName)."
            case 1: return "logged. small lift from \(personName)."
            default: return "logged. \(personName) lifted you."
            }
        }()
        return .result(dialog: IntentDialog(stringLiteral: line))
    }
}

@available(iOS 17.0, *)
struct LunaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogMoodIntent(),
            phrases: [
                "Log my mood in \(.applicationName)",
                "Tell \(.applicationName) how I feel"
            ],
            shortTitle: "Log Mood",
            systemImageName: "heart.fill"
        )
        AppShortcut(
            intent: QuickInteractionIntent(),
            phrases: [
                "Log a person in \(.applicationName)"
            ],
            shortTitle: "Log Person",
            systemImageName: "person.fill"
        )
    }
}
