import { useTranslation } from "react-i18next";
import { Reveal } from "../components/Reveal";
import { SectionHeading } from "../components/SectionHeading";

/** "Works your way": the smaller features, as a compact two-column list. */
export function MoreFeatures() {
  const { t } = useTranslation();
  const items = t("more.items", { returnObjects: true }) as { title: string; body: string }[];
  return (
    <section aria-labelledby="more-title" className="border-t border-line bg-void-deep">
      <div className="mx-auto grid max-w-6xl gap-12 px-4 py-20 sm:px-6 md:py-28 lg:grid-cols-[1fr_1.4fr]">
        <SectionHeading id="more-title" eyebrow={t("more.eyebrow")} title={t("more.title")}>
          {t("more.intro")}
        </SectionHeading>
        <dl className="grid gap-x-10 gap-y-8 sm:grid-cols-2">
          {items.map((item, i) => (
            <Reveal key={item.title} delay={(i % 2) * 0.08} className="border-l-2 border-emerald/60 pl-5">
              <dt className="font-display text-xl font-bold uppercase tracking-wide">{item.title}</dt>
              <dd className="mt-1.5 leading-relaxed text-muted">{item.body}</dd>
            </Reveal>
          ))}
        </dl>
      </div>
    </section>
  );
}
