import SwiftUI

/// How long each half ran after the clock reached zero ("H1 +1:12 · H2 +2:40").
/// Hidden when no half recorded it (matches from older versions).
struct WatchTimePastClockWidget: View {
    let firstHalf: Int?
    var secondHalf: Int? = nil

    var body: some View {
        if firstHalf != nil || secondHalf != nil {
            VStack(alignment: .leading, spacing: 4) {
                Text("PAST THE CLOCK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(Color.outline)
                HStack(spacing: 10) {
                    if let firstHalf { half("H1", firstHalf) }
                    if let secondHalf { half("H2", secondHalf) }
                    Spacer(minLength: 0)
                }
            }
            .padding(8)
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
        }
    }

    private func half(_ label: LocalizedStringKey, _ seconds: Int) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outline)
            Text(verbatim: "+" + WatchBreakCountdownWidget.clock(seconds))
                .font(.system(size: 13, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Text(label)): \(seconds / 60) minutes \(seconds % 60) seconds past the clock"))
    }
}

#Preview("Past the clock") {
    WatchTimePastClockWidget(firstHalf: 72, secondHalf: 160)
        .padding()
}
