import SwiftUI

struct SetupSettingLabelWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let tint: Color

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 30, height: 34)
                .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.iceTitanium)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.outline)
            }
        }
    }
}
