import { Link } from "react-router";
import { useTranslation } from "react-i18next";
import { Reveal } from "../components/Reveal";

export function PrivacyBand() {
  const { t } = useTranslation();
  const points = t("privacy.points", { returnObjects: true }) as string[];
  return (
    <section aria-labelledby="privacy-title" className="border-t border-line">
      <div className="mx-auto max-w-6xl px-4 py-20 sm:px-6 md:py-24">
        <Reveal className="grid items-center gap-10 rounded-control border border-line bg-surface/50 p-8 sm:p-12 lg:grid-cols-[1.2fr_1fr]">
          <div>
            <p className="font-display text-sm font-bold uppercase tracking-[0.22em] text-emerald">{t("privacy.eyebrow")}</p>
            <h2 id="privacy-title" className="mt-3 font-display text-4xl font-extrabold uppercase leading-[0.95] tracking-tight sm:text-5xl">
              {t("privacy.title")}
            </h2>
            <p className="mt-4 text-lg leading-relaxed text-muted">{t("privacy.body")}</p>
            <Link to="/privacy" className="mt-6 inline-flex items-center gap-2 font-display text-lg font-bold uppercase tracking-wide text-emerald hover:text-ice">
              {t("privacy.link")}
              <span aria-hidden="true">→</span>
            </Link>
          </div>
          <ul className="grid gap-3">
            {points.map((p) => (
              <li key={p} className="flex items-center gap-4 rounded-control border border-line bg-void px-5 py-4">
                <span aria-hidden="true" className="flex size-8 shrink-0 items-center justify-center rounded-full bg-emerald/15 text-emerald">✕</span>
                <span className="font-display text-xl font-bold uppercase tracking-wide">{p}</span>
              </li>
            ))}
          </ul>
        </Reveal>
      </div>
    </section>
  );
}
