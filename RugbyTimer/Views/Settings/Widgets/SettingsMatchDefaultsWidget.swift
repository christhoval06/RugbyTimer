import SwiftUI

struct SettingsMatchDefaultsWidget: View {
    @ObservedObject var settings: AppSettings

    private var halfLengthOptions: [(value: Int, label: String)] {
        AppSettings.halfLengthOptions.map { ($0 * 60, String(appLocalized: "\($0) min")) }
    }

    private var halfTimeBreakOptions: [(value: Int, label: String)] {
        AppSettings.halfTimeBreakOptions.map { ($0 * 60, String(appLocalized: "\($0) min")) }
    }

    private var sinBinOptions: [(value: Int, label: String)] {
        AppSettings.sinBinOptions.map { ($0 * 60, String(appLocalized: "\($0) min")) }
    }

    var body: some View {
        SettingsGroupWidget(number: "01", title: "MATCH DEFAULTS", detail: "EVERY NEW SETUP") {
            SettingsMenuRowWidget(
                symbol: "timer", title: "Half length", subtitle: "Match format per half",
                tint: .pitchEmerald, options: halfLengthOptions,
                selection: $settings.defaultHalfSeconds,
                valueLabel: String(appLocalized: "\(settings.defaultHalfSeconds / 60) MIN"),
                custom: .init(title: "Custom Half-Length",
                              message: "Enter the number of minutes per half (a positive whole number).")
            )
            SettingsDividerWidget()
            SettingsMenuRowWidget(
                symbol: "cup.and.saucer", title: "Half-time break", subtitle: "Countdown on the Watch",
                tint: .iceTitanium, options: halfTimeBreakOptions,
                selection: $settings.halfTimeBreakSeconds,
                valueLabel: String(appLocalized: "\(settings.halfTimeBreakSeconds / 60) MIN"),
                custom: .init(title: "Custom Half-Time Break",
                              message: "Enter the half-time break in minutes (1–30).",
                              range: SetupHalfTimeBreakWidget.customRange)
            )
            SettingsDividerWidget()
            SettingsMenuRowWidget(
                symbol: "rectangle.fill", title: "Sin-bin penalty", subtitle: "Yellow card countdown",
                tint: .sinBinAmber, options: sinBinOptions,
                selection: $settings.defaultSinBinSeconds,
                valueLabel: String(appLocalized: "\(settings.defaultSinBinSeconds / 60) MIN"),
                custom: .init(title: "Custom Sin-Bin Duration",
                              message: "Enter the yellow card countdown in minutes (a positive whole number).")
            )
            SettingsDividerWidget()
            SettingsTeamNamesWidget(homeTeam: $settings.defaultHomeTeam, awayTeam: $settings.defaultAwayTeam)
        }
    }
}
