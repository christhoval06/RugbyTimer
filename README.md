# Rugby Timer

A match clock for rugby referees, built for iPhone and Apple Watch. It keeps the clock, the sin-bins and the score on your wrist, so your eyes stay on the game.

## Features

- **Match clock**: first half, half-time, second half and full time, with configurable half lengths (40 down to 7 minutes). The Watch records how long each half ran past the clock.
- **Half-time break**: pick 2, 5, 10 or 15 minutes, or a custom length (1–30). The Watch counts the break down and alerts you when it ends.
- **Coin toss**: an optional toss on the Watch before kick-off, turned on from Setup, that records which team kicks off.
- **Sin-bins and cards**: yellow cards start a countdown (default 10 minutes, configurable). Red cards are logged as expulsions.
- **Scoring**: tries (+5), conversions (+2), penalty goals and drop goals (+3), with the scorer's shirt number.
- **Match stats**: half-time and full-time summaries on the Watch, with the score by half and a scoring breakdown per team.
- **End match early**: abandon a match for weather, injury or the pitch. The Watch asks first, then the current score becomes the final result.
- **Apple Watch first**: set the match up on iPhone and run it from the Watch. The Watch keeps an extended runtime session and schedules alerts for half-time, the half-time break and sin-bin expiry.
- **iPhone-only mode**: if no Watch is paired, the whole match runs on the phone.
- **Match record**: a timeline of every score and sanction, which you can share as text when the match ends.
- **Tap lock**: guards against accidental taps on the Watch during play.
- **Settings**: default team names, match length, sin-bin length, half-time break, shirt-number range, haptics, keep-screen-awake and app language.
- **Localized** in English, Spanish, French and Brazilian Portuguese. The language follows the device by default and can be changed in Settings › Language; the iPhone passes the choice to the Watch.

## Requirements

- Xcode 26 or later
- iOS 26.5+ and watchOS 26.5+

## Getting started

1. Open `RugbyTimer.xcodeproj` in Xcode.
2. Pick the `RugbyTimer` scheme to run on iPhone, or `RugbyTimerWatch Watch App` to run on Apple Watch.
3. To try iPhone and Watch together, run on a paired iPhone and Watch simulator pair.

Pass the `-skipOnboarding` launch argument to skip the splash screen and onboarding and go straight to Match Setup. The UI tests use it.

## Running tests

From Xcode, press ⌘U on either scheme. From the command line:

```bash
xcodebuild test -project RugbyTimer.xcodeproj -scheme RugbyTimer -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Project structure

```
RugbyTimer/                    iPhone app
├── App/                       AppState and its extensions: match flow, scoring, cards, coin toss, Watch sync
├── Core/                      Design tokens, settings, app language, app info
├── Models/                    MatchPeriod, MatchEvent, MatchCard, MatchStats, CoinToss
├── Services/                  Timer, haptics, coin toss, Watch sync, match record formatting, sharing
├── Tests/                     Timer, card countdown, stats and setup tests
├── Views/
│   ├── Onboarding/
│   ├── Setup/                 Teams, durations, half-time break, rules, coin toss, Watch status
│   ├── Live/                  Clock, scoreboard, scoring, sin-bins, final result
│   ├── Settings/              Match defaults, officiating, language, about
│   └── Shared/                Reusable pieces such as the minutes entry alert
└── Localizable.xcstrings
RugbyTimerWatch Watch App/     watchOS app: widgets, match summary, extended runtime and break alerts
RugbyTimerTests/               Unit tests (coin toss, half-time break, end match early, phone-hosted match)
RugbyTimerUITests/             UI tests
scripts/check_localization.py  Localization audit
```

iPhone and Watch stay in sync through `WatchConnectivityService`. The iPhone sends a `MatchConfiguration` and the Watch replies with `MatchSnapshot` updates (clock, score, cards and events). New fields on these payloads are optional, so older versions of either app can still decode them.

## Contributing

See [AGENTS.md](AGENTS.md) for the SwiftUI conventions:

- One widget per file, in each feature's `Widgets/` directory.
- Screen views only compose widgets and pass bindings or callbacks.
- Use the shared tokens in `RugbyTimer/Core/DesignTokens.swift`. Don't add feature-specific palettes.
- Don't hardcode UI text. Every new string needs `es`, `fr` and `pt-BR` entries in both `Localizable.xcstrings` catalogs (iPhone and Watch).

### Localization check

Build both schemes, then run the audit against the build's DerivedData folder. It must report 0 problems:

```bash
scripts/check_localization.py --derived-data <path-to-DerivedData>
```

It flags missing or stale translations, strings the compiler extracted but the catalog lacks, and hardcoded UI text. Mark an intentional English literal with `// l10n-ignore`.

## Author

Built by [Christhoval Barba](https://christhoval.dev), a player with Titanes Rugby Club, a former Panama national team player, and a rugby referee.

Support: me@christhoval.dev
