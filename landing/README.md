# Rugby Timer landing page

The marketing site for Rugby Timer, in the app's four languages: English, Spanish, French and Brazilian Portuguese.

Built with Vite, React, TypeScript, Tailwind CSS 4, Framer Motion, React Router (every page is a lazy route) and i18next.

## Run it

```bash
npm install
npm run dev        # http://localhost:5173
npm run build      # type-checks, then builds to dist/
npm run preview    # serves dist/ locally
npm test           # unit tests (Vitest), once
npm run test:watch # unit tests, re-run on change
```

## Tests

Vitest with jsdom and Testing Library, configured in `vitest.config.ts` on top of the site's own Vite config (so image imports and `?raw` Markdown work in tests too). `src/test/setup.ts` stubs the browser APIs jsdom lacks and resets the language to English before each test.

| File | Covers |
| --- | --- |
| `src/i18n/locales.test.ts` | All four locale files have the same keys and list lengths, no empty strings, matching `{{placeholders}}` |
| `src/i18n/i18n.test.ts` | Each language resolves to itself; regional codes map (es-MX → es, pt-PT → pt-BR); other languages fall back to English |
| `src/assets/images.test.ts` | Every screen in `manifest.json` resolves to an image with alt text in each language |
| `src/components/AppStoreButton.test.tsx` | Link target, new-tab safety, translation |
| `src/components/LanguageSwitcher.test.tsx` | Menu opens, mouse and keyboard selection, Escape and outside-click closing, focus return |
| `src/router.test.tsx` | Every route renders (home sections and price, privacy, terms, 404), page titles, the English-only notice |
| `src/test/manifest.test.ts` | The web app manifest is linked, complete, and its icons exist at their stated sizes |

## Web app manifest

`public/manifest.webmanifest` names the site, sets the Pitch Void theme color, lists 192 px, 512 px and maskable 512 px icons, and points to the App Store listing (`related_applications`) so browsers know the native app exists.

## Pages

| Path | Page | Source |
| --- | --- | --- |
| `/` | Home: hero, features, showcase, Apple Watch, more features, privacy, FAQ, download | `src/pages/HomePage.tsx`, `src/sections/` |
| `/privacy` | Privacy Policy | Renders [`../PRIVACY.md`](../PRIVACY.md), the same file the app links to |
| `/terms` | Terms & Conditions | Renders [`../TERMS.md`](../TERMS.md) |
| anything else | 404 | `src/pages/NotFoundPage.tsx` |

The policies are written in English. In other languages the page shows a short note saying so.

## Structure

```
src/
├── config.ts            APPSTORE_URL, CONTACT_ME_EMAIL and other links
├── router.tsx           Routes, each loaded lazily
├── i18n/                i18next setup and locales/{en,es,fr,pt-BR}.json
├── components/          Layout, header, footer, buttons, device frames, Reveal (scroll animation)
├── sections/            The home page sections, one per file
├── pages/               One file per route
└── assets/              App screens, icons, brand tokens and manifest.json (sizes, alt text per language)
```

- **Text:** all UI text lives in `src/i18n/locales/*.json`. Add every new key to all four files; the files must keep the same keys and list lengths.
- **Images:** screens are imported through `vite-imagetools` (`?w=760&format=webp`), so the build ships small WebP files. Alt text comes from `src/assets/manifest.json` in the page language.
- **Look:** colors and fonts are the app's tokens from [DESIGN.md](../DESIGN.md), defined in `src/styles.css`. Fonts are self-hosted, so the site makes no third-party requests.
- **Motion:** Framer Motion follows the visitor's "reduce motion" setting (`MotionConfig reducedMotion="user"`).

## Deploying

`npm run build` writes a static site to `dist/`. It uses browser routing, so the host must serve `index.html` for unknown paths (for example `/privacy` on a fresh load):

- **Netlify:** already set up in [`netlify.toml`](netlify.toml): build command, `dist` output, Node 24, the `/*` → `/index.html` rewrite, long caching for `/assets/*` and basic security headers. In the Netlify UI set **Base directory** to `landing`; the file supplies the rest.
- **Vercel:** add a rewrite from `/(.*)` to `/index.html` in `vercel.json`.
- **Cloudflare Pages / GitHub Pages:** use a `404.html` copy of `index.html`, or the host's single-page app setting.

The App Store button is a text link. Apple's official "Download on the App Store" badge can replace it: download it from Apple's marketing tools and don't redraw the Apple logo.
