import SwiftUI

/// One sanction in the full-time log: minute, card colour, shirt number and team.
struct WatchDisciplineLogRowWidget: View {
    let event: MatchEvent
    let tint: Color

    private var isRed: Bool { event.type == .redCard }

    private var offender: String {
        guard let number = event.playerNumber else { return event.teamName }
        return String(localized: "number \(number), \(event.teamName)")
    }

    private var accessibilityText: Text {
        isRed ? Text("Minute \(event.minute), red card, \(offender)")
              : Text("Minute \(event.minute), yellow card, \(offender)")
    }

    var body: some View {
        HStack(spacing: 5) {
            Text("\(event.minute)'")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outline)
                .frame(width: 24, alignment: .leading)
            RoundedRectangle(cornerRadius: 1.5)
                .fill(isRed ? Color.expulsionRed : Color.cardYellow)
                .frame(width: 6, height: 9)
            Text(event.playerNumber.map { "#\($0)" } ?? "—")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
            Text(event.teamName)
                .font(.system(size: 10, weight: .semibold).width(.condensed))
                .foregroundStyle(tint)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}
