import SwiftUI

/// Tappable row label with a trailing glyph (chevron for navigation, arrow for external links).
struct SettingsLinkRowWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var tint: Color = .pitchEmerald
    var trailingSymbol = "chevron.right"

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: symbol, title: title, subtitle: subtitle, tint: tint)
            Spacer(minLength: 4)
            Image(systemName: trailingSymbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.outline)
        }
        .padding(14)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}
