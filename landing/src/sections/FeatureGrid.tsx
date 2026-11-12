import { useTranslation } from "react-i18next";
import { Reveal } from "../components/Reveal";
import { SectionHeading } from "../components/SectionHeading";
import { FeatureIcon } from "./FeatureIcon";

type Feature = { icon: string; title: string; body: string };

export function FeatureGrid() {
  const { t } = useTranslation();
  const items = t("features.items", { returnObjects: true }) as Feature[];
  return (
    <section id="features" aria-labelledby="features-title" className="scroll-mt-20 border-t border-line">
      <div className="mx-auto max-w-6xl px-4 py-20 sm:px-6 md:py-28">
        <SectionHeading id="features-title" eyebrow={t("features.eyebrow")} title={t("features.title")}>
          {t("features.intro")}
        </SectionHeading>
        <ul className="mt-12 grid gap-px overflow-hidden rounded-control border border-line bg-line sm:grid-cols-2 lg:grid-cols-3">
          {items.map((item, i) => (
            <li key={item.title} className="bg-void">
              <Reveal delay={(i % 3) * 0.08} className="h-full p-7 transition hover:bg-surface/60">
                <FeatureIcon name={item.icon} />
                <h3 className="mt-5 font-display text-2xl font-bold uppercase tracking-wide">{item.title}</h3>
                <p className="mt-2 leading-relaxed text-muted">{item.body}</p>
              </Reveal>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
