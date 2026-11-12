# Device Testing

A checklist for a real iPhone and Apple Watch, for the things the simulator can't prove: signing, the widgets and complication, the Live Activity, Health workouts and alerts with your wrist down.

Run it at a training session or a friendly match, or walk through it at home with the timings shortened (a 7-minute half and a 2-minute sin-bin). Tick each box, and note the device, iOS and watchOS versions, and anything that failed.

| | |
| --- | --- |
| iPhone / iOS | |
| Apple Watch / watchOS | |
| Build | |
| Date | |

## 0. Before you start

- [ ] Install a Debug or TestFlight build on the iPhone. The Watch app installs with it.
- [ ] Both apps open without crashing.
- [ ] In Settings › Rugby Timer on the iPhone, Live Activities are allowed.
- [ ] Add the **Match** widget to the Home Screen (small and medium) and to the Lock Screen (round and rectangular).
- [ ] Add the Rugby Timer complication to a watch face, in each size the face offers (circular, rectangular, corner, inline).
- [ ] With no match played yet, the widgets and complication show "NO MATCHES YET" or the app name, not blank space or placeholder text.

## 1. App Group signing (widgets get data)

If this section fails, check that the App Group `group.dev.christhoval.apps.RugbyTimer` is on all four App IDs (iPhone app, Live Activity extension, Watch app, complication extension) in the developer portal.

- [ ] Set up a match on the iPhone. The Home Screen widget switches to the match within a few seconds.
- [ ] Run a match on the Watch. The complication shows the clock and score, not "RUGBY TIMER".

## 2. Live Activity (iPhone)

Match run on the iPhone (RUN MATCH ON IPHONE):

- [ ] The Live Activity appears on the Lock Screen when the match is set up (READY, 0–0), before kick-off.
- [ ] After kick-off, lock the phone. The clock counts down on the Lock Screen without the app open.
- [ ] Dynamic Island (iPhone 14 Pro or later): the compact clock shows, and a long press opens the expanded view.
- [ ] A score and a yellow card show within a few seconds. The sin-bin countdown appears.
- [ ] At half-time it shows the break, and the second half's clock after kick-off.
- [ ] At full time it shows the final score (FT) and disappears after about 30 minutes.
- [ ] Turn off Settings › Live Activity in the app during a match. The Live Activity goes at once, and doesn't come back for the next match until the setting is turned on again.

Match run on the Watch (SEND SETUP TO WATCH):

- [ ] The Live Activity starts on the iPhone when the setup is sent.
- [ ] With the iPhone locked in a pocket, kick off on the Watch. The Lock Screen clock starts running.
- [ ] Scores and cards entered on the Watch reach the Live Activity.

## 3. Match widget (iPhone)

- [ ] During a match: the small and medium widgets show the period, clock, teams and score. The clock keeps counting with the app closed.
- [ ] With a player in the sin-bin, the medium widget shows the sin-bin row.
- [ ] After full time: the widgets show "LAST MATCH", the date and the final score, with the winner highlighted.
- [ ] Lock Screen widgets: the round and rectangular sizes show the live clock during a match and "LAST MATCH" with the score afterwards. The inline one above the clock shows a short line.
- [ ] Change the app language in Settings. The widget labels and date follow it.
- [ ] Close the app mid-match and leave it closed. After about 4 hours the widget gives up the live match and shows the last result.

## 4. Watch complication

- [ ] During a match: the clock counts on the watch face, and the score updates after each score.
- [ ] Sin-bin: the rectangular complication shows the player and the time left.
- [ ] Half-time and full time show on the complication.
- [ ] Tapping the complication opens the app on the match.

## 5. Health workout (Watch)

- [ ] On the ready screen before kick-off, the Watch asks for Health access once. Allow it.
- [ ] The match runs as a Rugby workout: the workout indicator shows during play.
- [ ] At full time the workout is saved. In the Fitness or Health app on the iPhone it shows as Rugby with duration, distance, heart rate and active energy.
- [ ] Delete and reinstall the app, then decline Health access. The match still runs (extended runtime session), and the alerts below still fire during each half and the break.

## 6. Alerts with your wrist down (Watch)

Lower your wrist or cover the screen so it goes dark, and wait for each one:

- [ ] End of each half: haptic and alert.
- [ ] End of the half-time break: alert.
- [ ] Sin-bin ending: alert naming the player.
- [ ] HIA (12 min) or blood (15 min) timer ending: alert.
- [ ] Notifications from Rugby Timer are allowed on the Watch (Watch app on the iPhone › Notifications) and arrive without opening the app.

## 7. Quick Match on the Watch alone

- [ ] Leave the iPhone behind, or turn on Airplane Mode on the iPhone. Start a QUICK MATCH on the Watch and play it to full time.
- [ ] Bring the iPhone back in range. The match appears in Match History on the iPhone, once, with the right score and record.

## 8. Crash recovery

- [ ] Mid-match on the Watch, force-quit the app (hold the side button, then swipe). Reopen it: the same match, clock, score and sin-bins are there.
- [ ] Do the same on the iPhone in iPhone-only mode.

## 9. Outdoors

- [ ] In direct sunlight the clock, score and sin-bin times are readable on the Watch and the iPhone.
- [ ] Buttons work with wet fingers or gloves. The tap lock stops a sleeve from scoring.

## 10. App Store Connect upload

- [ ] Archive the app (Product › Archive) and upload it from the Organizer to TestFlight.
- [ ] The upload passes validation with no warnings about missing privacy files (`PrivacyInfo.xcprivacy`) or reasons for `UserDefaults`.
- [ ] The TestFlight build installs on both devices and passes sections 1 to 4 again.

## Results

| Section | Pass / fail | Notes |
| --- | --- | --- |
| 0. Before you start | | |
| 1. App Group signing | | |
| 2. Live Activity | | |
| 3. Match widget | | |
| 4. Watch complication | | |
| 5. Health workout | | |
| 6. Alerts | | |
| 7. Quick Match | | |
| 8. Crash recovery | | |
| 9. Outdoors | | |
| 10. Upload | | |
