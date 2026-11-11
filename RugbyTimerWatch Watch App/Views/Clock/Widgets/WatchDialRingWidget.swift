import SwiftUI

/// The Watch dial's tick marks and remaining-time arc, lit up to `fraction` in the zone tint.
struct WatchDialRingWidget: View {
    let size: CGFloat
    let fraction: Double
    let tint: Color
    let isTimeUp: Bool
    let isRunning: Bool

    private static let tickCount = 60

    var body: some View {
        let ringWidth = size * 0.055
        let ringInset = size * 0.11

        ZStack {
            ForEach(0..<Self.tickCount, id: \.self) { index in
                let isMajor = index % 5 == 0
                let isLit = Double(index) / Double(Self.tickCount) < fraction
                Capsule()
                    .fill(isLit ? tint.opacity(isMajor ? 0.9 : 0.4) : Color.armorBorder)
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? size * 0.05 : size * 0.025)
                    .offset(y: -size / 2 + size * 0.03)
                    .rotationEffect(.degrees(Double(index) / Double(Self.tickCount) * 360))
            }

            Circle()
                .stroke(Color.armorBorder, lineWidth: ringWidth)
                .padding(ringInset)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    isTimeUp
                        ? AnyShapeStyle(tint)
                        : AnyShapeStyle(AngularGradient(colors: [tint.opacity(0.35), tint], center: .center,
                                                        startAngle: .degrees(0),
                                                        endAngle: .degrees(360 * max(fraction, 0.01)))),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(ringInset)
                .shadow(color: tint.opacity(isRunning ? 0.45 : 0), radius: 5)
                .animation(.linear(duration: 1), value: fraction)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    WatchDialRingWidget(size: 140, fraction: 0.7, tint: Color.pitchEmerald, isTimeUp: false, isRunning: true)
        .background(Color.pitchVoid)
}
