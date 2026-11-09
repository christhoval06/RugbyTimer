import SwiftUI

struct SetupDurationTileWidget: View {
    let value: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let selected: Bool
    var isCustom = false

    private var foreground: Color { selected ? Color.pitchVoid : Color.iceTitanium }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: isCustom ? 24 : 30, weight: .black).width(.condensed))
                if !isCustom {
                    Text("MIN")
                        .font(.system(size: 11, weight: .bold))
                }
                Spacer(minLength: 0)
                Image(systemName: selected ? "checkmark.circle.fill" : (isCustom ? "slider.horizontal.3" : "circle"))
                    .font(.system(size: 13, weight: .medium))
                    .opacity(selected || isCustom ? 1 : 0.2)
            }
            .foregroundStyle(foreground)
            Text(subtitle)
                .font(.system(size: 8, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(selected ? Color.pitchVoid.opacity(0.7) : Color.outline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .background(selected ? Color.pitchEmerald : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color.pitchEmerald : Color.armorBorder))
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
