import SwiftUI

/// Watch match clock in the iPhone style: a tick dial with the remaining-time arc,
/// a status pill, a large condensed readout and the period label, scaled to the Watch.
/// Colours follow `TimerRingView.zone` so the phone and the Watch always agree.
struct WatchTimerDialWidget: View {
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
        TimerRingView.progress(timeRemaining: timeRemaining, totalDuration: totalDuration, overtimeSeconds: overtimeSeconds)
    }
    private var tint: Color {
        switch zone {
        case .normal: .pitchEmerald
        case .closing: .cardYellow
        case .timeUp: .expulsionRed
        }
    }
    private var statusTint: Color { isRunning || zone == .timeUp ? tint : .sinBinAmber }
    private var status: LocalizedStringResource {
        if zone == .timeUp { return isOvertime ? "OVERTIME" : "TIME UP" }
        return isRunning ? "RUNNING" : "PAUSED"
    }
    private var readout: String {
        let seconds = isOvertime ? overtimeSeconds : timeRemaining
        return (isOvertime ? "+" : "") + String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let ringWidth = size * 0.055
            let ringInset = size * 0.11

            ZStack {
                ForEach(0..<Self.tickCount, id: \.self) { index in
                    let isMajor = index % 5 == 0
                    let isLit = Double(index) / Double(Self.tickCount) < remainingFraction
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
                    .trim(from: 0, to: remainingFraction)
                    .stroke(
                        zone == .timeUp
                            ? AnyShapeStyle(tint)
                            : AnyShapeStyle(AngularGradient(colors: [tint.opacity(0.35), tint], center: .center,
                                                            startAngle: .degrees(0),
                                                            endAngle: .degrees(360 * max(remainingFraction, 0.01)))),
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(ringInset)
                    .shadow(color: tint.opacity(isRunning ? 0.45 : 0), radius: 5)
                    .animation(.linear(duration: 1), value: remainingFraction)

                VStack(spacing: size * 0.02) {
                    HStack(spacing: 3) {
                        Circle().fill(statusTint).frame(width: 4, height: 4)
                        Text(status)
                            .font(.system(size: 7, weight: .bold))
                            .tracking(0.8)
                    }
                    .foregroundStyle(statusTint)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusTint.opacity(0.14), in: Capsule())

                    Text(readout)
                        .font(.system(size: size * 0.26, weight: .black).width(.condensed))
                        .monospacedDigit()
                        .foregroundStyle(zone == .timeUp ? Color.expulsionRed : Color.iceTitanium)
                        .contentTransition(.numericText(countsDown: !isOvertime))
                        .animation(.default, value: readout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(periodLabel)
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .tracking(0.6)
                        .foregroundStyle(Color.outline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, ringInset + ringWidth + 2)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Text(periodLabel)), \(String(appLocalized: status).lowercased()), \(readout)")
    }
}

#Preview("Running") {
    WatchTimerDialWidget(timeRemaining: 1834, totalDuration: 2400, isRunning: true,
                         overtimeSeconds: 0, periodLabel: "FIRST HALF · H1")
        .frame(width: 140)
        .background(Color.pitchVoid)
}

#Preview("Closing, paused") {
    WatchTimerDialWidget(timeRemaining: 204, totalDuration: 2400, isRunning: false,
                         overtimeSeconds: 0, periodLabel: "SECOND HALF · H2")
        .frame(width: 140)
        .background(Color.pitchVoid)
}

#Preview("Overtime") {
    WatchTimerDialWidget(timeRemaining: 0, totalDuration: 2400, isRunning: true,
                         overtimeSeconds: 37, periodLabel: "SECOND HALF · H2")
        .frame(width: 140)
        .background(Color.pitchVoid)
}
