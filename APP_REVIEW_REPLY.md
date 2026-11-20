# App Review reply: Guideline 2.1 (Information Needed)

Two things to paste into App Store Connect:

1. **Reply**: the full answer in the Resolution Center thread, with the screen recording attached.
2. **Notes**: the short version for App Review Information › Notes (limit 4000 characters). This replaces the current notes.

---

## Screen recording: what to film

Film on a real iPhone running the latest iOS, and the Apple Watch if you have one, using the iPhone's Screen Recording in Control Center. For the Watch, film it with a second phone, or record the iPhone-only flow and then a short Watch clip. The recording must **start from the Home Screen with the app launching**. Keep it to about 2 to 3 minutes.

1. Home Screen → tap Rugby Timer → splash → onboarding (swipe through or skip).
2. Match Setup: type two team names, set the half length (pick 7 min so it's quick), turn on the 20-minute red card.
3. Tap **RUN MATCH ON IPHONE** → kick off.
4. Add a try and a conversion for one team, a penalty goal for the other.
5. Give a yellow card to a shirt number. Show the sin-bin countdown.
6. Tap PEN / FK once. Record a substitution. Start an HIA injury timer.
7. Lock the phone: show the Live Activity on the Lock Screen. Unlock.
8. End the first half → half-time stats → start the second half → end the match.
9. Full-time summary → share the match record (open the share sheet, then cancel).
10. Back on Match Setup → Match History → open the match → Settings (show Language and Live Activity toggles).
11. (Watch) On iPhone tap **SEND SETUP TO WATCH**, show the match arriving on the Watch, kick off, add a score. Show **QUICK MATCH** on the Watch.

Nothing to show for accounts, user-generated content or paid content: the app has none (it's a paid-up-front app with no in-app purchases).

---

## 1. Reply (Resolution Center)

```text
Hello,

Thank you for reviewing Rugby Timer. Here is the information requested. We've also added it to the Notes field of App Review Information.

1. SCREEN RECORDING
Attached is a recording on a physical iPhone 13 Pro (iOS 27.3) paired with an Apple Watch Series 7 (watchOS 26.6). watchOS has no built-in screen recording, so we filmed both devices together with a second device's camera, showing them working together in real time as a referee uses them.
It starts with launching the app and shows the typical flow: setting up a match on the iPhone, sending it to the Watch, and running it on the Watch (kick-off, scores, a yellow-card sin-bin countdown, half-time and full time), with the iPhone following the match. It ends with the match record and match history on the iPhone.
The app has no account registration or login, no user-generated content and no in-app purchases, so none of these appear.

2. PURPOSE AND TARGET AUDIENCE
Rugby Timer is a match clock for rugby union referees, from school and club matches to sevens tournaments. A referee must keep the game clock, time every sin-bin, track the score and note every card while watching play, usually with a stopwatch and a notebook.
Rugby Timer keeps the clock, sin-bin countdowns, score and disciplinary record on the referee's Apple Watch (or iPhone if no Watch is paired). It alerts the referee when a half, the half-time break or a sin-bin ends, and at full time produces a match record (every score, card, substitution and injury, with match times) to share with teams or their referees' society.

3. HOW TO USE THE MAIN FEATURES
No login, credentials or sample files are needed. All features work as soon as the app opens.
- iPhone only: complete or skip onboarding. On Match Setup enter the teams and half length, tap RUN MATCH ON IPHONE (RUN ON THIS IPHONE INSTEAD when a Watch is paired), kick off, add scores and cards, and end each half.
- With Apple Watch: open the Watch app, then on iPhone tap SEND SETUP TO WATCH. The match appears on the Watch, ready to kick off. To use the Watch alone, tap QUICK MATCH on the Watch.
- Match history: tap Match History on Match Setup.
- Live Activity: start a match on iPhone and lock the phone.
- Health (Watch, optional): the Watch asks for Health access before kick-off, to run the match as a Rugby workout. If declined, it uses an extended runtime session instead.

4. EXTERNAL SERVICES
None. No servers, data providers, authentication, payment, analytics, advertising or AI services. The app only uses on-device Apple frameworks: WatchConnectivity, HealthKit (optional), ActivityKit, WidgetKit, SwiftData and local notifications. All data stays on the user's devices.

5. REGIONAL DIFFERENCES
None. The app works the same in all regions. It's localized in English, Spanish, French and Brazilian Portuguese.

6. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
Not applicable. The app isn't in a regulated industry and contains no protected third-party material. It uses no logos, names or content of World Rugby or any union or competition, and isn't affiliated with them.

Thank you,
Christhoval Barba
```

---

## 2. Notes field (App Review Information)

```text
Rugby Timer is a match clock for rugby union referees. It keeps the game clock, sin-bin countdowns, score and disciplinary record on Apple Watch (or iPhone if no Watch is paired), and produces a shareable match record at full time.

NO ACCOUNT, NO LOGIN, NO IN-APP PURCHASES, NO USER-GENERATED CONTENT. Paid up front. All features work as soon as the app opens.

EXTERNAL SERVICES: none. No servers, analytics, ads, payment or AI services. Only on-device Apple frameworks: WatchConnectivity, HealthKit (optional, Watch), ActivityKit/WidgetKit, SwiftData, local notifications. Data stays on the user's devices.

REGIONS: works the same in all regions. Localized in English, Spanish, French and Brazilian Portuguese.

REGULATED / THIRD-PARTY MATERIAL: not applicable. Not affiliated with World Rugby or any union; uses no third-party logos or content.

HOW TO TEST
iPhone only: complete or skip onboarding. On Match Setup set the teams and half length, tap RUN MATCH ON IPHONE (or RUN ON THIS IPHONE INSTEAD when a Watch is paired). Kick off, add a score or a yellow card, end the half.

With Apple Watch: open the Watch app, then on iPhone tap SEND SETUP TO WATCH. The match appears on the Watch, ready to kick off. To test the Watch alone, tap QUICK MATCH on the Watch main screen.

Undo: record a score or card, then tap UNDO LAST ENTRY within 15 seconds.

Injury timers (iPhone): during play tap INJURY, pick a team and number, then HIA · 12 MIN. Tap the player in the sanctions list to close it as back on or replaced.

Penalty count: tap PEN or FK for a team (Watch: swipe right from the clock; iPhone: under SANCTIONS). Totals show in the stats and match record.

Match history: finish a match, go back to Match Setup and tap Match History. Tap a match to open its record; swipe left to delete.

Extra time: set Extra time to Fifteens, run on iPhone, end both halves level. Kick off ET1 or end as a draw.

20-minute red: turn it on in Match Setup, then issue a RED 20' card.

Substitutions: turn on Substitutions in Match Setup, tap SUBSTITUTION, pick off and on, confirm.

Live Activity and widgets: start a match on iPhone and lock the phone. Add the "Match" widget to the Home or Lock Screen. On Apple Watch, add the Rugby Timer complication.

HealthKit (Apple Watch): the Watch asks for Health access once before kick-off. With access, each match runs as an HKWorkoutSession (Rugby), which keeps the clock and alerts accurate with the wrist down, and saves the workout to Health. It reads heart rate, distance and active energy only for that workout. If declined, the Watch uses an extended runtime session instead.
```
