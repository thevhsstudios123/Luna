import SwiftUI

enum HeartState {
    case full, neutral, drained, armored

    var color: Color {
        switch self {
        case .full:    return LunaColors.accentWarm
        case .neutral: return LunaColors.accentSoft
        case .drained: return Color(hex: 0xB89A9F)
        case .armored: return LunaColors.accentBold
        }
    }

    var label: String {
        switch self {
        case .full: return "full"
        case .neutral: return "neutral"
        case .drained: return "drained"
        case .armored: return "armored"
        }
    }
}

struct HeartAvatar: View {
    var state: HeartState
    var reactTrigger: Int = 0   // increment to trigger a brief react animation
    @State private var beat: CGFloat = 1.0
    @State private var sparkle: CGFloat = 0.0
    @State private var reacting: Bool = false

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(state.color.opacity(0.2))
                    .frame(width: d * 1.2, height: d * 1.2)
                    .blur(radius: 16)

                HeartShape()
                    .fill(state.color)
                    .frame(width: d * 0.82, height: d * 0.76)
                    .overlay(
                        Group {
                            if state == .drained {
                                CrackShape()
                                    .stroke(LunaColors.textPrimary.opacity(0.4),
                                            style: .init(lineWidth: 1.5, lineCap: .round))
                                    .frame(width: d * 0.2, height: d * 0.3)
                                    .offset(x: -d * 0.05, y: d * 0.02)
                            }
                        }
                    )

                if state == .armored {
                    ArmorShape()
                        .fill(Color(hex: 0x8A7B8F).opacity(0.9))
                        .frame(width: d * 0.78, height: d * 0.72)
                        .overlay(
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: d * 0.78, height: 2)
                                .offset(y: -d * 0.05)
                        )
                }

                face(d: d)

                if state == .full {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 3, height: 3)
                            .offset(x: [d * 0.3, -d * 0.3, d * 0.1][i],
                                    y: [-d * 0.3, -d * 0.2, -d * 0.4][i])
                            .opacity(0.4 + 0.6 * sparkle)
                    }
                }
            }
            .scaleEffect(beat)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: beat)
            .scaleEffect(reacting ? 1.15 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: reacting)
            .onAppear {
                beat = 1.04
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    sparkle = 1.0
                }
            }
            .onChange(of: reactTrigger) { _, _ in
                reacting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { reacting = false }
            }
        }
        .accessibilityLabel("heart avatar, \(state.label)")
    }

    @ViewBuilder
    private func face(d: CGFloat) -> some View {
        switch state {
        case .full:
            HStack(spacing: d * 0.14) {
                SmileShape()
                    .stroke(LunaColors.textPrimary.opacity(0.85), style: .init(lineWidth: 2, lineCap: .round))
                    .frame(width: d * 0.08, height: d * 0.04)
                SmileShape()
                    .stroke(LunaColors.textPrimary.opacity(0.85), style: .init(lineWidth: 2, lineCap: .round))
                    .frame(width: d * 0.08, height: d * 0.04)
            }
            .offset(y: -d * 0.04)
        case .neutral:
            HStack(spacing: d * 0.14) {
                Circle().fill(LunaColors.textPrimary.opacity(0.8)).frame(width: d * 0.05, height: d * 0.05)
                Circle().fill(LunaColors.textPrimary.opacity(0.8)).frame(width: d * 0.05, height: d * 0.05)
            }
            .offset(y: -d * 0.04)
        case .drained:
            HStack(spacing: d * 0.14) {
                Capsule().fill(LunaColors.textPrimary.opacity(0.6)).frame(width: d * 0.08, height: 2)
                Capsule().fill(LunaColors.textPrimary.opacity(0.6)).frame(width: d * 0.08, height: 2)
            }
            .offset(y: -d * 0.02)
        case .armored:
            // Side-eye: one eye peeking over armor edge
            Circle()
                .fill(LunaColors.textPrimary)
                .frame(width: d * 0.06, height: d * 0.06)
                .offset(x: d * 0.12, y: -d * 0.14)
        }
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addCurve(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.3),
                   control1: CGPoint(x: rect.minX, y: rect.maxY - h * 0.2),
                   control2: CGPoint(x: rect.minX, y: rect.minY + h * 0.5))
        p.addArc(center: CGPoint(x: rect.minX + w * 0.25, y: rect.minY + h * 0.25),
                 radius: w * 0.25,
                 startAngle: .degrees(180),
                 endAngle: .degrees(0),
                 clockwise: false)
        p.addArc(center: CGPoint(x: rect.maxX - w * 0.25, y: rect.minY + h * 0.25),
                 radius: w * 0.25,
                 startAngle: .degrees(180),
                 endAngle: .degrees(0),
                 clockwise: false)
        p.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                   control1: CGPoint(x: rect.maxX, y: rect.minY + h * 0.5),
                   control2: CGPoint(x: rect.maxX, y: rect.maxY - h * 0.2))
        p.closeSubpath()
        return p
    }
}

struct CrackShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX - rect.width * 0.2, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX + rect.width * 0.1, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX - rect.width * 0.1, y: rect.maxY))
        return p
    }
}

struct ArmorShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Shield-ish overlay
        p.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.15, y: rect.midY),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                       control: CGPoint(x: rect.maxX - w * 0.1, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.15, y: rect.midY),
                       control: CGPoint(x: rect.minX + w * 0.1, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1),
                       control: CGPoint(x: rect.minX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.midX, y: rect.maxY * 1.5))
        return p
    }
}
