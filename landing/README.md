# Rugby Timer landing page

The marketing site for Rugby Timer, to be built with Vite and React, in the app's four languages (English, Spanish, French and Brazilian Portuguese). Only the assets exist so far.

## Assets

`src/assets/` holds unedited screens from the iPhone and Apple Watch apps, plus the app icon and brand colors. Import them from React so Vite fingerprints and optimizes them at build time.

| Folder | Contents | Size |
| --- | --- | --- |
| `phone/` | 8 iPhone 17 Pro Max screens: live clock, Lock Screen Live Activity, scoreboard, score sheet, card sheet, full time, match record, match setup | 1320 × 2868 |
| `watch/` | 3 Apple Watch Series 11 (46mm) screens: match clock, score page, live result with sin-bin | 416 × 496 |
| `brand/` | App icon as SVG and 1024 px PNG (default, dark, tinted), and `tokens.json` with the colors, fonts and radii from [DESIGN.md](../DESIGN.md) | |

`src/assets/manifest.json` lists every image with its size and alt text in `en`, `es`, `fr` and `pt-BR`. Use the size for `width`/`height` attributes so the page doesn't shift while images load, and pick the alt text for the active locale.

The screens use English UI and demo data (Rangers RFC v City Lions). They're shared by every locale until localized captures exist.

## When building the site

- Keep the app's look: the Pitch Void background, emerald for live states, low corner radius, high contrast. See [DESIGN.md](../DESIGN.md).
- Put UI text in locale files, not in components, and keep the alt text in `manifest.json` in step with them.
- Phone screens are large PNGs. Serve them through an image plugin (for example `vite-imagetools`) as WebP or AVIF at the display sizes.
- Link to the App Store listing and to [PRIVACY.md](../PRIVACY.md), published at the privacy policy URL.
