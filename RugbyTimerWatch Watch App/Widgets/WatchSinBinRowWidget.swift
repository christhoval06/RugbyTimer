import SwiftUI

struct WatchSinBinRowWidget: View {
    let card: MatchCard

    private var cardTint: Color { card.type == .yellow ? .cardYellow : .expulsionRed }

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(cardTint)
                .frame(width: 8, height: 12)
            Text("#\(card.playerNumber)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
            Text(card.teamName)
                .font(.system(size: 10, weight: .semibold).width(.condensed))
                .foregroundStyle(Color.outline)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(statusText)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(card.isExpired && card.countsDown ? Color.pitchEmerald : cardTint)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: Text {
        if card.type == .yellow { return Text("Yellow card, number \(card.playerNumber), \(card.teamName), \(statusText)") }
        if card.countsDown { return Text("20-minute red card, number \(card.playerNumber), \(card.teamName), \(statusText)") }
        return Text("Red card, number \(card.playerNumber), \(card.teamName), \(statusText)")
    }

    private var statusText: String {
        if card.type == .red && !card.countsDown { return String(appLocalized: "OFF") }
        // 20-minute red: a replacement can come on once it runs out.
        if card.isExpired { return card.type == .red ? String(appLocalized: "SUB ON") : String(appLocalized: "READY") }
        return String(format: "%02d:%02d", card.remainingSeconds / 60, card.remainingSeconds % 60)
    }
}
