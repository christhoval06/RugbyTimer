# Rugby Timer

A match clock for rugby referees, built for iPhone and Apple Watch. It keeps the clock, the sin-bins and the score on your wrist, so your eyes stay on the game.

## Features

- **Match clock**: first half, half-time, second half and full time, with configurable half lengths (40 down to 7 minutes). The Watch records how long each half ran past the clock.
- **Half-time break**: pick 2, 5, 10 or 15 minutes, or a custom length (1–30). The Watch counts the break down and alerts you when it ends.
- **Coin toss**: an optional toss on the Watch before kick-off, turned on from Setup, that records which team kicks off.
- **Sin-bins and cards**: yellow cards start a countdown (default 10 minutes, configurable). Red cards are logged as expulsions. With the **20-minute red card** rule on (Setup, or the Watch Quick Match), a red can also be a 20-minute red: the player is off for good, and the team can bring on a replacement when the 20 minutes run out. A second yellow for the same player asks to show a red instead, which ends their sin-bin (a 20-minute red when the rule is on).
- **Scoring**: tries (+5), penalty tries (+7), conversions (+2), penalty goals and drop goals (+3), with the scorer's shirt number.
- **Match stats**: half-time and full-time summaries on the Watch, with the score by half and a scoring breakdown per team.
- **End match early**: abandon a match for weather, injury or the pitch. The Watch asks first, then the current score becomes the final result.
- **Apple Watch first**: set the match up on iPhone and run it from the Watch. With Health access, the Watch runs the match as a Rugby workout, which keeps it running from kick-off to full time and saves the workout to Health. Without it, the Watch falls back to an extended runtime session. Either way it schedules alerts for half-time, the half-time break and sin-bin expiry.
- **Crash recovery**: the device running the clock saves the match after every change. If the app is closed or crashes, it reopens on the same match, with the clock, score, sin-bins and record intact.
- **Undo last entry**: for 15 seconds after a score or card, an Undo button takes it back (wrong team, wrong number or a mis-tap). Undoing a card also removes its sin-bin.
- **iPhone-only mode**: if no Watch is paired, the whole match runs on the phone.
- **Watch Quick Match**: no iPhone at the ground? Set up a match on the Watch alone (half length, break, sin-bin length, tap lock, coin toss, 20-minute red) and play Team A against Team B. The Watch remembers the last choices. A Quick Match isn't sent to the iPhone.
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

The Watch target has the HealthKit capability (`RugbyTimerWatch Watch App.entitlements`) and the `workout-processing` background mode. With automatic signing, Xcode adds HealthKit to the Watch App ID on the first device build. The Watch asks for Health access once, on the ready screen before kick-off. Decline it to test the extended runtime fallback.

Pass the `-skipOnboarding` launch argument to skip the splash screen and onboarding and go straight to Match Setup. The UI tests use it.

## Running tests

From Xcode, press ⌘U on either scheme. From the command line:

```bash
xcodebuild test -project RugbyTimer.xcodeproj -scheme RugbyTimer -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Project structure

```
RugbyTimer/                    iPhone app
├── App/                       AppState and its extensions: match flow, scoring, cards, undo, coin toss, Watch sync, persistence
├── Core/                      Design tokens, settings, app language, app info
├── Models/                    MatchPeriod, MatchEvent, MatchCard, MatchStats, CoinToss, SavedMatch
├── Services/                  Timer, haptics, coin toss, Watch sync, match persistence, match record formatting, sharing
├── Tests/                     Timer, card countdown, stats and setup tests
├── Views/
│   ├── Onboarding/
│   ├── Setup/                 Teams, durations, half-time break, rules, coin toss, Watch status
│   ├── Live/                  Clock, scoreboard, scoring, sin-bins, final result
│   ├── Settings/              Match defaults, officiating, language, about
│   └── Shared/                Reusable pieces such as the minutes entry alert
└── Localizable.xcstrings
RugbyTimerWatch Watch App/     watchOS app: widgets, Quick Match, match summary, workout session, extended runtime fallback and alerts
RugbyTimerTests/               Unit tests (coin toss, half-time break, end match early, phone-hosted match, crash recovery, undo, law updates)
RugbyTimerUITests/             UI tests
scripts/check_localization.py  Localization audit
```

iPhone and Watch stay in sync through `WatchConnectivityService`. The iPhone sends a `MatchConfiguration` and the Watch replies with `MatchSnapshot` updates (clock, score, cards and events). New fields on these payloads are optional, so older versions of either app can still decode them.

The device running the clock (the Watch, or the iPhone in iPhone-only mode) also saves the match to `current-match.json` in Application Support through `MatchPersistence`, and `AppState.launch()` restores it at startup. An iPhone that only mirrors a Watch match keeps no copy of its own.

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

## Privacy

Rugby Timer collects no data. Read the full [privacy policy](PRIVACY.md).
