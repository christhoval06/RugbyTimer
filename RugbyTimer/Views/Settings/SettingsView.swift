import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    SettingsMatchDefaultsWidget(settings: settings)
                    SettingsOfficiatingWidget(settings: settings)
                    SettingsAboutWidget(settings: settings)
                    SettingsSupportWidget()
                    SettingsResetWidget(onReset: settings.resetToStandard)
                    SettingsFooterWidget()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.pitchVoid.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("closeSettings")
                }
            }
        }
        .tint(Color.pitchEmerald)
    }
}

#Preview("Settings") {
    SettingsView()
        .environmentObject(AppSettings())
        .preferredColorScheme(.dark)
}
