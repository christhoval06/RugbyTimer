import SwiftUI

/// Quick Match setup on the Watch: half length, half-time break, sin-bin, tap lock, coin toss, 20-minute red and extra time.
/// Teams are always Team A and Team B; there's no team editor on the wrist.
struct WatchQuickSetupView: View {
    let onReady: (WatchQuickSetup) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var setup = WatchQuickSetup.load()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    minutesPicker("Half length", selection: $setup.halfSeconds,
                                  options: WatchQuickSetup.halfMinuteOptions)
                    minutesPicker("Half-time break", selection: $setup.halfTimeBreakSeconds,
                                  options: WatchQuickSetup.breakMinuteOptions)
                    minutesPicker("Sin-bin", selection: $setup.sinBinSeconds,
                                  options: WatchQuickSetup.sinBinMinuteOptions)
                }
                Section {
                    Toggle("Tap lock", isOn: $setup.tapLockEnabled)
                    Toggle("Coin toss", isOn: $setup.coinTossEnabled)
                    Toggle("20-minute red", isOn: $setup.twentyMinuteRedEnabled)
                    Picker("Extra time", selection: $setup.extraTimeFormat) {
                        Text("Off").tag(ExtraTimeFormat.off)
                        Text("Fifteens").tag(ExtraTimeFormat.twoHalves)
                        Text("Sevens").tag(ExtraTimeFormat.suddenDeath)
                    }
                }
                .tint(Color.pitchEmerald)
                Section {
                    readyButton
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Quick match")
        }
    }

    private var readyButton: some View {
        Button {
            setup.save()
            dismiss()
            onReady(setup)
        } label: {
            Label("READY", systemImage: "checkmark")
                .font(.system(size: 13, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.pitchVoid)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Sets up the match between Team A and Team B")
    }

    private func minutesPicker(_ title: LocalizedStringKey, selection: Binding<Int>,
                               options: [Int]) -> some View {
        Picker(title, selection: selection) {
            ForEach(options, id: \.self) { minutes in
                Text("\(minutes) min").tag(minutes * 60)
            }
        }
    }
}

#Preview("Quick match setup") {
    WatchQuickSetupView { _ in }
}
