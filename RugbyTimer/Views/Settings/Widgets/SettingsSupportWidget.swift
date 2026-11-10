import SwiftUI
import StoreKit

struct SettingsSupportWidget: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        SettingsGroupWidget(number: "05", title: "CONTACT & SUPPORT", detail: "WE READ EVERYTHING") {
            mailRow(symbol: "envelope", title: "Contact the developer",
                    subtitle: "\(AppInfo.supportEmail)", subject: "Hello") // l10n-ignore
            SettingsDividerWidget()
            mailRow(symbol: "ladybug", title: "Report a problem",
                    subtitle: "Includes your app version", subject: "Bug report", tint: .expulsionRed) // l10n-ignore
            SettingsDividerWidget()
            mailRow(symbol: "lightbulb", title: "Suggest a feature",
                    subtitle: "Tell us what referees need", subject: "Feature idea", tint: .cardYellow) // l10n-ignore
            SettingsDividerWidget()
            Button {
                requestReview()
            } label: {
                SettingsLinkRowWidget(symbol: "star", title: "Rate Rugby Timer",
                                      subtitle: "It helps other referees find it", tint: .sinBinAmber,
                                      trailingSymbol: "arrow.up.right")
            }
        }
    }

    private func mailRow(symbol: String, title: LocalizedStringKey, subtitle: LocalizedStringKey, subject: String,
                         tint: Color = .pitchEmerald) -> some View {
        Button {
            if let url = AppInfo.mailURL(subject: subject) { openURL(url) }
        } label: {
            SettingsLinkRowWidget(symbol: symbol, title: title, subtitle: subtitle,
                                  tint: tint, trailingSymbol: "arrow.up.right")
        }
    }
}
