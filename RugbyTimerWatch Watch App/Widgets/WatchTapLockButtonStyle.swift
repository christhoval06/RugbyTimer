import SwiftUI
import WatchKit

extension EnvironmentValues {
    /// Set from the iPhone's "Accidental tap lock" toggle for the configured match.
    @Entry var tapLockEnabled = false
}

/// With tap lock on, the action fires only after a short press-and-hold, with a fill
/// showing progress; a quick tap gives a "hold longer" haptic and does nothing.
/// With tap lock off it behaves like a plain button.
struct WatchTapLockButtonStyle: PrimitiveButtonStyle {
    /// How hold progress is drawn: a left-to-right fill for buttons, a sweep for round controls.
    enum Progress { case bar, ring }

    static let holdDuration = 0.5
    var progress: Progress = .bar

    func makeBody(configuration: Configuration) -> some View {
        WatchTapLockButton(configuration: configuration, progress: progress)
    }
}

private struct WatchTapLockButton: View {
    let configuration: PrimitiveButtonStyle.Configuration
    let progress: WatchTapLockButtonStyle.Progress

    @Environment(\.tapLockEnabled) private var tapLockEnabled
    @State private var isHolding = false
    @State private var didTrigger = false

    var body: some View {
        if tapLockEnabled {
            configuration.label
                .overlay(alignment: .leading) {
                    switch progress {
                    case .bar: progressFill
                    case .ring: progressRing
                    }
                }
                .scaleEffect(isHolding ? 0.96 : 1)
                .animation(.easeOut(duration: 0.15), value: isHolding)
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: WatchTapLockButtonStyle.holdDuration, maximumDistance: 12) {
                    didTrigger = true
                    configuration.trigger()
                } onPressingChanged: { pressing in
                    if pressing {
                        didTrigger = false
                    } else if !didTrigger {
                        WKInterfaceDevice.current().play(.directionDown)
                    }
                    isHolding = pressing
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Press and hold to confirm")
                .accessibilityAction { configuration.trigger() }
        } else {
            Button(action: configuration.trigger) { configuration.label }
                .buttonStyle(.plain)
        }
    }

    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: isHolding ? 1 : 0)
            .stroke(Color.iceTitanium, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .padding(-5)
            .opacity(isHolding ? 0.9 : 0)
            .animation(isHolding ? .linear(duration: WatchTapLockButtonStyle.holdDuration) : .easeOut(duration: 0.15),
                       value: isHolding)
            .allowsHitTesting(false)
    }

    private var progressFill: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(Color.iceTitanium.opacity(0.28))
                .frame(width: isHolding ? proxy.size.width : 0)
                .animation(isHolding ? .linear(duration: WatchTapLockButtonStyle.holdDuration) : .easeOut(duration: 0.15),
                           value: isHolding)
        }
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .allowsHitTesting(false)
    }
}
