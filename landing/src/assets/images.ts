import manifest from "./manifest.json";
import phoneMatchClock from "./phone/match-clock.png?w=760&format=webp";
import phoneLockScreen from "./phone/lock-screen-live-activity.png?w=760&format=webp";
import phoneScoreboard from "./phone/scoreboard.png?w=760&format=webp";
import phoneRecordScore from "./phone/record-score.png?w=760&format=webp";
import phoneIssueCard from "./phone/issue-card.png?w=760&format=webp";
import phoneFullTime from "./phone/full-time.png?w=760&format=webp";
import phoneMatchRecord from "./phone/match-record.png?w=760&format=webp";
import phoneMatchSetup from "./phone/match-setup.png?w=760&format=webp";
import watchMatchClock from "./watch/match-clock.png?w=416&format=webp";
import watchScore from "./watch/score.png?w=416&format=webp";
import watchResult from "./watch/result-sin-bin.png?w=416&format=webp";
import appIcon from "./brand/app-icon-1024.png?w=256&format=webp";

export { appIcon };

const sources: Record<string, string> = {
  "phone/match-clock": phoneMatchClock,
  "phone/lock-screen-live-activity": phoneLockScreen,
  "phone/scoreboard": phoneScoreboard,
  "phone/record-score": phoneRecordScore,
  "phone/issue-card": phoneIssueCard,
  "phone/full-time": phoneFullTime,
  "phone/match-record": phoneMatchRecord,
  "phone/match-setup": phoneMatchSetup,
  "watch/match-clock": watchMatchClock,
  "watch/score": watchScore,
  "watch/result-sin-bin": watchResult,
};

type Locale = "en" | "es" | "fr" | "pt-BR";
export type Screen = { src: string; alt: string; width: number; height: number };

/** A screen from manifest.json, with its alt text in the page language. */
export function screen(device: "phone" | "watch", id: string, language: string): Screen {
  const entry = manifest[device].find((e) => e.id === id);
  if (!entry) throw new Error(`Unknown screen ${device}/${id}`);
  const locale = (manifest.locales.includes(language) ? language : "en") as Locale;
  return { src: sources[`${device}/${id}`], alt: entry.alt[locale], width: entry.width, height: entry.height };
}
