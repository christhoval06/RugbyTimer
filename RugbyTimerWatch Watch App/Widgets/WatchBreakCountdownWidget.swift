import SwiftUI

/// Half-time interval countdown from the half-time whistle. Once it runs out it counts
/// the time over in amber, so the referee knows the restart is late.
struct WatchBreakCountdownWidget: View {
    let endsAt: Date
    let totalSeconds: Int

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = Int(endsAt.timeIntervalSince(context.date).rounded(.up))
            content(remaining: remaining)
        }
    }

    private func content(remaining: Int) -> some View {
        let isOver = remaining <= 0
        let progress = totalSeconds > 0 ? Double(max(0, remaining)) / Double(totalSeconds) : 0
        return VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text(isOver ? "BREAK OVER" : "BREAK LEFT")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(isOver ? Color.sinBinAmber : Color.outline)
                Spacer(minLength: 4)
                Text(verbatim: (isOver ? "+" : "") + Self.clock(abs(remaining)))
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundStyle(isOver ? Color.sinBinAmber : Color.iceTitanium)
                    .contentTransition(.numericText(countsDown: true))
            }
            GeometryReader { proxy in
                Capsule().fill(Color.surfaceContainerHighest)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(remaining <= 60 ? Color.sinBinAmber : Color.pitchEmerald)
                            .frame(width: proxy.size.width * progress)
                    }
            }
            .frame(height: 4)
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isOver
            ? Text("Break over by \(Self.clock(-remaining))")
            : Text("Break, \(Self.clock(remaining)) left"))
    }

    static func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview("Break countdown") {
    VStack {
        WatchBreakCountdownWidget(endsAt: .now.addingTimeInterval(412), totalSeconds: 600)
        WatchBreakCountdownWidget(endsAt: .now.addingTimeInterval(-23), totalSeconds: 600)
    }
    .padding()
}
