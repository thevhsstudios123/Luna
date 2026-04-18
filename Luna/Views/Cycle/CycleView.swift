import SwiftUI
import SwiftData

struct CycleView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \CycleEvent.date, order: .reverse) private var events: [CycleEvent]

    @State private var scrubDay: Int?
    @State private var showLog = false

    private var profile: UserProfile? { profiles.first }
    private var cycleLength: Int { profile?.averageCycleLength ?? 28 }
    private var currentDay: Int {
        CycleEngine.currentDay(lastPeriod: profile?.lastPeriodStart, cycleLength: cycleLength) ?? 1
    }
    private var displayDay: Int { scrubDay ?? currentDay }
    private var displayPhase: CyclePhase {
        CycleEngine.phase(forDay: displayDay, cycleLength: cycleLength)
    }
    private var voice: VoicePack { VoicePack(tone: appState.voice) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                CycleWheel(currentDay: displayDay, cycleLength: cycleLength, onScrub: { day in
                    scrubDay = day
                })
                .frame(height: 320)
                .padding(.horizontal, 16)

                phaseCopy
                flowLogCard
                symptomsCard
                statsCard
                Spacer(minLength: 120)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .navigationTitle("cycle")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLog) {
            LogPeriodView()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("cycle")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                Text("day \(displayDay)")
                    .font(LunaType.displayL)
                    .foregroundStyle(appState.theme.textPrimary)
            }
            Spacer()
            Button {
                Haptics.soft()
                showLog = true
            } label: {
                HStack(spacing: 6) {
                    Circle().fill(LunaColors.phaseMenstrual).frame(width: 8, height: 8)
                    Text("log period")
                        .font(LunaType.bodyS.weight(.semibold))
                        .foregroundStyle(appState.theme.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Capsule().fill(appState.theme.bgSecondary))
            }
            .buttonStyle(.plain)
        }
    }

    private var phaseCopy: some View {
        SoftCard(tint: displayPhase.color.opacity(0.18)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(displayPhase.label)
                        .font(LunaType.displayM)
                        .foregroundStyle(displayPhase.color)
                    Spacer()
                    Text("day \(displayDay)")
                        .font(LunaType.metaM)
                        .foregroundStyle(appState.theme.textSecondary)
                }
                Text(phaseLine)
                    .font(LunaType.bodyL)
                    .foregroundStyle(appState.theme.textPrimary)
            }
        }
    }

    private var phaseLine: String {
        switch (displayPhase, appState.voice) {
        case (.menstrual, .soft): return "you're resting because your body asked you to."
        case (.menstrual, .balanced): return "low energy is the assignment. don't fight your biology."
        case (.menstrual, .savage): return "you're bleeding. be kind to yourself or i'll do it for you."
        case (.follicular, .soft): return "new ideas land well this week. follow the quiet ones."
        case (.follicular, .balanced): return "creative and brave. pick something hard and start."
        case (.follicular, .savage): return "do the thing. you know the thing."
        case (.ovulation, .soft): return "a few days of magnetic warmth. use it generously."
        case (.ovulation, .balanced): return "best days to say hard things out loud."
        case (.ovulation, .savage): return "ovulating. talk. flirt. negotiate. don't text him though."
        case (.luteal, .soft): return "be soft with your plans. the fog is temporary."
        case (.luteal, .balanced): return "brain fog is hormonal. not a personality. write, don't send."
        case (.luteal, .savage): return "luteal. the call is coming from inside the uterus."
        }
    }

    private var flowLogCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("flow today")
                    .font(LunaType.displayS)
                    .foregroundStyle(appState.theme.textPrimary)
                HStack(spacing: 8) {
                    ForEach(FlowIntensity.allCases) { f in
                        ChipButton(title: f.label, isSelected: todayFlow == f) { logFlow(f) }
                    }
                }
            }
        }
    }

    private var todayFlow: FlowIntensity {
        events.first(where: { $0.date.isSameDay(as: .now) && $0.flow != .none })?.flow ?? .none
    }

    private func logFlow(_ f: FlowIntensity) {
        let event = CycleEvent(date: .now, kind: .period, flow: f)
        modelContext.insert(event)
        Haptics.success()
    }

    private var symptomsCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("how your body feels")
                    .font(LunaType.displayS)
                    .foregroundStyle(appState.theme.textPrimary)
                FlowLayout(spacing: 8) {
                    ForEach(Symptom.allCases) { s in
                        ChipButton(title: s.label, isSelected: todaysSymptoms.contains(s)) { toggleSymptom(s) }
                    }
                }
            }
        }
    }

    private var todaysSymptoms: Set<Symptom> {
        Set(events.first(where: { $0.date.isSameDay(as: .now) && $0.kind == .symptom })?.symptoms ?? [])
    }

    private func toggleSymptom(_ s: Symptom) {
        let existing = events.first(where: { $0.date.isSameDay(as: .now) && $0.kind == .symptom })
        if let e = existing {
            var set = Set(e.symptoms)
            if set.contains(s) { set.remove(s) } else { set.insert(s) }
            e.symptoms = Array(set)
        } else {
            let ev = CycleEvent(date: .now, kind: .symptom, symptoms: [s])
            modelContext.insert(ev)
        }
        Haptics.selection()
    }

    private var statsCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("cycle stats")
                    .font(LunaType.metaM.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                    .textCase(.uppercase)
                HStack(spacing: 16) {
                    StatTile(label: "avg", value: "\(cycleLength)d")
                }
                if let p = nextPredict {
                    PredictionRow(title: "next period", prediction: p)
                }
                if let o = ovPredict {
                    PredictionRow(title: "ovulation window", prediction: o)
                }
                if events.isEmpty {
                    Text(voice.emptyCheckIns)
                        .font(LunaType.bodyS)
                        .foregroundStyle(appState.theme.textSecondary)
                }
            }
        }
    }

    // We send the engine the lengths between consecutive period-start events
    // so the spread reflects this user's actual variability.
    private var recentLengths: [Int] {
        let starts = events.filter { $0.kind == .period && $0.flow != .none }
            .sorted(by: { $0.date < $1.date })
            .map(\.date)
        guard starts.count >= 2 else { return [] }
        var out: [Int] = []
        for i in 1..<starts.count {
            let d = Calendar.current.dateComponents([.day], from: starts[i-1], to: starts[i]).day ?? 0
            if d > 14 && d < 60 { out.append(d) }
        }
        return out
    }

    private var nextPredict: CycleEngine.Prediction? {
        CycleEngine.nextPeriodPrediction(lastPeriod: profile?.lastPeriodStart, cycleLength: cycleLength, recentLengths: recentLengths)
    }
    private var ovPredict: CycleEngine.Prediction? {
        CycleEngine.ovulationPrediction(lastPeriod: profile?.lastPeriodStart, cycleLength: cycleLength, recentLengths: recentLengths)
    }
}

