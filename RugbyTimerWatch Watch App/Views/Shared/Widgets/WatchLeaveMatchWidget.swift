import SwiftUI

/// Back to the Watch main screen, where the referee can start a Quick Match or wait for the iPhone.
/// Before kick-off it changes the setup; at full time it starts over and asks first,
/// because the result and stats on the Watch are cleared.
struct WatchLeaveMatchWidget: View {
    enum Kind { case changeSetup, quickMatchInstead, newMatch }

    let kind: Kind
    let onLeave: () -> Void

    @State private var isConfirming = false

    var body: some View {
        Button { kind == .newMatch ? isConfirming = true : onLeave() } label: {
            Label { title } icon: { Image(systemName: symbol) }
                .font(.system(size: 11, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.pitchEmerald)
                .frame(maxWidth: .infinity, minHeight: 32)
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.pitchEmerald.opacity(0.5)))
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .confirmationDialog("Start a new match?", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("New match", role: .destructive, action: onLeave)
            Button("Keep result", role: .cancel) {}
        } message: {
            Text("This match's result and stats are cleared from the Watch.")
        }
    }

    private var title: Text {
        switch kind {
        case .changeSetup: Text("CHANGE SETUP")
        case .quickMatchInstead: Text("QUICK MATCH INSTEAD")
        case .newMatch: Text("NEW MATCH")
        }
    }

    private var symbol: String {
        switch kind {
        case .changeSetup: "slider.horizontal.3"
        case .quickMatchInstead: "bolt.fill"
        case .newMatch: "plus"
        }
    }
}

#Preview("Leave options") {
    VStack {
        WatchLeaveMatchWidget(kind: .changeSetup) {}
        WatchLeaveMatchWidget(kind: .quickMatchInstead) {}
        WatchLeaveMatchWidget(kind: .newMatch) {}
    }
    .padding()
}
