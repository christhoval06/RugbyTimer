# Rugby Timer

A match clock for rugby referees, built for iPhone and Apple Watch. It keeps the clock, the sin-bins and the score on your wrist, so your eyes stay on the game.

## Features

- **Match clock**: first half, half-time, second half and full time, with configurable half lengths (40 down to 7 minutes).
- **Sin-bins and cards**: yellow cards start a countdown (default 10 minutes, configurable). Red cards are logged as expulsions.
- **Scoring**: tries (+5), conversions (+2), penalty goals and drop goals (+3), with the scorer's shirt number.
- **Apple Watch first**: set the match up on iPhone and run it from the Watch. The Watch keeps an extended runtime session and schedules alerts for half-time and sin-bin expiry.
- **iPhone-only mode**: if no Watch is paired, the whole match runs on the phone.
- **Match record**: a timeline of every score and sanction, which you can share as text when the match ends.
- **Tap lock**: guards against accidental taps on the Watch during play.
- **Settings**: default team names, match length, sin-bin length, shirt-number range, haptics and keep-screen-awake.
- **Localized** in English, Spanish, French and Brazilian Portuguese.

## Requirements

- Xcode 26 or later
- iOS 26.5+ and watchOS 26.5+

## Getting started

1. Open `RugbyTimer.xcodeproj` in Xcode.
2. Pick the `RugbyTimer` scheme to run on iPhone, or `RugbyTimerWatch Watch App` to run on Apple Watch.
3. To try iPhone and Watch together, run on a paired iPhone and Watch simulator pair.

Pass the `-skipOnboarding` launch argument to go straight to Match Setup. The UI tests use it.

## Running tests

From Xcode, press ⌘U on either scheme. From the command line:

```bash
xcodebuild test -project RugbyTimer.xcodeproj -scheme RugbyTimer -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Project structure

```
RugbyTimer/                    iPhone app
├── App/                       AppState: the shared match state machine
├── Core/                      Design tokens, settings, app info
├── Models/                    MatchPeriod, MatchEvent, MatchCard
├── Services/                  Timer, haptics, Watch sync, match record formatting, sharing
├── Views/
│   ├── Onboarding/
│   ├── Setup/                 Teams, durations, rules, Watch status
│   ├── Live/                  Clock, scoreboard, scoring, sin-bins
│   ├── Settings/
│   └── Summary/
└── Localizable.xcstrings
RugbyTimerWatch Watch App/     watchOS app (widgets and extended runtime service)
RugbyTimerTests/               Unit tests
RugbyTimerUITests/             UI tests
```

iPhone and Watch stay in sync through `WatchConnectivityService`. The iPhone sends a `MatchConfiguration` and the Watch replies with `MatchSnapshot` updates (clock, score, cards and events). New fields on these payloads are optional, so older versions of either app can still decode them.

## Contributing

See [AGENTS.md](AGENTS.md) for the SwiftUI conventions:

- One widget per file, in each feature's `Widgets/` directory.
- Screen views only compose widgets and pass bindings or callbacks.
- Use the shared tokens in `RugbyTimer/Core/DesignTokens.swift`. Don't add feature-specific palettes.

## Author

Built by [Christhoval Barba](https://christhoval.dev), a player with Titanes Rugby Club, a former Panama national team player, and a rugby referee.

Support: support@christhoval.dev
