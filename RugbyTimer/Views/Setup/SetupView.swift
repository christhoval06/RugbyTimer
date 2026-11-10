import SwiftUI

public struct SetupView: View {
    @Binding public var homeTeamName: String
    @Binding public var awayTeamName: String
    @Binding public var selectedDurationSeconds: Int
    @Binding public var sinBinDurationSeconds: Int
    @Binding public var halfTimeBreakSeconds: Int
    public var isWatchSynced: Bool
    public var watchName: String
    public var watchBattery: Int
    public var isWatchAvailable: Bool
    public var onPrepareMatch: () -> Void
    public var onRunOnPhone: (() -> Void)?

    public init(
        homeTeamName: Binding<String>,
        awayTeamName: Binding<String>,
        selectedDurationSeconds: Binding<Int>,
        sinBinDurationSeconds: Binding<Int>,
        halfTimeBreakSeconds: Binding<Int> = .constant(120),
        isWatchSynced: Bool = true,
        watchName: String = "APPLE WATCH ULTRA",
        watchBattery: Int = 98,
        isWatchAvailable: Bool = true,
        onPrepareMatch: @escaping () -> Void,
        onRunOnPhone: (() -> Void)? = nil
    ) {
        self._homeTeamName = homeTeamName
        self._awayTeamName = awayTeamName
        self._selectedDurationSeconds = selectedDurationSeconds
        self._sinBinDurationSeconds = sinBinDurationSeconds
        self._halfTimeBreakSeconds = halfTimeBreakSeconds
        self.isWatchSynced = isWatchSynced
        self.watchName = watchName
        self.watchBattery = watchBattery
        self.isWatchAvailable = isWatchAvailable
        self.onPrepareMatch = onPrepareMatch
        self.onRunOnPhone = onRunOnPhone
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SetupHeaderWidget(isWatchAvailable: isWatchAvailable)
                    SetupWatchStatusWidget(isWatchSynced: isWatchSynced, watchName: watchName,
                                           watchBattery: watchBattery, isWatchAvailable: isWatchAvailable)
                    SetupTeamsWidget(homeTeamName: $homeTeamName, awayTeamName: $awayTeamName)
                    SetupDurationWidget(selectedDurationSeconds: $selectedDurationSeconds)
                    SetupRulesWidget(sinBinDurationSeconds: $sinBinDurationSeconds,
                                     halfTimeBreakSeconds: $halfTimeBreakSeconds)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .clipped()
            SetupPrepareWidget(isWatchAvailable: isWatchAvailable, onPrepareMatch: onPrepareMatch,
                               onRunOnPhone: onRunOnPhone)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
    }
}

#Preview("Setup Screen Preview") {
    @Previewable @State var home = "Rangers RFC"
    @Previewable @State var away = "City Lions"
    @Previewable @State var duration = 2400
    @Previewable @State var sinBinDuration = 600

    return SetupView(
        homeTeamName: $home,
        awayTeamName: $away,
        selectedDurationSeconds: $duration,
        sinBinDurationSeconds: $sinBinDuration,
        isWatchSynced: true,
        watchName: "APPLE WATCH ULTRA",
        watchBattery: 98,
        onPrepareMatch: {
            print("Send setup to watch tapped!")
        }
    )
    .environmentObject(AppSettings())
    .preferredColorScheme(.dark)
}
