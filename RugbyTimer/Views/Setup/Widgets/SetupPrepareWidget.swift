import SwiftUI

struct SetupPrepareWidget: View {
    /// A Watch with RugbyTimer is paired. Decides which way of running the match is the main button.
    let isWatchAvailable: Bool
    let onPrepareMatch: () -> Void
    let onRunOnPhone: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            if isWatchAvailable || onRunOnPhone == nil {
                watchButton
                if let onRunOnPhone {
                    SetupSecondaryActionWidget(symbol: "iphone", title: "RUN ON THIS IPHONE INSTEAD",
                                               identifier: "runMatchOnPhone", action: onRunOnPhone)
                }
            } else if let onRunOnPhone {
                SetupPrimaryActionWidget(symbol: "iphone", title: "RUN MATCH ON IPHONE",
                                         subtitle: "NO APPLE WATCH NEEDED", trailingSymbol: "play.fill",
                                         identifier: "runMatchOnPhone", action: onRunOnPhone)
                SetupSecondaryActionWidget(symbol: "applewatch", title: "SEND SETUP TO WATCH",
                                           identifier: "sendMatchSetup", action: onPrepareMatch)
            }
            Label(isWatchAvailable || onRunOnPhone == nil ? "Start the match on Apple Watch" : "Clock, score and cards run on this iPhone",
                  systemImage: "lock.fill")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.outline)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid)
        .overlay(alignment: .top) { Color.armorBorder.frame(height: 1) }
    }

    private var watchButton: some View {
        SetupPrimaryActionWidget(symbol: "applewatch", title: "SEND SETUP TO WATCH",
                                 subtitle: "READY FOR KICKOFF", trailingSymbol: "arrow.up.right",
                                 identifier: "sendMatchSetup", action: onPrepareMatch)
    }
}
