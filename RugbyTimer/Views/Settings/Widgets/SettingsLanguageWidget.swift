import SwiftUI

/// App language for iPhone and Apple Watch. "System" follows the device, with English
/// as the fallback when the device language is not one the app ships.
struct SettingsLanguageWidget: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        SettingsGroupWidget(number: "03", title: "LANGUAGE", detail: "IPHONE & WATCH") {
            HStack(spacing: 12) {
                SetupSettingLabelWidget(symbol: "globe", title: "App language",
                                        subtitle: "English when your language isn't available", tint: .pitchEmerald)
                Spacer(minLength: 4)
                Menu {
                    Picker("App language", selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { language in
                            name(for: language).tag(language)
                        }
                    }
                } label: {
                    Label { name(for: settings.language) } icon: { Image(systemName: "chevron.down") }
                        .font(.system(size: 13, weight: .heavy).width(.condensed))
                        .foregroundStyle(Color.pitchEmerald)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 44)
                        .background(Color.pitchEmerald.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }
                .onChange(of: settings.language) { HapticService.playStartStop() }
                .accessibilityLabel("App language")
                .accessibilityValue(name(for: settings.language))
                .accessibilityIdentifier("appLanguage")
            }
            .padding(14)
        }
    }

    /// Languages appear in their own words; only "System" is translated.
    private func name(for language: AppLanguage) -> Text {
        guard let nativeName = language.nativeName else { return Text("System") }
        return Text(verbatim: nativeName)
    }
}

#Preview("Language") {
    SettingsLanguageWidget(settings: AppSettings())
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
