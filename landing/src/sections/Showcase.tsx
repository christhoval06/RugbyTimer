import { useTranslation } from "react-i18next";
import { screen } from "../assets/images";
import { PhoneFrame } from "../components/DeviceFrames";
import { Reveal } from "../components/Reveal";

type Row = { eyebrow: string; title: string; body: string; points: string[] };

/** Which real screens illustrate each row, in the order of showcase.items. */
const SCREENS: string[][] = [
  ["lock-screen-live-activity"],
  ["scoreboard"],
  ["record-score", "issue-card"],
  ["match-record"],
];

export function Showcase() {
  const { t, i18n } = useTranslation();
  const lang = i18n.resolvedLanguage ?? "en";
  const rows = t("showcase.items", { returnObjects: true }) as Row[];

  return (
    <section aria-label={t("showcase.label")} className="border-t border-line bg-void-deep">
      <div className="mx-auto max-w-6xl space-y-24 px-4 py-20 sm:px-6 md:space-y-32 md:py-28">
        {rows.map((row, i) => {
          const flip = i % 2 === 1;
          const ids = SCREENS[i] ?? [];
          return (
            <article key={row.title} className="grid items-center gap-12 md:grid-cols-2">
              <Reveal className={flip ? "md:order-2" : ""}>
                <p className="font-display text-sm font-bold uppercase tracking-[0.22em] text-emerald">{row.eyebrow}</p>
                <h3 className="mt-3 font-display text-4xl font-extrabold uppercase leading-[0.95] tracking-tight sm:text-5xl">{row.title}</h3>
                <p className="mt-4 text-lg leading-relaxed text-muted">{row.body}</p>
                <ul className="mt-6 space-y-3">
                  {row.points.map((p) => (
                    <li key={p} className="flex gap-3 text-ice/90">
                      <span aria-hidden="true" className="mt-2 h-0.5 w-4 shrink-0 bg-emerald" />
                      {p}
                    </li>
                  ))}
                </ul>
              </Reveal>
              <Reveal delay={0.1} y={40} className={`flex justify-center gap-5 ${flip ? "md:order-1" : ""}`}>
                {ids.map((id, n) => (
                  <PhoneFrame
                    key={id}
                    screen={screen("phone", id, lang)}
                    className={ids.length > 1 ? `w-[46%] max-w-[250px] ${n === 1 ? "mt-14" : ""}` : "w-[70%] max-w-[320px]"}
                  />
                ))}
              </Reveal>
            </article>
          );
        })}
      </div>
    </section>
  );
}
