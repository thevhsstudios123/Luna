import SwiftUI

// Subtle noise texture drawn programmatically. No image assets needed.
struct GrainOverlay: View {
    var intensity: Double = 0.03
    var body: some View {
        Canvas { ctx, size in
            let count = Int((size.width * size.height) / 180)
            var rng = SystemRandomNumberGenerator()
            for _ in 0..<count {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let a = Double.random(in: 0.01...intensity, using: &rng)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                ctx.fill(Path(rect), with: .color(.black.opacity(a)))
            }
        }
        .allowsHitTesting(false)
        .blendMode(.multiply)
    }
}

// Soft radial vignette used behind hero content.
struct SoftGlow: View {
    var color: Color
    var body: some View {
        RadialGradient(
            colors: [color.opacity(0.5), color.opacity(0.0)],
            center: .center,
            startRadius: 0,
            endRadius: 240
        )
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }
}
