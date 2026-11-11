import SwiftUI

/// Substitutions for this match: on or off (off hides the Watch page and the iPhone SUB button),
/// and how many each team may make. Remembered for the next match.
struct SetupSubstitutionsWidget: View {
    @EnvironmentObject private var settings: AppSettings

    private var rules: SubstitutionRules { settings.substitutionRules }

    private var subtitle: LocalizedStringKey {
        guard rules.isEnabled else { return "Off · no substitutions page on the Watch" }
        return rules.hasLimit ? "Up to \(rules.limit) per team" : "No limit · rolling substitutions"
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SetupSettingLabelWidget(symbol: "arrow.left.arrow.right", title: "Substitutions",
                                        subtitle: subtitle, tint: Color.pitchEmerald)
                Spacer(minLength: 4)
                Toggle("Substitutions", isOn: $settings.substitutionRules.isEnabled)
                    .labelsHidden()
                    .tint(Color.pitchEmerald)
                    .onChange(of: rules.isEnabled) { HapticService.playStartStop() }
                    .accessibilityIdentifier("setup.substitutions.toggle")
            }
            if rules.isEnabled {
                Picker("Substitutions per team", selection: $settings.substitutionRules.limit) {
                    ForEach(SubstitutionRules.limitOptions, id: \.self) { limit in
                        if limit == SubstitutionRules.unlimited {
                            Text("No limit").tag(limit)
                        } else {
                            Text(verbatim: "\(limit)").tag(limit)
                        }
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: rules.limit) { HapticService.playStartStop() }
                .accessibilityIdentifier("setup.substitutions.limit")
            }
        }
        .padding(14)
    }
}

#Preview("Substitutions") {
    SetupSubstitutionsWidget()
        .environmentObject(AppSettings())
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
