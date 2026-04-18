import SwiftUI

// 1-10 slider with a morphing emoji face expressing value.
struct MoodSlider: View {
    var title: String
    @Binding var value: Int
    var labels: (low: String, high: String) = ("low", "high")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(LunaType.displayS)
                    .foregroundStyle(LunaColors.textPrimary)
                Spacer()
                MorphFace(value: value)
                    .frame(width: 36, height: 36)
            }

            GeometryReader { geo in
                let w = geo.size.width
                let clamped = max(1, min(10, value))
                let knobX = w * CGFloat(clamped - 1) / 9.0

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LunaColors.bgSecondary)
                        .frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(colors: [LunaColors.accentSoft, LunaColors.accentBold],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(knobX, 14), height: 10)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .overlay(Circle().stroke(LunaColors.textPrimary.opacity(0.1), lineWidth: 1))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        .offset(x: knobX - 13)
                        .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                            let raw = g.location.x / w
                            let v = Int(round(raw * 9.0)) + 1
                            let newV = max(1, min(10, v))
                            if newV != value {
                                Haptics.selection()
                                value = newV
                            }
                        })
                }
            }
            .frame(height: 30)

            HStack {
                Text(labels.low).font(LunaType.metaM).foregroundStyle(LunaColors.textSecondary)
                Spacer()
                Text("\(value)").font(LunaType.metaM).foregroundStyle(LunaColors.textPrimary)
                Spacer()
                Text(labels.high).font(LunaType.metaM).foregroundStyle(LunaColors.textSecondary)
            }
        }
    }
}

struct MorphFace: View {
    var value: Int
    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                Circle().fill(color)
                HStack(spacing: d * 0.18) {
                    Circle().fill(LunaColors.textPrimary).frame(width: d * 0.1, height: d * 0.1)
                    Circle().fill(LunaColors.textPrimary).frame(width: d * 0.1, height: d * 0.1)
                }
                .offset(y: -d * 0.08)
                MouthShape(value: value)
                    .stroke(LunaColors.textPrimary, style: .init(lineWidth: 2, lineCap: .round))
                    .frame(width: d * 0.35, height: d * 0.1)
                    .offset(y: d * 0.12)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
        }
    }

    private var color: Color {
        switch value {
        case ...3: return Color(hex: 0xC6B2C8)
        case 4...5: return LunaColors.accentSoft
        case 6...7: return Color(hex: 0xF0C987)
        default: return LunaColors.success
        }
    }
}

// Mouth curve interpolates from frown to smile based on value 1-10.
struct MouthShape: Shape {
    var value: Int
    var animatableData: CGFloat {
        get { CGFloat(value) }
        set { value = Int(newValue) }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let v = CGFloat(max(1, min(10, value)))
        // -1 for frown, +1 for smile
        let t = (v - 5.5) / 4.5
        let curveHeight = rect.height * 0.8 * t
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.midX, y: rect.midY + curveHeight))
        return p
    }
}
