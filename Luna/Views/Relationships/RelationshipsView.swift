import SwiftUI
import SwiftData

struct RelationshipsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.createdAt) private var people: [Person]

    @State private var showAdd = false

    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("relationship lens")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text("who you're with, who you become")
                            .font(LunaType.displayM)
                            .foregroundStyle(appState.theme.textPrimary)
                    }
                    Spacer()
                    Button {
                        Haptics.soft()
                        showAdd = true
                    } label: {
                        Text("+")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(appState.theme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(appState.theme.bgSecondary))
                    }
                }

                if !appState.isPremium {
                    PremiumTeaser()
                }

                if people.isEmpty {
                    EmptyStateCard(title: "add the humans", message: voice.emptyRelationships)
                } else {
                    ForEach(people) { person in
                        NavigationLink(destination: PersonDetailView(person: person)) {
                            PersonRow(person: person)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer(minLength: 120)
            }
            .padding(20)
        }
        .navigationTitle("relationships")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAdd) { AddPersonView() }
    }
}

struct PersonRow: View {
    var person: Person
    @EnvironmentObject var appState: AppState

    private var heartState: HeartState {
        let deltas = person.interactions.map(\.moodDelta)
        guard !deltas.isEmpty else { return .neutral }
        let avg = Double(deltas.reduce(0, +)) / Double(deltas.count)
        if avg <= -1.5 { return .armored }
        if avg < 0 { return .drained }
        if avg >= 1 { return .full }
        return .neutral
    }

    var body: some View {
        SoftCard {
            HStack(spacing: 14) {
                HeartAvatar(state: heartState)
                    .frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 3) {
                    Text(person.name)
                        .font(LunaType.displayS)
                        .foregroundStyle(appState.theme.textPrimary)
                    Text(person.relationship.label)
                        .font(LunaType.bodyS)
                        .foregroundStyle(appState.theme.textSecondary)
                    Text("\(person.interactions.count) logged")
                        .font(LunaType.metaS)
                        .foregroundStyle(appState.theme.textSecondary)
                }
                Spacer()
                Text(heartState.label)
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(heartState.color)
            }
        }
    }
}

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var relationship: RelationshipKind = .friend
    @State private var emoji = "🌙"

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("add someone")
                    .font(LunaType.displayL)
                TextField("name", text: $name)
                    .font(LunaType.bodyL)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(LunaColors.bgSecondary))
                Text("relationship")
                    .font(LunaType.displayS)
                FlowLayout(spacing: 8) {
                    ForEach(RelationshipKind.allCases) { r in
                        ChipButton(title: r.label, isSelected: relationship == r) { relationship = r }
                    }
                }
                Text("emoji")
                    .font(LunaType.displayS)
                HStack(spacing: 8) {
                    ForEach(["🌙", "🔥", "🌸", "☕️", "🪐", "🌊", "🐝", "🎀"], id: \.self) { e in
                        Button {
                            emoji = e; Haptics.selection()
                        } label: {
                            Text(e)
                                .font(.system(size: 26))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(emoji == e ? LunaColors.accentSoft : LunaColors.bgSecondary))
                        }
                    }
                }
                Spacer()
                SoftButton(title: "add") {
                    let p = Person(name: name, relationship: relationship, photoEmoji: emoji)
                    modelContext.insert(p)
                    Haptics.success()
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(20)
            .themedBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close") { dismiss() }
                }
            }
        }
    }
}

struct PersonDetailView: View {
    var person: Person
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @State private var showLog = false

    private var heartState: HeartState {
        let deltas = person.interactions.map(\.moodDelta)
        guard !deltas.isEmpty else { return .neutral }
        let avg = Double(deltas.reduce(0, +)) / Double(deltas.count)
        if avg <= -1.5 { return .armored }
        if avg < 0 { return .drained }
        if avg >= 1 { return .full }
        return .neutral
    }

