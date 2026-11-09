# RugbyTimer

## 1. Project Overview
* **App Name:** RugbyTimer (Pitch Official System)
* **Purpose:** A mission-critical, athletic-brutalist timekeeping and card management system built for rugby match officials, featuring an iPhone setup/summary console and an Apple Watch live-match companion HUD.
* **Platforms:** iOS 17+ & watchOS 10+
* **Architecture:** SOLID Principles, MVVM-inspired reactive state management, single-responsibility files (<120 lines).
* **Tech Stack:** Swift, SwiftUI, Combine, WatchConnectivity, XCTest.

---

## 2. Directory Structure
```text
RugbyTimer/
├── App/
│   ├── RugbyTimerApp.swift          # iOS App Entry Point (@main)
│   └── AppState.swift               # Central State Store & Navigation
├── Core/
│   ├── DesignTokens.swift           # Colors & Typography (Athletic Brutalism spec)
│   └── HapticService.swift          # Cross-platform haptic engine (iOS & watchOS)
├── Models/
│   ├── Match.swift
│   ├── MatchCard.swift              # Sin-bin & Card data model
│   ├── MatchEvent.swift             # Minute-by-minute timeline event log
│   └── MatchPeriod.swift            # Pre-match, H1, Half-Time, H2, Full-Time
├── Services/
│   ├── MatchTimerService.swift      # Isolated timekeeping logic
│   └── WatchConnectivityService.swift # Bluetooth sync & telemetry
├── Views/
│   ├── Setup/
│   │   └── SetupView.swift          # Pre-match iPhone configuration form
│   ├── Live/
│   │   ├── LiveMatchView.swift      # Live Watch/Phone HUD container
│   │   ├── TimerRingView.swift      # Circular OLED countdown progress ring
│   │   ├── SinBinRowView.swift      # Horizontal yellow/red card countdown bar
│   │   └── CardModalView.swift      # 1-23 player picker & sanction modal
│   └── Summary/
│       └── MatchSummaryView.swift   # Post-match report & event timeline
├── RugbyTimerWatch Watch App/
│   └── RugbyTimerWatchApp.swift     # watchOS App Entry Point (@main)
└── Tests/
    ├── MatchTimerTests.swift
    ├── CardCountdownTests.swift
    ├── TimerRingTests.swift
    └── SetupValidationTests.swift
```

---

## 3. Design System & Styling (`DESIGN.md`)
* **Aesthetic:** Athletic Brutalism / Avionic instrumentation. Optimized for outdoor glare (direct sunlight) and night floodlights.
* **Color Tokens:**
  * Background Void: `#0B0E14` (OLED black)
  * Pitch Emerald (`#10B981`): Running clock, successful tries, active connection.
  * Sin-Bin Amber (`#F59E0B`): Warning states, active card countdowns, half-time.
  * Card Yellow (`#FACC15`): Regulatory yellow card cautions.
  * Expulsion Red (`#EF4444`): Red cards, emergency stops.
  * Ice Titanium White (`#F9FAFB`): High-contrast numeric display.
* **Typography:**
  * **Barlow Condensed:** All numeric counters, timers, and score lines (`tabular-nums` enforced to prevent layout jitter).
  * **Atkinson Hyperlegible Next:** Rule lookups, team names, and disciplinary logs (distinguishes ambiguous glyphs like `1`, `I`, `l` and `0`, `O`).
* **Constraints:** Low radius (`4px` to `8px`) for buttons to maximize touch surface area for rain/sweat/gloves. No pill-shaped buttons.

---

## 4. Core Architecture & SOLID Principles
* **Single Responsibility:** Every widget, model, and service lives in its own dedicated file. No file exceeds ~120 lines.
* **Dependency Injection:** Services like `MatchTimerService` and `WatchConnectivityService` are injected into state containers (`AppState`).
* **Testability:** Business logic (timers, card countdowns) is isolated in pure Swift classes, allowing unit tests without UI instantiation (`XCTest`).

---

## 5. SwiftUI structure

- Prefer isolated SwiftUI view widgets in each feature's `Widgets/` directory, with one widget per file.
- Keep screen views focused on composing widgets and passing bindings or callbacks.
- Keep local interaction state and dialogs in the widget that owns them.
- Create a new widget for a new UI section instead of expanding a screen with large computed view properties.
- Use shared tokens from `RugbyTimer/Core/DesignTokens.swift`; do not create feature-specific palettes that duplicate those tokens.

---

## 5. Cross-Device Sync (WatchConnectivity)
* **iPhone -> Watch:** Transmits match configuration (Home Team, Away Team, Match Duration) via `WCSession.sendMessage` when the referee taps *"SEND TO WATCH & PREPARE KICKOFF"*.
* **Watch -> iPhone:** Broadcasts hardware telemetry (Watch Model Name, Battery Level) back to the iPhone setup banner over Bluetooth (BLE).

---

## 6. Testing & Development Guidelines for AI Agents
1. **Never exceed 120 lines per file.** If a file grows too large, refactor by breaking sub-components into separate files inside their respective folders.
2. **Always include `#Preview` blocks** in view files using modern `@Previewable @State` where applicable, or standard mock states.
3. **Target Membership:** Ensure shared models/views (`MatchCard`, `LiveMatchView`, `DesignTokens`, etc.) have their Target Membership checked for **both** `RugbyTimer` (iOS) and `RugbyTimerWatch` (watchOS).
4. **Platform Safety:** Wrap watchOS-specific APIs (`WKInterfaceDevice`) and iOS-specific APIs (`UIImpactFeedbackGenerator`) in conditional compilation blocks (`#if os(watchOS)`, `#if os(iOS)`).
