import SwiftUI

// Radial cycle visualization. Segments represent each phase, current day is the traveling dot.
struct CycleWheel: View {
    var currentDay: Int
    var cycleLength: Int
    var onScrub: ((Int) -> Void)? = nil

    @State private var dragDay: Int? = nil

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = d / 2 - 8
            let day = dragDay ?? currentDay
            let angle = angleForDay(day)

            ZStack {
                // Phase arcs
                ForEach(CyclePhase.allCases) { phase in
                    let range = phaseRange(phase)
                    Arc(start: angleForDay(range.0), end: angleForDay(range.1))
                        .stroke(phase.color.opacity(0.7),
                                style: .init(lineWidth: 18, lineCap: .round))
                        .frame(width: d - 24, height: d - 24)
                }

                // Month tick marks
                ForEach(0..<cycleLength, id: \.self) { i in
                    let a = angleForDay(i + 1)
                    Circle()
                        .fill(LunaColors.textSecondary.opacity(0.3))
                        .frame(width: 3, height: 3)
                        .offset(x: cos(a) * (radius - 30),
                                y: sin(a) * (radius - 30))
                }

                // Center label
                VStack(spacing: 4) {
                    Text("day \(day)")
                        .font(LunaType.displayL)
                        .foregroundStyle(LunaColors.textPrimary)
                    Text(CycleEngine.phase(forDay: day, cycleLength: cycleLength).label)
                        .font(LunaType.bodyM)
                        .foregroundStyle(LunaColors.textSecondary)
                }

                // Current day dot
                Circle()
                    .fill(LunaColors.textPrimary)
                    .frame(width: 14, height: 14)
                    .offset(x: cos(angle) * (radius - 12), y: sin(angle) * (radius - 12))
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let dx = g.location.x - center.x
                        let dy = g.location.y - center.y
                        let a = atan2(dy, dx)
                        let day = dayForAngle(a)
                        if dragDay != day {
                            Haptics.selection()
                            dragDay = day
                            onScrub?(day)
                        }
                    }
                    .onEnded { _ in dragDay = nil }
            )
        }
    }

    private func angleForDay(_ day: Int) -> CGFloat {
        // Start at top (-π/2) and sweep clockwise
        let fraction = CGFloat(day - 1) / CGFloat(cycleLength)
        return -.pi / 2 + fraction * 2 * .pi
    }

    private func dayForAngle(_ a: CGFloat) -> Int {
        var normalized = (a + .pi / 2) / (2 * .pi)
        if normalized < 0 { normalized += 1 }
        let day = Int(round(normalized * CGFloat(cycleLength))) + 1
        return min(max(day, 1), cycleLength)
    }

    private func phaseRange(_ phase: CyclePhase) -> (Int, Int) {
        let len = cycleLength
        let ovStart = max(len - 14, 12)
        switch phase {
        case .menstrual:  return (1, 5)
        case .follicular: return (6, ovStart - 1)
        case .ovulation:  return (ovStart, ovStart + 2)
        case .luteal:     return (ovStart + 3, len)
        }
    }
}

struct Arc: Shape {
    var start: CGFloat
    var end: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        p.addArc(center: center,
                 radius: radius,
                 startAngle: .radians(Double(start)),
                 endAngle: .radians(Double(end)),
                 clockwise: false)
        return p
    }
}