    private var avgDelta: Double {
        let d = person.interactions.map(\.moodDelta)
        return d.isEmpty ? 0 : Double(d.reduce(0, +)) / Double(d.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 16) {
                    HeartAvatar(state: heartState)
                        .frame(width: 80, height: 80)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name)
                            .font(LunaType.displayL)
                            .foregroundStyle(appState.theme.textPrimary)
                        Text(person.relationship.label)
                            .font(LunaType.bodyM)
                            .foregroundStyle(appState.theme.textSecondary)
                    }
                }

                SoftCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("how they land")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        Text(impactCopy)
                            .font(LunaType.displayS)
                            .foregroundStyle(appState.theme.textPrimary)
                    }
                }

                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("mood delta (last 10)")
                            .font(LunaType.metaM.weight(.semibold))
                            .foregroundStyle(appState.theme.textSecondary)
                            .textCase(.uppercase)
                        SparkLine(values: person.interactions.prefix(10).map { Double($0.moodDelta) }.reversed())
                            .frame(height: 60)
                    }
                }

                SoftButton(title: "log an interaction") { showLog = true }

                Text("history")
                    .font(LunaType.displayS)
                    .foregroundStyle(appState.theme.textPrimary)
                    .padding(.top, 8)

                if person.interactions.isEmpty {
                    EmptyStateCard(title: "nothing logged yet",
                                   message: "log the next time you see them. luna's watching for patterns.")
                } else {
                    ForEach(person.interactions.sorted(by: { $0.date > $1.date })) { interaction in
                        SoftCard {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(interaction.kind.label).font(LunaType.bodyM).foregroundStyle(appState.theme.textPrimary)
                                    Spacer()
                                    Text(interaction.date.monthDay.lowercased()).font(LunaType.metaM).foregroundStyle(appState.theme.textSecondary)
                                }
                                HStack(spacing: 8) {
                                    Text("before: \(interaction.moodBefore)").font(LunaType.bodyS).foregroundStyle(appState.theme.textSecondary)
                                    Text("→").foregroundStyle(appState.theme.textSecondary)
                                    Text("after: \(interaction.moodAfter)").font(LunaType.bodyS).foregroundStyle(appState.theme.textPrimary)
                                    Spacer()
                                    DeltaBadge(delta: interaction.moodDelta)
                                }
                                if !interaction.note.isEmpty {
                                    Text(interaction.note).font(LunaType.bodyM).foregroundStyle(appState.theme.textPrimary).italic()
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLog) {
            LogInteractionView(person: person)
        }
    }

    private var impactCopy: String {
        switch (heartState, appState.voice) {
        case (.full, _): return "you feel better after \(person.name). that's not nothing."
        case (.neutral, _): return "neutral so far. give it a few more data points."
        case (.drained, _): return "you tend to feel lower after \(person.name). pattern, not vibes."
        case (.armored, .soft): return "\(person.name) keeps costing you. be gentle with yourself here."
        case (.armored, .balanced): return "\(person.name) consistently lowers your mood. take that seriously."
        case (.armored, .savage): return "\(person.name) costs you every time. you know what to do."
        }
    }
}

struct DeltaBadge: View {
    var delta: Int
    var body: some View {
        Text(delta >= 0 ? "+\(delta)" : "\(delta)")
            .font(LunaType.metaM.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(color)
            .background(Capsule().fill(color.opacity(0.15)))
    }
    private var color: Color {
        if delta <= -2 { return LunaColors.alert }
        if delta < 0 { return LunaColors.accentWarm }
        if delta == 0 { return LunaColors.textSecondary }
        return LunaColors.success
    }
}

struct SparkLine: View {
    var values: [Double]
    var body: some View {
        GeometryReader { geo in
            if values.isEmpty {
                Text("not enough data yet")
                    .font(LunaType.bodyS)
                    .foregroundStyle(LunaColors.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let minV = values.min() ?? -1
                let maxV = values.max() ?? 1
                let range = max(maxV - minV, 1)
                Path { p in
                    for (i, v) in values.enumerated() {
                        let x = geo.size.width * CGFloat(i) / CGFloat(max(values.count - 1, 1))
                        let y = geo.size.height * (1 - CGFloat((v - minV) / range))
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(LunaColors.accentBold, style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

struct LogInteractionView: View {
    var person: Person
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var kind: InteractionKind = .text
    @State private var before: Int = 5
    @State private var after: Int = 5
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("logged with \(person.name)")
                        .font(LunaType.displayL)
                    Text("type")
                        .font(LunaType.displayS)
                    HStack(spacing: 8) {
                        ForEach(InteractionKind.allCases) { k in
                            ChipButton(title: k.label, isSelected: kind == k) { kind = k }
                        }
                    }
                    SoftCard { MoodSlider(title: "before", value: $before, labels: ("heavy", "light")) }
                    SoftCard { MoodSlider(title: "after", value: $after, labels: ("heavy", "light")) }
                    SoftCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("what happened (optional)")
                                .font(LunaType.bodyS.weight(.semibold))
                                .foregroundStyle(LunaColors.textSecondary)
                            TextField("a line or two", text: $note, axis: .vertical)
                                .font(LunaType.bodyL)
                                .lineLimit(3, reservesSpace: true)
                        }
                    }
                    SoftButton(title: "save") {
                        let i = Interaction(date: .now, kind: kind, moodBefore: before, moodAfter: after, note: note, person: person)
                        modelContext.insert(i)
                        Haptics.success()
                        dismiss()
                    }
                }
                .padding(20)
            }
            .themedBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("close") { dismiss() } }
            }
        }
    }
}
