// LunaQuickLogWidget — Lock Screen + Home Screen widget.
//
// SCAFFOLD ONLY — this file is not yet part of the Luna build target.
// To activate it, add a Widget Extension target to the Xcode project:
//
//   1. In Xcode: File → New → Target → Widget Extension. Name it "LunaWidget".
//      Uncheck "Include Configuration Intent" unless you want the user to pick mood
//      from the widget gallery.
//   2. Replace the auto-generated Widget swift file with this one.
//   3. Add Luna's app group capability to BOTH targets so SwiftData can sync.
//      (Signing & Capabilities → + Capability → App Groups → group.com.luna.app)
//   4. Move LogMoodIntent into a shared Swift file accessible to both targets,
//      OR import via a tiny Frameworks/LunaShared module.
//   5. Build the widget scheme. The widget appears in the gallery on the simulator.
//
// Once active: the widget exposes 3 buttons (1, 5, 10) that fire LogMoodIntent
// without opening the app — one tap to log how you feel from the lock screen.

import WidgetKit
import SwiftUI
import AppIntents

@available(iOS 17.0, *)
struct LunaQuickLogProvider: TimelineProvider {
    func placeholder(in context: Context) -> LunaQuickLogEntry {
        LunaQuickLogEntry(date: .now)
    }
    func getSnapshot(in context: Context, completion: @escaping (LunaQuickLogEntry) -> Void) {
        completion(LunaQuickLogEntry(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LunaQuickLogEntry>) -> Void) {
        let entry = LunaQuickLogEntry(date: .now)
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }
}

@available(iOS 17.0, *)
struct LunaQuickLogEntry: TimelineEntry {
    let date: Date
}

@available(iOS 17.0, *)
struct LunaQuickLogView: View {
    var entry: LunaQuickLogEntry

    var body: some View {
        VStack(spacing: 8) {
            Text("how do you feel?")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                quickButton(emoji: "🌧️", value: 2)
                quickButton(emoji: "🙂", value: 5)
                quickButton(emoji: "✨", value: 9)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    @ViewBuilder
    private func quickButton(emoji: String, value: Int) -> some View {
        // The button executes the LogMoodIntent with no app launch.
        Button(intent: PlaceholderLogIntent(mood: value)) {
            Text(emoji).font(.title2)
        }
        .buttonStyle(.plain)
    }
}

// Placeholder so the widget scaffold compiles standalone. Replace with the real
// LogMoodIntent (in Luna/Intents/LunaIntents.swift) once shared via app group.
@available(iOS 17.0, *)
struct PlaceholderLogIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Mood (placeholder)"
    @Parameter(title: "mood") var mood: Int
    init() { self.mood = 5 }
    init(mood: Int) { self.mood = mood }
    func perform() async throws -> some IntentResult { .result() }
}

@available(iOS 17.0, *)
struct LunaQuickLogWidget: Widget {
    let kind: String = "LunaQuickLogWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunaQuickLogProvider()) { entry in
            LunaQuickLogView(entry: entry)
        }
        .configurationDisplayName("Quick log")
        .description("Tap to tell Luna how you feel without opening the app.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}
