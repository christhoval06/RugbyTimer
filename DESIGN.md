# RugbyTimer - Design System & UI/UX Specification

## 1. Brand & Aesthetic Philosophy
The **Pitch Official System** is an uncompromising, mission-critical digital operating environment built specifically for rugby match officials, touch judges, television match officials (TMO), and wearers of high-stress wrist-mounted wearables. 

Operating on a rugby pitch requires split-second cognition under intense physical exertion, adverse weather conditions (blinding direct sunlight, torrential rain, artificial stadium floodlights), and immense match pressure. The aesthetic fuses **athletic brutalism** with **precision avionics instrumentation**: deep tactical charcoal foundations, high-luminance field markings, razor-sharp status indicators, and massive tactile touch targets. 

The interface eliminates ambiguity entirely—every micro-interaction delivers decisive visual and haptic feedback, ensuring officials spend zero mental bandwidth decoding the screen and 100% managing the match.

---

## 2. Color Palette & Tokens
Engineered for maximum outdoor luminance and instant visual recognition across peripheral vision:

* **Pitch Void (`#0B0E14` / `#05070A`):** The non-negotiable canvas base. An ultra-deep pitch charcoal/black that preserves OLED efficiency and prevents retinal blow-out during night fixtures under stadium lights.
* **Match Pitch Emerald (`#10B981`):** Primary operating indicator. Represents live clock status, advantage play, successful kicks, and confirmed decisions. Pierces through glare with vibrant energy.
* **Sin-Bin Amber (`#F59E0B`):** Warning states, active card countdowns, injury clock holds, and substitution reviews.
* **Card Yellow (`#FACC15`):** Pure regulatory yellow card status and formal official cautions.
* **Expulsion Red (`#EF4444`):** Red cards, violent conduct flags, TMO overturn alerts, and emergency medical halts.
* **Ice Titanium White (`#F9FAFB`):** Maximum-contrast typography for athletic numbers, game time, score tallies, and critical alerts.
* **Titanium Armor Border (`#1F2937` / `#374151`):** Distinct structural boundaries that maintain container separation even on low-tier sunlight-readable transflective screens.
* **Outline / Muted (`#86948A`):** Secondary structural labeling, law book references, and inactive timestamps.

---

## 3. Typography Engine
The typography pairs industrial precision with unambiguous legibility:
* **Barlow Condensed:** Used for all critical numeric outputs, timers, score lines, and high-urgency callouts. Its industrial, condensed proportions allow large-scale numerals to fit within narrow watch faces and split mobile panes without horizontal truncation. All numerical counters enforce tabular lining figures (`tabular-nums`) to prevent layout jitter as the clock ticks.
* **Atkinson Hyperlegible Next:** Used for body copy, rule lookups, disciplinary logs, and incident descriptions. Provides rapid legibility, explicitly differentiating ambiguous letterforms (`1`, `I`, `l` and `0`, `O`) to prevent misidentifying jersey numbers or infraction codes during mid-play operations.

---

## 4. Layout, Spacing & Elevation
* **Smartwatch Viewport (38mm - 49mm):** Single-column stacked HUD. Full bleed with an 8px safe rim margin to prevent edge touch distortion from sweat and rain. Compact spacing (`space-xs` to `space-sm`) prioritizes massive tactile buttons and clock readouts.
* **Sideline Terminal (Mobile):** Split-zone thumb reachability: scoreboards and match timers reside in the top cognitive display zone, while interactive officiating buttons (Try, Penalty, Card, Whistle) dominate the bottom 60% ergonomic thumb sweep zone.
* **Tactical High-Contrast Layering:** In harsh direct sunlight, conventional soft blur shadows wash out completely. Depth is established through hard 1.5px solid borders (`#1F2937`) and solid container fills (`#1D2026`) rather than drop shadows.

---

## 5. Shape & Component Constraints
* **Low-Radius Brutalism:** Radii are strictly controlled at `4px` (`0.25rem`) for compact tags and input containers, `8px` (`0.5rem`) for score tiles and cards, and `12px` (`0.75rem`) for dominant primary match action buttons. 
* **Prohibition of Pill Shapes:** Excessively rounded or pill-shaped containers are prohibited for primary controls, as they reduce clickable surface area in corner touch zones—an unacceptable liability when operating hardware with sweaty, rain-slicked hands or referee gloves.
* **Minimum Touch Targets:** Minimum height of 56px on mobile, expanding to 36px–68px on watch interfaces with high-contrast uppercase labels.
