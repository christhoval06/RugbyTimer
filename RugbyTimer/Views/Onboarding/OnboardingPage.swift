import SwiftUI

/// One onboarding screen. Edit `all` to change the tour copy.
struct OnboardingPage: Identifiable {
    let id: Int
    let symbol: String
    let eyebrow: LocalizedStringResource
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let tint: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0, symbol: "stopwatch", eyebrow: "WELCOME",
            title: "YOUR MATCH,\nON YOUR WRIST",
            description: "Rugby Timer is a referee's match clock. Set up the match on iPhone, kick off on Apple Watch and keep your eyes on the game.",
            tint: .pitchEmerald
        ),
        OnboardingPage(
            id: 1, symbol: "applewatch.radiowaves.left.and.right", eyebrow: "WHY USE IT",
            title: "EVERYTHING THE\nREFEREE TRACKS",
            description: "Run the clock, record tries, conversions and goals, and send players to the sin-bin. Countdowns run with the match clock, and your wrist taps when time is up.",
            tint: .sinBinAmber
        ),
        OnboardingPage(
            id: 2, symbol: "figure.rugby", eyebrow: "WHY I MADE IT",
            title: "BUILT BY\nA RUGBY PLAYER",
            description: "15+ years playing for Titanes Rugby Club and seven with Panama's national team taught me the game. Refereeing taught me what the clock really needs. I built Rugby Timer for the person holding the whistle.",
            tint: .cardYellow
        ),
        OnboardingPage(
            id: 3, symbol: "flag.checkered", eyebrow: "READY",
            title: "SET UP. SEND.\nKICK OFF.",
            description: "Name the teams and pick the half length, send the setup to your Watch, then start the match from your wrist. You can replay this tour any time from Settings.",
            tint: .pitchEmerald
        )
    ]
}
