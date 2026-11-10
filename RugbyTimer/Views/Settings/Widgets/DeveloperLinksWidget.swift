import SwiftUI

struct DeveloperLinksWidget: View {
    var body: some View {
        SettingsGroupWidget(number: "02", title: "FIND ME", detail: "ELSEWHERE") {
            link(AppInfo.websiteURL, symbol: "globe", title: "Website",
                 subtitle: "\(AppInfo.websiteURL.host() ?? "")")
            SettingsDividerWidget()
            link(AppInfo.githubURL, symbol: "chevron.left.forwardslash.chevron.right", title: "GitHub",
                 subtitle: "\(AppInfo.developerHandle)", tint: .iceTitanium)
            SettingsDividerWidget()
            if let mail = AppInfo.mailURL(subject: "Hello") { // l10n-ignore: subject stays English
                link(mail, symbol: "envelope", title: "Email", subtitle: "\(AppInfo.supportEmail)", tint: .sinBinAmber)
            }
        }
    }

    private func link(_ url: URL, symbol: String, title: LocalizedStringKey, subtitle: LocalizedStringKey,
                      tint: Color = .pitchEmerald) -> some View {
        Link(destination: url) {
            SettingsLinkRowWidget(symbol: symbol, title: title, subtitle: subtitle,
                                  tint: tint, trailingSymbol: "arrow.up.right")
        }
    }
}
