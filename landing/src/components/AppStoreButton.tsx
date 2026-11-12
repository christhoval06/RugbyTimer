import { useTranslation } from "react-i18next";
import { APPSTORE_URL } from "../config";

type Props = { size?: "md" | "lg"; className?: string };

/**
 * Link to the App Store listing. Text only: Apple's own "Download on the App Store" badge
 * can replace it (download it from Apple's marketing tools; don't redraw the Apple logo).
 */
export function AppStoreButton({ size = "md", className = "" }: Props) {
  const { t } = useTranslation();
  const sizing = size === "lg" ? "px-7 py-4 text-xl" : "px-5 py-2.5 text-base";
  return (
    <a
      href={APPSTORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className={`inline-flex items-center gap-3 rounded-control bg-emerald font-display font-extrabold uppercase tracking-wide text-void transition hover:bg-emerald/90 active:translate-y-px ${sizing} ${className}`}
    >
      <svg aria-hidden="true" viewBox="0 0 24 24" className="size-[1.1em]" fill="none" stroke="currentColor" strokeWidth="2.5">
        <path d="M12 4v11m0 0-4.5-4.5M12 15l4.5-4.5M5 20h14" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
      {t("cta.download")}
    </a>
  );
}
