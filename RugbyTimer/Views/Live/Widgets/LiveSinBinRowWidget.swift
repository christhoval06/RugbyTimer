import SwiftUI

struct LiveSinBinRowWidget: View {
    let card: MatchCard

    private var tint: Color { card.type == .yellow ? Color.cardYellow : Color.expulsionRed }

    private var subtitle: LocalizedStringKey {
        if card.type == .red && card.countsDown {
            return card.isExpired ? "20-minute red · Replacement can come on" : "20-minute red · Replacement in"
        }
        if card.type == .red { return "Red card · Sent off" }
        return card.isExpired ? "Sin-bin over · Ready to return" : "Yellow card · Sin-bin"
    }

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: "rectangle.portrait.fill", title: "#\(card.playerNumber) · \(card.teamName)",
                                    subtitle: subtitle, tint: tint)
            Spacer(minLength: 4)
            if card.countsDown && !card.isExpired {
                let timerTint = card.type == .red ? Color.expulsionRed : Color.sinBinAmber
                Text(formatTime(card.remainingSeconds))
                    .font(.system(size: 17, weight: .heavy, design: .monospaced))
                    .foregroundStyle(timerTint)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 36)
                    .background(timerTint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            } else if card.countsDown {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.pitchEmerald)
            }
        }
        .padding(14)
        .accessibilityElement(children: .combine)
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
