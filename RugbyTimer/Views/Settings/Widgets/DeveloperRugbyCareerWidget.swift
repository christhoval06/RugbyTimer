import SwiftUI

struct DeveloperRugbyCareerWidget: View {
    private let tints: [Color] = [.pitchEmerald, .sinBinAmber, .cardYellow]

    var body: some View {
        SettingsGroupWidget(number: "01", title: "ON THE PITCH", detail: "RUGBY CAREER") {
            ForEach(Array(AppInfo.rugbyCareer.enumerated()), id: \.offset) { index, item in
                if index > 0 { SettingsDividerWidget() }
                HStack {
                    SetupSettingLabelWidget(symbol: item.symbol, title: "\(String(appLocalized: item.title))",
                                            subtitle: "\(String(appLocalized: item.detail))", tint: tints[index % tints.count])
                    Spacer(minLength: 0)
                }
                .padding(14)
                .accessibilityElement(children: .combine)
            }
        }
    }
}
