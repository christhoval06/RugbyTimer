import { useTranslation } from "react-i18next";
import { Reveal } from "../components/Reveal";
import { SectionHeading } from "../components/SectionHeading";

/** Native <details> accordion: keyboard and screen-reader friendly, no script needed. */
export function Faq() {
  const { t } = useTranslation();
  const items = t("faq.items", { returnObjects: true }) as { q: string; a: string }[];
  return (
    <section id="faq" aria-labelledby="faq-title" className="scroll-mt-20 border-t border-line bg-void-deep">
      <div className="mx-auto max-w-3xl px-4 py-20 sm:px-6 md:py-28">
        <SectionHeading id="faq-title" eyebrow={t("faq.eyebrow")} title={t("faq.title")} align="center" />
        <div className="mt-12 divide-y divide-line rounded-control border border-line">
          {items.map((item, i) => (
            <Reveal key={item.q} delay={i * 0.04} y={12}>
              <details className="group px-6 py-5 open:bg-surface/40">
                <summary className="flex cursor-pointer list-none items-center justify-between gap-6 font-display text-xl font-bold uppercase tracking-wide [&::-webkit-details-marker]:hidden">
                  {item.q}
                  <span aria-hidden="true" className="text-2xl text-emerald transition group-open:rotate-45">+</span>
                </summary>
                <p className="mt-3 leading-relaxed text-muted">{item.a}</p>
              </details>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
