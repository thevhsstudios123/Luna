import SwiftUI

// The Moon. Shape and expression morph with cycle phase.
struct MoonAvatar: View {
    var phase: CyclePhase
    @State private var breathe: CGFloat = 1.0
    @State private var shimmer: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                // Soft halo
                Circle()
                    .fill(phase.color.opacity(0.18))
                    .frame(width: d * 1.25, height: d * 1.25)
                    .blur(radius: 18)

                // Base moon body — elliptical for a more organic shape
                moonShape
                    .fill(phase.color.opacity(0.95))
                    .frame(width: d * 0.82, height: d * 0.88)
                    .overlay(Group { if phase == .ovulation { shimmerOverlay(d: d) } })

                // Subtle highlight
                Ellipse()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: d * 0.28, height: d * 0.18)
                    .offset(x: -d * 0.15, y: -d * 0.22)

                // Accessories per phase
                accessories(d: d)

                // Face
                face(d: d)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .scaleEffect(breathe)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: breathe)
            .onAppear {
                breathe = 1.04
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    shimmer = 1.0
                }
            }
        }
        .accessibilityLabel("moon avatar, \(phase.label) phase")
    }

    private var moonShape: some Shape {
        // Slight asymmetric for luteal (waning) vs follicular (waxing)
        switch phase {
        case .menstrual, .ovulation: return AnyShape(Circle())
        case .follicular: return AnyShape(WaxingShape())
        case .luteal: return AnyShape(WaningShape())
        }
    }

    @ViewBuilder
    private func accessories(d: CGFloat) -> some View {
        switch phase {
        case .menstrual:
            // Tiny blanket wrapping lower half
            BlanketShape()
                .fill(LunaColors.bgSecondary)
                .frame(width: d * 0.78, height: d * 0.42)
                .offset(y: d * 0.22)
                .overlay(
                    BlanketShape()
                        .stroke(LunaColors.textPrimary.opacity(0.18), lineWidth: 1)
                        .frame(width: d * 0.78, height: d * 0.42)
                        .offset(y: d * 0.22)
                )
        case .follicular:
            EmptyView() // bouncy, no accessories
        case .ovulation:
            // Sparkles
            ForEach(0..<6) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .offset(x: cos(Double(i) * .pi / 3) * Double(d) * 0.48,
                            y: sin(Double(i) * .pi / 3) * Double(d) * 0.48)
                    .opacity(0.5 + 0.5 * shimmer)
            }
        case .luteal:
            // Sunglasses + hoodie hood
            HoodShape()
                .fill(LunaColors.accentBold.opacity(0.85))
                .frame(width: d * 0.95, height: d * 0.55)
                .offset(y: -d * 0.28)
            Capsule()
                .fill(LunaColors.textPrimary.opacity(0.88))
                .frame(width: d * 0.55, height: d * 0.12)
                .offset(y: -d * 0.02)
            // Shades lenses highlight
            HStack(spacing: d * 0.06) {
                Circle().fill(Color.white.opacity(0.2)).frame(width: d * 0.05, height: d * 0.05)
                Circle().fill(Color.white.opacity(0.2)).frame(width: d * 0.05, height: d * 0.05)
            }
            .offset(y: -d * 0.03)
        }
    }

    @ViewBuilder
    private func face(d: CGFloat) -> some View {
        switch phase {
        case .menstrual:
            // Sleepy half-closed eyes
            HStack(spacing: d * 0.16) {
                Capsule().fill(LunaColors.textPrimary.opacity(0.85)).frame(width: d * 0.1, height: 2)
                Capsule().fill(LunaColors.textPrimary.opacity(0.85)).frame(width: d * 0.1, height: 2)
            }
            .offset(y: -d * 0.04)
        case .follicular:
            // Bright eyes + smirk
            HStack(spacing: d * 0.14) {
                Circle().fill(LunaColors.textPrimary.opacity(0.9)).frame(width: d * 0.06, height: d * 0.06)
                Circle().fill(LunaColors.textPrimary.opacity(0.9)).frame(width: d * 0.06, height: d * 0.06)
            }
            .offset(y: -d * 0.04)
            SmirkShape()
                .stroke(LunaColors.textPrimary.opacity(0.8), style: .init(lineWidth: 2, lineCap: .round))
                .frame(width: d * 0.22, height: d * 0.08)
                .offset(y: d * 0.12)
        case .ovulation:
            // Knowing look — arched
            HStack(spacing: d * 0.16) {
                Capsule().fill(LunaColors.textPrimary.opacity(0.9)).frame(width: d * 0.08, height: d * 0.04)
                Capsule().fill(LunaColors.textPrimary.opacity(0.9)).frame(width: d * 0.08, height: d * 0.04)
            }
            .offset(y: -d * 0.04)
            SmirkShape()
                .stroke(LunaColors.textPrimary.opacity(0.85), style: .init(lineWidth: 2, lineCap: .round))
                .frame(width: d * 0.24, height: d * 0.1)
                .offset(y: d * 0.12)
        case .luteal:
            // Hidden behind shades; just a small flat mouth
            Capsule()
                .fill(LunaColors.textPrimary.opacity(0.7))
                .frame(width: d * 0.16, height: 2)
                .offset(y: d * 0.14)
        }
    }

    @ViewBuilder
    private func shimmerOverlay(d: CGFloat) -> some View {
        LinearGradient(
            colors: [Color.white.opacity(0.0), Color.white.opacity(0.35), Color.white.opacity(0.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        .frame(width: d * 0.82, height: d * 0.88)
        .mask(Circle().frame(width: d * 0.82, height: d * 0.88))
        .opacity(0.6 + 0.4 * shimmer)
    }
}

// Non-circular moon shapes that feel organic, not geometric.
struct WaxingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: rect)
        let cut = CGRect(x: rect.minX - rect.width * 0.2, y: rect.minY, width: rect.width * 0.45, height: rect.height)
        var cutPath = Path()
        cutPath.addEllipse(in: cut)
        return p.subtracting(cutPath)
    }
}

struct WaningShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: rect)
        let cut = CGRect(x: rect.midX + rect.width * 0.05, y: rect.minY, width: rect.width * 0.45, height: rect.height)
        var cutPath = Path()
        cutPath.addEllipse(in: cut)
        return p.subtracting(cutPath)
    }
}

struct BlanketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                   control1: CGPoint(x: rect.width * 0.3, y: rect.minY),
                   control2: CGPoint(x: rect.width * 0.7, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct HoodShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.3))
        p.closeSubpath()
        return p
    }
}

struct SmirkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY - rect.height * 0.4),
                       control: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

// Type-erased Shape for switching between Shape types in the view body.
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ shape: S) { _path = { shape.path(in: $0) } }
    func path(in rect: CGRect) -> Path { _path(rect) }
}
