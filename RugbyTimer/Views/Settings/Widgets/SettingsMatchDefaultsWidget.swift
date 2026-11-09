import SwiftUI

struct SettingsMatchDefaultsWidget: View {
    @ObservedObject var settings: AppSettings

    private var halfLengthOptions: [(value: Int, label: String)] {
        AppSettings.halfLengthOptions.map { ($0 * 60, String(localized: "\($0) min")) }
    }

    private var sinBinOptions: [(value: Int, label: String)] {
        AppSettings.sinBinOptions.map { ($0 * 60, String(localized: "\($0) min")) }
    }

    var body: some View {
        SettingsGroupWidget(number: "01", title: "MATCH DEFAULTS", detail: "EVERY NEW SETUP") {
            SettingsMenuRowWidget(
                symbol: "timer", title: "Half length", subtitle: "Match format per half",
                tint: .pitchEmerald, options: halfLengthOptions,
                selection: $settings.defaultHalfSeconds,
                valueLabel: String(localized: "\(settings.defaultHalfSeconds / 60) MIN")
            )
            SettingsDividerWidget()
            SettingsMenuRowWidget(
                symbol: "rectangle.fill", title: "Sin-bin penalty", subtitle: "Yellow card countdown",
                tint: .sinBinAmber, options: sinBinOptions,
                selection: $settings.defaultSinBinSeconds,
                valueLabel: String(localized: "\(settings.defaultSinBinSeconds / 60) MIN")
            )
            SettingsDividerWidget()
            SettingsTeamNamesWidget(homeTeam: $settings.defaultHomeTeam, awayTeam: $settings.defaultAwayTeam)
        }
    }
}
