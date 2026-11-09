import SwiftUI

/// iPhone match clock: a tick dial with the remaining-time arc and a large readout.
/// Colours follow `TimerRingView.zone` so the phone and the Watch always agree.
struct LiveTimerRingWidget: View {
    let timeRemaining: Int
    let totalDuration: Int
    let isRunning: Bool
    let overtimeSeconds: Int
    let periodLabel: LocalizedStringResource

    private static let tickCount = 60

    private var zone: TimerRingView.Zone {
        TimerRingView.zone(timeRemaining: timeRemaining, totalDuration: totalDuration, overtimeSeconds: overtimeSeconds)
    }
    private var isOvertime: Bool { overtimeSeconds > 0 }
    private var remainingFraction: Double {
        if zone == .timeUp { return 1 }
        guard totalDuration > 0 else { return 0 }
        return min(1, max(0, Double(timeRemaining) / Double(totalDuration)))
    }
    private var tint: Color {
        switch zone {
        case .normal: Color.pitchEmerald
        case .closing: Color.cardYellow
        case .timeUp: Color.expulsionRed
        }
    }
    private var status: LocalizedStringResource {
        if zone == .timeUp { return isOvertime ? "OVERTIME" : "TIME UP" }
        return isRunning ? "RUNNING" : "PAUSED"
    }
    private var readout: String {
        let seconds = isOvertime ? overtimeSeconds : timeRemaining
        return (isOvertime ? "+" : "") + String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        ZStack {
            ForEach(0..<Self.tickCount, id: \.self) { index in
                let isMajor = index % 5 == 0
                let isLit = Double(index) / Double(Self.tickCount) < remainingFraction
                Capsule()
                    .fill(isLit ? tint.opacity(isMajor ? 0.9 : 0.4) : Color.armorBorder)
                    .frame(width: isMajor ? 3 : 1.5, height: isMajor ? 12 : 6)
                    .offset(y: -122)
                    .rotationEffect(.degrees(Double(index) / Double(Self.tickCount) * 360))
            }

            Circle()
                .stroke(Color.armorBorder, lineWidth: 12)
                .padding(26)

            Circle()
                .trim(from: 0, to: remainingFraction)
                .stroke(
                    zone == .timeUp
                        ? AnyShapeStyle(tint)
                        : AnyShapeStyle(AngularGradient(colors: [tint.opacity(0.35), tint], center: .center,
                                                        startAngle: .degrees(0),
                                                        endAngle: .degrees(360 * max(remainingFraction, 0.01)))),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(26)
                .shadow(color: tint.opacity(isRunning ? 0.45 : 0), radius: 8)
                .animation(.linear(duration: 1), value: remainingFraction)

            VStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle().fill(isRunning ? tint : Color.sinBinAmber).frame(width: 6, height: 6)
                    Text(status)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundStyle(isRunning || zone == .timeUp ? tint : Color.sinBinAmber)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background((isRunning || zone == .timeUp ? tint : Color.sinBinAmber).opacity(0.12), in: Capsule())

                Text(readout)
                    .font(.system(size: 60, weight: .black).width(.condensed))
                    .monospacedDigit()
                    .foregroundStyle(zone == .timeUp ? Color.expulsionRed : Color.iceTitanium)
                    .contentTransition(.numericText(countsDown: !isOvertime))
                    .animation(.default, value: readout)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(periodLabel)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(Color.outline)
            }
            .padding(.horizontal, 48)
        }
        .frame(width: 260, height: 260)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Text(periodLabel)), \(String(localized: status).lowercased()), \(readout)")
    }
}
