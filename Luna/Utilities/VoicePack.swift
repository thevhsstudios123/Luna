import Foundation

enum VoiceTone: String, CaseIterable, Identifiable {
    case soft, balanced, savage
    var id: String { rawValue }
    var label: String {
        switch self {
        case .soft: return "Soft"
        case .balanced: return "Balanced"
        case .savage: return "Savage"
        }
    }
    var subtitle: String {
        switch self {
        case .soft: return "gentle, tender, warm hug energy"
        case .balanced: return "wise, grounded, your group-chat bestie"
        case .savage: return "honest, punchy, no sugar added"
        }
    }
}

// Voice pack: every user-facing string routes through here so tone is consistent.
// Add strings here, not inline in views.
struct VoicePack {
    let tone: VoiceTone

    // MARK: - Greetings
    func greeting(name: String = "") -> String {
        let n = name.isEmpty ? "" : ", \(name)"
        switch tone {
        case .soft:     return "hi\(n). you made it today."
        case .balanced: return "hey\(n). good to see you."
        case .savage:   return "look who's back\(n)."
        }
    }

    // MARK: - Home forecast
    func lutealHeadsUp(day: Int) -> String {
        switch tone {
        case .soft:     return "day \(day). you're in your luteal phase. be extra tender with yourself today."
        case .balanced: return "day \(day), luteal phase. past 3 cycles you've felt irritable around day 24. heads up."
        case .savage:   return "day \(day). luteal. if everyone seems annoying, the call is coming from inside the uterus."
        }
    }

    func menstrualToday(day: Int) -> String {
        switch tone {
        case .soft:     return "you bled today. rest is productive."
        case .balanced: return "day \(day). menstrual. lower the expectations, raise the snacks."
        case .savage:   return "you are bleeding. cancel the meeting."
        }
    }

    func follicularToday(day: Int) -> String {
        switch tone {
        case .soft:     return "day \(day). a bright window. let yourself want things."
        case .balanced: return "day \(day), follicular. your energy's climbing — use it on what you care about."
        case .savage:   return "day \(day). follicular. yes, you are in fact, that girl."
        }
    }

    func ovulationToday(day: Int) -> String {
        switch tone {
        case .soft:     return "day \(day). you're glowing and it's chemical, but it still counts."
        case .balanced: return "day \(day), ovulation. charismatic mode — have the hard conversation now."
        case .savage:   return "day \(day). ovulating. be warned: texting the ex will seem reasonable. it's not."
        }
    }

    // MARK: - Onboarding
    var welcomeHeadline: String {
        switch tone {
        case .soft:     return "hi. it's nice to meet you."
        case .balanced: return "we haven't met yet. let's fix that."
        case .savage:   return "two minutes. honest answers. no therapist voice."
        }
    }

    var welcomeSub: String {
        switch tone {
        case .soft:     return "a soft place to land. we'll go slow."
        case .balanced: return "a few questions so luna knows who she's talking to."
        case .savage:   return "lie and the app will be useless. up to you."
        }
    }

    // MARK: - Empty states
    var emptyCheckIns: String {
        switch tone {
        case .soft:     return "nothing here yet — and that's okay."
        case .balanced: return "empty on purpose. luna learns when you show up."
        case .savage:   return "empty. suspicious. go log something."
        }
    }

    var emptyPatterns: String {
        switch tone {
        case .soft:     return "patterns bloom with time. we'll be here."
        case .balanced: return "a few cycles in, this page gets good. hang tight."
        case .savage:   return "no patterns yet because you just got here. relax."
        }
    }

    var emptyRelationships: String {
        switch tone {
        case .soft:     return "add the people who take up space in your life."
        case .balanced: return "start with the one who's on your mind right now."
        case .savage:   return "there's someone you were about to text. add them first."
        }
    }

    // MARK: - Skip-friendly
    var skipLabel: String {
        switch tone {
        case .soft: return "skip for today"
        case .balanced: return "not today"
        case .savage: return "nope, bye"
        }
    }

    // MARK: - Paywall
    var paywallHeadline: String {
        switch tone {
        case .soft:     return "see the whole picture."
        case .balanced: return "luna, fully unlocked."
        case .savage:   return "the real ones pay."
        }
    }

    var paywallSub: String {
        switch tone {
        case .soft:     return "patterns, forecasts, and the relationship lens — yours."
        case .balanced: return "forecast, patterns, and relationship lens. all in."
        case .savage:   return "forecast, patterns, relationships. the whole mirror. no fluff."
        }
    }

    // MARK: - Check-in sign-off
    var checkInDone: String {
        switch tone {
        case .soft:     return "thank you for being honest."
        case .balanced: return "logged. luna's listening."
        case .savage:   return "logged. see you tomorrow, gorgeous."
        }
    }

    // MARK: - Pattern sample lines
    func sampleWorstDay(day: Int) -> String {
        switch tone {
        case .soft:     return "you tend to feel tender on day \(day). mark it gently."
        case .balanced: return "you feel your worst on day \(day) every cycle. plan softly around it."
        case .savage:   return "day \(day) is your villain arc. put it in the calendar."
        }
    }

    func sleepDrop(hours: Double) -> String {
        let h = String(format: "%.1f", hours)
        switch tone {
        case .soft:     return "you sleep about \(h) hours less in your luteal phase. rest is a love language."
        case .balanced: return "you sleep \(h) hours less in luteal. plan around it."
        case .savage:   return "you lose \(h) hours of sleep in luteal. maybe stop scrolling, i don't know."
        }
    }

    // MARK: - Notification copy
    func nudgeBigDecision(day: Int) -> String {
        switch tone {
        case .soft:     return "day \(day). not the day for a big decision. it can wait."
        case .balanced: return "day \(day). hold the big decision until the fog clears."
        case .savage:   return "day \(day). do not send that email. i beg."
        }
    }
}

extension VoicePack {
    static func current(_ tone: VoiceTone) -> VoicePack { VoicePack(tone: tone) }

    // Personal baseline copy
    func belowBaseline(today: Int, baseline: Double) -> String {
        let avg = String(format: "%.1f", baseline)
        switch tone {
        case .soft:     return "today's mood is below your average (\(avg)). nothing wrong with you. just a heavier day."
        case .balanced: return "you logged \(today) today. your baseline is \(avg). this is a dip, not a trend."
        case .savage:   return "you're a \(today) today. usually you're a \(avg). something's up — name it."
        }
    }

    func adaptiveHeadline(_ effective: VoiceTone, original: VoiceTone) -> String? {
        guard effective != original else { return nil }
        switch tone {
        case .soft:     return "luna is being extra gentle this week."
        case .balanced: return "luna toned it down — you've had a hard stretch."
        case .savage:   return "softening, even though i told you i wouldn't. tap to override."
        }
    }
}
