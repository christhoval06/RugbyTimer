import SwiftUI

/// Section heading plus a bordered card of rows, matching the Match Setup sections.
struct SettingsGroupWidget<Content: View>: View {
    let number: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: number, title: title, detail: detail)
            VStack(spacing: 0) { content }
                .buttonStyle(.plain)
                .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
