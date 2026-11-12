import type { ComponentPropsWithoutRef } from "react";
import { Link } from "react-router";
import Markdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { useTranslation } from "react-i18next";

/** Renders a policy written in Markdown (PRIVACY.md, TERMS.md) in the site's style. */
export function LegalDocument({ source }: { source: string }) {
  const { t, i18n } = useTranslation();
  const isEnglish = (i18n.resolvedLanguage ?? "en") === "en";

  return (
    <article className="mx-auto max-w-3xl px-4 py-14 sm:px-6 md:py-20">
      {!isEnglish && (
        <p className="mb-10 rounded-control border border-amber/40 bg-amber/10 px-5 py-4 text-sm text-ice">{t("legal.englishOnly")}</p>
      )}
      {/* The policies are written in English; screen readers should read them as English. */}
      <div lang="en">
        <Markdown remarkPlugins={[remarkGfm]} components={components}>
          {source}
        </Markdown>
      </div>
      <Link to="/" className="mt-14 inline-flex items-center gap-2 font-display text-lg font-bold uppercase tracking-wide text-emerald hover:text-ice">
        <span aria-hidden="true">←</span>
        {t("legal.backHome")}
      </Link>
    </article>
  );
}

const components = {
  h1: (p: ComponentPropsWithoutRef<"h1">) => (
    <h1 className="font-display text-5xl font-extrabold uppercase leading-[0.95] tracking-tight sm:text-6xl" {...p} />
  ),
  h2: (p: ComponentPropsWithoutRef<"h2">) => (
    <h2 className="mt-12 border-t border-line pt-8 font-display text-2xl font-bold uppercase tracking-wide text-ice" {...p} />
  ),
  p: (p: ComponentPropsWithoutRef<"p">) => <p className="mt-4 leading-relaxed text-ice/80" {...p} />,
  ul: (p: ComponentPropsWithoutRef<"ul">) => <ul className="mt-4 space-y-3" {...p} />,
  li: (p: ComponentPropsWithoutRef<"li">) => (
    <li className="relative pl-6 leading-relaxed text-ice/80 before:absolute before:left-0 before:top-3 before:h-0.5 before:w-3 before:bg-emerald" {...p} />
  ),
  strong: (p: ComponentPropsWithoutRef<"strong">) => <strong className="font-bold text-ice" {...p} />,
  a: ({ href = "", ...p }: ComponentPropsWithoutRef<"a">) =>
    href.startsWith("/") ? (
      <Link to={href} className="text-emerald underline underline-offset-4 hover:text-ice" {...p} />
    ) : (
      <a href={href} className="text-emerald underline underline-offset-4 hover:text-ice" {...(href.startsWith("http") ? { target: "_blank", rel: "noopener noreferrer" } : {})} {...p} />
    ),
  table: (p: ComponentPropsWithoutRef<"table">) => (
    <div className="mt-6 overflow-x-auto rounded-control border border-line">
      <table className="w-full min-w-[40rem] border-collapse text-left text-sm" {...p} />
    </div>
  ),
  th: (p: ComponentPropsWithoutRef<"th">) => (
    <th className="border-b border-line bg-surface px-4 py-3 font-display text-base font-bold uppercase tracking-wide" {...p} />
  ),
  td: (p: ComponentPropsWithoutRef<"td">) => <td className="border-b border-line px-4 py-3 align-top leading-relaxed text-ice/80" {...p} />,
};
