import type { ReactNode } from "react";
import { Reveal } from "./Reveal";

type Props = { eyebrow: string; title: string; children?: ReactNode; align?: "left" | "center"; id?: string };

/** Section intro in the app's style: emerald eyebrow, condensed uppercase title, plain body. */
export function SectionHeading({ eyebrow, title, children, align = "left", id }: Props) {
  const centered = align === "center" ? "mx-auto text-center" : "";
  return (
    <Reveal className={`max-w-2xl ${centered}`}>
      <p className="font-display text-sm font-bold uppercase tracking-[0.22em] text-emerald">{eyebrow}</p>
      <h2 id={id} className="mt-3 font-display text-4xl font-extrabold uppercase leading-[0.95] tracking-tight sm:text-5xl">
        {title}
      </h2>
      {children && <div className="mt-4 text-lg leading-relaxed text-muted">{children}</div>}
    </Reveal>
  );
}
