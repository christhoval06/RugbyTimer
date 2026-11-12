import { useTranslation } from "react-i18next";
import { screen } from "../assets/images";
import { WatchFrame } from "../components/DeviceFrames";
import { Reveal } from "../components/Reveal";
import { SectionHeading } from "../components/SectionHeading";

const WATCH_SCREENS = ["match-clock", "score", "result-sin-bin"];

export function WatchSection() {
  const { t, i18n } = useTranslation();
  const lang = i18n.resolvedLanguage ?? "en";
  const points = t("watch.points", { returnObjects: true }) as { title: string; body: string }[];

  return (
    <section id="watch" aria-labelledby="watch-title" className="relative scroll-mt-20 overflow-hidden border-t border-line">
      <div aria-hidden="true" className="absolute inset-x-0 top-24 mx-auto h-80 max-w-3xl rounded-full bg-emerald/10 blur-3xl" />
      <div className="relative mx-auto max-w-6xl px-4 py-20 sm:px-6 md:py-28">
        <SectionHeading id="watch-title" eyebrow={t("watch.eyebrow")} title={t("watch.title")} align="center">
          {t("watch.body")}
        </SectionHeading>
        <div className="mx-auto mt-14 grid max-w-4xl grid-cols-3 items-end gap-4 sm:gap-8">
          {WATCH_SCREENS.map((id, i) => (
            <Reveal key={id} delay={i * 0.12} y={30} className={i === 1 ? "sm:-translate-y-6" : ""}>
              <WatchFrame screen={screen("watch", id, lang)} />
            </Reveal>
          ))}
        </div>
        <ul className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {points.map((p, i) => (
            <li key={p.title}>
              <Reveal delay={i * 0.06} className="h-full rounded-control border border-line bg-surface/60 p-6">
                <h3 className="font-display text-xl font-bold uppercase tracking-wide">{p.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">{p.body}</p>
              </Reveal>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
