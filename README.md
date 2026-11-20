# Rugby Timer

A match clock for rugby referees, built for iPhone and Apple Watch. It keeps the clock, the sin-bins and the score on your wrist, so your eyes stay on the game.

## Features

- **Match clock**: first half, half-time, second half and full time, with configurable half lengths (40 down to 7 minutes). The Watch records how long each half ran past the clock.
- **Extra time**: for knockout matches, pick *Fifteens* (two 10-minute halves, then 10-minute sudden-death periods) or *Sevens* (5-minute sudden-death periods) in Setup or the Watch Quick Match. When the scores are level at full time, the match goes to an extra-time break instead of ending: kick off the next period, or end the match as a draw (for a kicking competition). In sudden death the END button appears as soon as a team scores; the referee blows the whistle, so a mis-tapped score can still be undone. Match time, the record and the stats carry on through extra time, with extra-time points shown apart.
- **Half-time break**: pick 2, 5, 10 or 15 minutes, or a custom length (1–30). The Watch counts the break down and alerts you when it ends.
- **Coin toss**: an optional toss on the Watch before kick-off, turned on from Setup, that records which team kicks off.
- **Sin-bins and cards**: yellow cards start a countdown (default 10 minutes, configurable). Red cards are logged as expulsions. With the **20-minute red card** rule on (Setup, or the Watch Quick Match), a red can also be a 20-minute red: the player is off for good, and the team can bring on a replacement when the 20 minutes run out. A second yellow for the same player asks to show a red instead, which ends their sin-bin (a 20-minute red when the rule is on).
- **Injury timers** track a Head Injury Assessment (HIA) for 12 minutes or a blood replacement for 15 minutes. Select the player's shirt number to start the timer. The countdown runs through stoppages and half-time, and the Watch alerts you when time is up. Record *back on* or *replaced* to close the timer and log the outcome. The HIA process applies in approved competitions, where medical staff decide whether the player can return. [World Rugby's HIA protocol](https://passport.world.rugby/player-welfare-medical/concussion-management-for-match-day-medical-staff-using-the-hia-protocol/hia-protocol/)
- **Sin-bin control**: on the device running the match, tap a player in the off-field list to end their sin-bin (or 20-minute red) early or fix a wrong shirt number, on the card and in the record. The card picker starts empty, so a card never goes to a number you didn't pick.
- **Substitutions** let you record who goes off and who comes on by shirt number. Set an optional per-team limit (8, 5, 12 or none) in Match Setup or Watch Quick Match. On the Watch, use the Substitutions page in Compact or a team's Substitutions page in Extended. In iPhone-only mode, use the **Substitution** button. You can see each team's count live and in the stats, and review the entries in the match record. The app warns you if the team has reached its limit or the player has a card or was already replaced.
- **Scoring**: tries (+5), penalty tries (+7), conversions (+2), penalty goals and drop goals (+3), with the scorer's shirt number.
- **Penalty count** lets you record a penalty (PEN) or free kick (FK) against a team from the Watch Penalties page or the iPhone-only live screen. You can undo the last entry. The iPhone lists the entries with their match times, newest first. Half-time and full-time stats show each team's totals, with penalties by half at full time. The match record includes the totals.
- **Match stats**: half-time and full-time summaries on the Watch, with the score by half and a scoring breakdown per team.
- **End match early**: abandon a match for weather, injury or the pitch. The Watch asks first, then the current score becomes the final result.
- **Apple Watch first**: set the match up on iPhone and run it from the Watch. With Health access, the Watch runs the match as a Rugby workout, which keeps it running from kick-off to full time and saves the workout to Health. Without it, the Watch falls back to an extended runtime session. Either way it schedules alerts for half-time, the half-time break and sin-bin expiry.
- **Crash recovery**: the device running the clock saves the match after every change. If the app is closed or crashes, it reopens on the same match, with the clock, score, sin-bins and record intact.
- **Undo last entry**: for 15 seconds after a score, card, penalty or injury timer, an Undo button takes it back (wrong team, wrong number or a mis-tap). Undoing a card also removes its sin-bin.
- **iPhone-only mode**: if no Watch is paired, the whole match runs on the phone.
- **Watch Quick Match**: no iPhone at the ground? Set up a match on the Watch alone (half length, break, sin-bin length, tap lock, coin toss, 20-minute red) and play Team A against Team B. The Watch remembers the last choices, and sends the finished match to the iPhone's match history.
- **Match record**: a timeline of every score and sanction, which you can share as text when the match ends.
- **Match history**: every finished match is kept on the iPhone, newest first, from the Match History button on Match Setup. Tap a match to read or share its record; swipe to delete it. Matches run on the iPhone, run on the Watch, and Watch Quick Matches all appear (the Watch sends a Quick Match to the iPhone at full time, even if the iPhone is out of range then). Stored with SwiftData behind `MatchHistoryStorage`; only `Persistence/` imports SwiftData.
- **Live Activity**: while a match is set up or under way, the iPhone shows the clock, score and sin-bins on the Lock Screen and in the Dynamic Island, whether the match runs on the Watch or the iPhone. It can be turned off in Settings.
- **Match widget**: a Home Screen widget (small and medium) and Lock Screen widgets on iPhone. They show the match under way, or the last result between matches.
- **Watch complication**: the match clock and score on the watch face (circular, rectangular and inline).
- **Tap lock**: guards against accidental taps on the Watch during play.
- **Settings**: default team names, match length, sin-bin length, half-time break, shirt-number range, haptics, keep-screen-awake, Live Activity and app language.
- **Localized** in English, Spanish, French and Brazilian Portuguese. The language follows the device by default and can be changed in Settings › Language; the iPhone passes the choice to the Watch.

## Apple Watch layouts

**Compact** is the default. Swipe right from the clock to Penalties, Sanctions and Substitutions as enabled, or left to Score and Result.

Turn on **Extended layout** under **Watch display settings** in Watch **Quick Match** or iPhone **Match Setup**. **Send Setup to Watch** applies the iPhone choices to the new match. For a match set up on iPhone, you can adjust them on the Watch's **Match Ready** screen before kick-off.

In **Extended**, start at the center clock. Swipe right for Team B (Away) or left for Team A (Home). Moving farther from the clock in either direction takes you through five separate pages in this order.

**Score → Penalties → Sanctions → Substitutions → Injuries**

Turn on **Show penalties and sanctions** in Watch display settings to show those entry pages in either layout. Substitution pages appear when you enable substitution tracking for the match. In Extended, you can record HIA and blood replacements on each team's **Injuries** page.

Swipe up or turn the Digital Crown in the center during play to move through these pages.

1. **Match Clock** has the main timer, pause and resume, and controls for ending or starting a period.
2. **Time Details** shows elapsed and remaining time and offers **End Match Early**.
3. **Active Timers** shows sanctions, injury timers and any running break countdown. You can still reach active timers with the penalty and sanction entry pages hidden.
4. **Result** shows the live summary and a **Match Clock** button to return to the timer. At full time, the Watch opens the final result.

## Requirements

- Xcode 26 or later
- iOS 26.5+ and watchOS 26.5+

## Getting started

1. Open `RugbyTimer.xcodeproj` in Xcode.
2. Pick the `RugbyTimer` scheme to run on iPhone, or `RugbyTimerWatch Watch App` to run on Apple Watch.
3. To try iPhone and Watch together, run on a paired iPhone and Watch simulator pair.

The Watch target has the HealthKit capability (`RugbyTimerWatch Watch App.entitlements`) and the `workout-processing` background mode. With automatic signing, Xcode adds HealthKit to the Watch App ID on the first device build. The Watch asks for Health access once, on the ready screen before kick-off. Decline it to test the extended runtime fallback.

The apps share the match with their widgets through the App Group `group.dev.christhoval.apps.RugbyTimer`: the iPhone app and the Live Activity extension, and the Watch app and the complication. Each target that ships has a `PrivacyInfo.xcprivacy` privacy manifest.

Pass the `-skipOnboarding` launch argument to skip the splash screen and onboarding and go straight to Match Setup. UI tests also pass `-uiTesting`, so every launch starts clean: no match to recover, default settings, and an empty history kept in memory (see `LaunchOptions`). Nothing a UI test does touches your real data.

## Running tests

From Xcode, press ⌘U on either scheme. From the command line:

```bash
xcodebuild test -project RugbyTimer.xcodeproj -scheme RugbyTimer -destination 'platform=iOS Simulator,name=iPhone 17'
```

Before a release, run [TESTING.md](TESTING.md) on a real iPhone and Apple Watch. It covers what the simulator can't: App Group signing, the widgets and complication, the Live Activity, Health workouts and alerts with your wrist down.

## Project structure

```
RugbyTimer/                    iPhone app
├── App/                       AppState and its extensions: match flow, scoring, cards, undo, coin toss, Watch sync, persistence
├── Core/                      Design tokens, settings, app language, app info
├── Models/                    MatchPeriod, MatchEvent, MatchCard, MatchStats, CoinToss, SavedMatch
├── Persistence/               Match history, crash recovery, Watch display preferences
├── Services/                  Timer, haptics, coin toss, Watch sync, match record formatting, sharing
├── Tests/                     Timer, card countdown, stats and setup tests
├── Views/
│   ├── Onboarding/
│   ├── Setup/                 Teams, durations, rules, Watch status and display settings
│   ├── Live/                  Clock, scoreboard, scoring, sin-bins, final result
│   ├── History/               Match history list
│   ├── Settings/              Match defaults, officiating, language, about
│   └── Shared/                Reusable pieces such as the minutes entry alert
└── Localizable.xcstrings
RugbyTimerWatch Watch App/     watchOS app
├── Models/                    Match summary, Quick Match setup, live page order
├── Services/                  Quick Match, workout session, extended runtime fallback, alerts
└── Views/                     One folder per screen: the screen's View, and its own Widgets/
    ├── Home/                  Set up on iPhone, or Quick Match (and its setup sheet)
    ├── Ready/                 Pre-match: matchup, coin toss, kick-off
    ├── Live/                  Compact and Extended match pagers
    ├── Clock/                 Clock controls, time details, off-field timers and breaks
    ├── Sanctions/             Cards, injury timers and the off-field list
    ├── Penalties/             Penalty and free-kick counter
    ├── Score/                 Scoring page
    ├── Substitutions/         Player changes and per-team counts
    ├── Result/                Score, scoring breakdown, discipline and penalty stats
    ├── Settings/              Watch display settings
    └── Shared/Widgets/        Widgets used by several screens (page title, pickers, tap lock, off-field rows)
RugbyTimerLiveActivity/        iPhone widget extension: the Live Activity and the Match widget (HomeWidget/)
RugbyTimerComplication/        Watch complication extension
RugbyTimerTests/               Unit tests (coin toss, half-time break, end match early, phone-hosted match, crash recovery, undo, law updates, injuries and sin-bin edits, penalty counts, extra time, match history)
RugbyTimerUITests/             UI tests (setup, match record sharing, penalty count, extra time, match history)
scripts/check_localization.py  Localization audit
```

iPhone and Watch stay in sync through `WatchConnectivityService`. The iPhone sends a `MatchConfiguration` with the match rules and Watch display choices. The Watch replies with `MatchSnapshot` updates for the clock, score, cards and events. New fields on these payloads are optional, so older versions of either app can still decode them.

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