// Honest prediction row: shows the window + the confidence behind it.
struct PredictionRow: View {
    var title: String
    var prediction: CycleEngine.Prediction
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(LunaType.bodyS.weight(.semibold))
                    .foregroundStyle(appState.theme.textSecondary)
                Spacer()
                Text(confidenceLabel)
                    .font(LunaType.metaS.weight(.semibold))
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .foregroundStyle(LunaColors.textSecondary)
                    .background(Capsule().fill(LunaColors.bgSecondary))
            }
            Text(rangeText)
                .font(LunaType.displayS)
                .foregroundStyle(appState.theme.textPrimary)
            // Honesty note — we never show a single date.
            Text("most likely \(prediction.likely.monthDay.lowercased())")
                .font(LunaType.metaS)
                .foregroundStyle(appState.theme.textSecondary)
        }
    }

    private var rangeText: String {
        "\(prediction.early.monthDay.lowercased()) – \(prediction.late.monthDay.lowercased())"
    }
    private var confidenceLabel: String {
        switch prediction.confidence {
        case ..<0.34: return "low confidence"
        case 0.34..<0.67: return "fair"
        default: return "high confidence"
        }
    }
}

struct StatTile: View {
    var label: String
    var value: String
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(LunaType.displayS)
                .foregroundStyle(appState.theme.textPrimary)
            Text(label)
                .font(LunaType.metaS)
                .foregroundStyle(appState.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LogPeriodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var date: Date = .now
    @State private var flow: FlowIntensity = .medium

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("log period")
                    .font(LunaType.displayL)
                DatePicker("start date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Text("flow")
                    .font(LunaType.displayS)
                HStack(spacing: 8) {
                    ForEach(FlowIntensity.allCases) { f in
                        ChipButton(title: f.label, isSelected: flow == f) { flow = f }
                    }
                }
                Spacer()
                SoftButton(title: "log it") {
                    let e = CycleEvent(date: date, kind: .period, flow: flow)
                    modelContext.insert(e)
                    if let p = profiles.first { p.lastPeriodStart = date }
                    Haptics.success()
                    dismiss()
                }
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
