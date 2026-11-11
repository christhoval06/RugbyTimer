import SwiftUI

struct SettingsOfficiatingWidget: View {
    @ObservedObject var settings: AppSettings

    private var playerRangeOptions: [(value: Int, label: String)] {
        AppSettings.playerRangeOptions.map { ($0.max, "1–\($0.max) · \(String(appLocalized: $0.label))") }
    }

    var body: some View {
        SettingsGroupWidget(number: "02", title: "OFFICIATING", detail: "ON THE PITCH") {
            SettingsMenuRowWidget(
                symbol: "number", title: "Shirt numbers", subtitle: "Range offered for scorers and cards",
                tint: .cardYellow, options: playerRangeOptions,
                selection: $settings.maxPlayerNumber,
                valueLabel: "1–\(settings.maxPlayerNumber)"
            )
            SettingsDividerWidget()
            SettingsToggleRowWidget(
                symbol: "iphone.radiowaves.left.and.right", title: "iPhone haptics",
                subtitle: "Watch alerts always play", isOn: $settings.hapticsEnabled
            )
            SettingsDividerWidget()
            SettingsToggleRowWidget(
                symbol: "sun.max", title: "Keep screen awake",
                subtitle: "While following a live match", tint: .sinBinAmber,
                isOn: $settings.keepScreenAwake
            )
            SettingsDividerWidget()
            SettingsToggleRowWidget(
                symbol: "lock.iphone", title: "Live Activity",
                subtitle: "Clock and score on the Lock Screen", isOn: $settings.liveActivityEnabled
            )
        }
    }
}
