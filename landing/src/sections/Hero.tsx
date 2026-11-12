import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { screen } from "../assets/images";
import { AppStoreButton } from "../components/AppStoreButton";
import { PhoneFrame, WatchFrame } from "../components/DeviceFrames";

const ease = [0.22, 1, 0.36, 1] as const;

export function Hero() {
  const { t, i18n } = useTranslation();
  const lang = i18n.resolvedLanguage ?? "en";
  const badges = t("hero.badges", { returnObjects: true }) as string[];

  return (
    <section aria-labelledby="hero-title" className="relative overflow-hidden">
      <div aria-hidden="true" className="pitch-lines absolute inset-0 opacity-70" />
      <div aria-hidden="true" className="absolute left-1/2 top-1/3 size-[56rem] -translate-x-1/2 rounded-full bg-emerald/10 blur-3xl" />
      <div className="relative mx-auto grid max-w-6xl items-center gap-12 px-4 pb-20 pt-14 sm:px-6 md:pt-20 lg:grid-cols-[1.05fr_1fr]">
        <motion.div initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7, ease }}>
          <p className="inline-flex items-center gap-2 rounded-control border border-emerald/30 bg-emerald/10 px-3 py-1 font-display text-sm font-bold uppercase tracking-[0.2em] text-emerald">
            <span className="size-2 animate-pulse rounded-full bg-emerald" />
            {t("hero.eyebrow")}
          </p>
          <h1 id="hero-title" className="mt-5 font-display text-5xl font-extrabold uppercase leading-[0.9] tracking-tight sm:text-7xl">
            {t("hero.title")}
          </h1>
          <p className="mt-6 max-w-xl text-lg leading-relaxed text-muted sm:text-xl">{t("hero.subtitle")}</p>
          <div className="mt-8 flex flex-wrap items-center gap-4">
            <AppStoreButton size="lg" />
            <a href="#features" className="rounded-control border border-line-strong px-6 py-4 font-display text-xl font-bold uppercase tracking-wide text-ice transition hover:border-emerald hover:text-emerald">
              {t("cta.howItWorks")}
            </a>
          </div>
          <ul className="mt-8 flex flex-wrap gap-x-6 gap-y-2 text-sm text-muted">
            {badges.map((b) => (
              <li key={b} className="flex items-center gap-2">
                <svg aria-hidden="true" viewBox="0 0 16 16" className="size-4 text-emerald" fill="none" stroke="currentColor" strokeWidth="2.4">
                  <path d="m3 8.5 3 3 7-7" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                {b}
              </li>
            ))}
          </ul>
        </motion.div>

        <div className="relative mx-auto w-full max-w-md lg:max-w-none">
          <motion.div
            initial={{ opacity: 0, y: 40, rotate: -2 }}
            animate={{ opacity: 1, y: 0, rotate: 0 }}
            transition={{ duration: 0.9, delay: 0.15, ease }}
            className="mx-auto w-[68%] max-w-[330px] lg:ml-6"
          >
            <PhoneFrame screen={screen("phone", "match-clock", lang)} priority />
          </motion.div>
          <motion.div
            initial={{ opacity: 0, x: 40, y: 20 }}
            animate={{ opacity: 1, x: 0, y: [0, -10, 0] }}
            transition={{ opacity: { duration: 0.8, delay: 0.45 }, x: { duration: 0.8, delay: 0.45, ease }, y: { duration: 6, delay: 1.2, repeat: Infinity, ease: "easeInOut" } }}
            className="absolute -bottom-6 right-0 w-[42%] max-w-[210px] sm:right-4"
          >
            <WatchFrame screen={screen("watch", "match-clock", lang)} />
          </motion.div>
        </div>
      </div>
    </section>
  );
}
