import SwiftUI

enum BrainState {
    case sharp, okay, foggy, melted
    static func from(hours: Double) -> BrainState {
        switch hours {
        case ..<3: return .sharp
        case 3..<5: return .okay
        case 5..<7: return .foggy
        default: return .melted
        }
    }

    var bodyColor: Color {
        switch self {
        case .sharp:  return LunaColors.accentSoft
        case .okay:   return LunaColors.accentSoft.opacity(0.85)
        case .foggy:  return Color(hex: 0xB8AAB5)
        case .melted: return Color(hex: 0x7A6F78)
        }
    }

    var label: String {
        switch self {
        case .sharp: return "sharp"
        case .okay: return "okay"
        case .foggy: return "foggy"
        case .melted: return "melted"
        }
    }
}

struct BrainAvatar: View {
    var state: BrainState
    @State private var pulse: CGFloat = 1.0
    @State private var spark: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                // Halo
                Circle()
                    .fill(state.bodyColor.opacity(0.2))
                    .frame(width: d * 1.2, height: d * 1.2)
                    .blur(radius: 14)

                BrainShape()
                    .fill(state.bodyColor)
                    .frame(width: d * 0.85, height: d * 0.78)
                    .offset(y: state == .melted ? d * 0.12 : 0)
                    .scaleEffect(y: state == .melted ? 0.7 : 1.0)

                // Face
                face(d: d)

                // State details
                overlay(d: d)
            }
            .scaleEffect(pulse)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
            .onAppear {
                pulse = 1.03
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    spark = 1.0
                }
            }
        }
        .accessibilityLabel("brain avatar, \(state.label)")
    }

    @ViewBuilder
    private func face(d: CGFloat) -> some View {
        switch state {
        case .sharp:
            HStack(spacing: d * 0.12) {
                Circle().fill(LunaColors.textPrimary).frame(width: d * 0.06, height: d * 0.06)
                Circle().fill(LunaColors.textPrimary).frame(width: d * 0.06, height: d * 0.06)
            }
            .offset(y: -d * 0.02)
        case .okay:
            HStack(spacing: d * 0.14) {
                Capsule().fill(LunaColors.textPrimary.opacity(0.8)).frame(width: d * 0.08, height: 2)
                Capsule().fill(LunaColors.textPrimary.opacity(0.8)).frame(width: d * 0.08, height: 2)
            }
            .offset(y: -d * 0.02)
        case .foggy:
            HStack(spacing: d * 0.14) {
                Capsule().fill(LunaColors.textPrimary.opacity(0.7)).frame(width: d * 0.08, height: 2).rotationEffect(.degrees(10))
                Capsule().fill(LunaColors.textPrimary.opacity(0.7)).frame(width: d * 0.08, height: 2).rotationEffect(.degrees(-10))
            }
            .offset(y: d * 0.02)
        case .melted:
            // Face down — two small lines only
            HStack(spacing: d * 0.14) {
                Capsule().fill(LunaColors.textPrimary.opacity(0.5)).frame(width: d * 0.08, height: 2)
                Capsule().fill(LunaColors.textPrimary.opacity(0.5)).frame(width: d * 0.08, height: 2)
            }
            .offset(y: d * 0.1)
            // Tiny phone
            RoundedRectangle(cornerRadius: 3)
                .fill(LunaColors.textPrimary)
                .frame(width: d * 0.18, height: d * 0.28)
                .offset(x: d * 0.22, y: d * 0.25)
        }
    }

    @ViewBuilder
    private func overlay(d: CGFloat) -> some View {
        switch state {
        case .sharp:
            // Lightning bolts
            LightningShape()
                .stroke(LunaColors.accentBold, style: .init(lineWidth: 2, lineCap: .round))
                .frame(width: d * 0.14, height: d * 0.22)
                .offset(x: d * 0.3, y: -d * 0.3)
                .opacity(0.3 + 0.7 * spark)
            LightningShape()
                .stroke(LunaColors.accentBold, style: .init(lineWidth: 2, lineCap: .round))
                .frame(width: d * 0.1, height: d * 0.16)
                .offset(x: -d * 0.3, y: -d * 0.26)
                .opacity(0.3 + 0.7 * spark)
        case .foggy:
            FogCloud()
                .fill(Color.white.opacity(0.5))
                .frame(width: d * 0.5, height: d * 0.2)
                .offset(y: -d * 0.4)
        case .melted:
            // Drip drop
            Capsule()
                .fill(state.bodyColor)
                .frame(width: d * 0.1, height: d * 0.3)
                .offset(x: -d * 0.2, y: d * 0.3)
        default: EmptyView()
        }
    }
}

// An organic brain-ish shape with soft lobes — not clinical.
struct BrainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: rect.minX + w * 0.1, y: rect.midY + h * 0.1))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                       control: CGPoint(x: rect.minX - w * 0.1, y: rect.minY - h * 0.1))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.1, y: rect.midY + h * 0.1),
                       control: CGPoint(x: rect.maxX + w * 0.1, y: rect.minY - h * 0.1))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                       control: CGPoint(x: rect.maxX + w * 0.05, y: rect.maxY + h * 0.1))
        p.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.1, y: rect.midY + h * 0.1),
                       control: CGPoint(x: rect.minX - w * 0.05, y: rect.maxY + h * 0.1))
        p.closeSubpath()
        return p
    }
}

struct LightningShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX - rect.width * 0.1, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.3, y: rect.maxY))
        return p
    }
}

struct FogCloud: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.addEllipse(in: CGRect(x: 0, y: h * 0.3, width: w * 0.4, height: h * 0.7))
        p.addEllipse(in: CGRect(x: w * 0.3, y: 0, width: w * 0.4, height: h))
        p.addEllipse(in: CGRect(x: w * 0.6, y: h * 0.3, width: w * 0.4, height: h * 0.7))
        return p
    }
}
