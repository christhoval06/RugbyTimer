import { Link } from "react-router";
import { useTranslation } from "react-i18next";
import { appIcon } from "../assets/images";
import { CONTACT_ME_EMAIL, DEVELOPER_NAME, DEVELOPER_URL } from "../config";
import { LanguageSwitcher } from "./LanguageSwitcher";

export function Footer() {
  const { t } = useTranslation();
  const year = new Date().getFullYear();
  return (
    <footer className="border-t border-line bg-void-deep">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-12 sm:px-6 md:grid-cols-[1.4fr_1fr_1fr]">
        <div>
          <div className="flex items-center gap-2.5">
            <img src={appIcon} alt="" width={32} height={32} className="size-8 rounded-[8px]" />
            <span className="font-display text-xl font-extrabold uppercase tracking-wide">Rugby Timer</span>
          </div>
          <p className="mt-3 max-w-xs text-sm text-muted">{t("footer.tagline")}</p>
          <LanguageSwitcher placement="up" className="mt-5 inline-block" />
        </div>
        <nav aria-label={t("a11y.footerNav")}>
          <h2 className="font-display text-sm font-bold uppercase tracking-[0.18em] text-emerald">{t("footer.legal")}</h2>
          <ul className="mt-3 space-y-2 text-sm">
            <li><Link to="/privacy" className="text-muted hover:text-ice">{t("nav.privacy")}</Link></li>
            <li><Link to="/terms" className="text-muted hover:text-ice">{t("nav.terms")}</Link></li>
          </ul>
        </nav>
        <div>
          <h2 className="font-display text-sm font-bold uppercase tracking-[0.18em] text-emerald">{t("footer.contact")}</h2>
          <ul className="mt-3 space-y-2 text-sm">
            <li><a href={`mailto:${CONTACT_ME_EMAIL}`} className="text-muted hover:text-ice">{CONTACT_ME_EMAIL}</a></li>
            <li><a href={DEVELOPER_URL} target="_blank" rel="noopener noreferrer" className="text-muted hover:text-ice">christhoval.dev</a></li>
          </ul>
        </div>
      </div>
      <div className="border-t border-line">
        <div className="mx-auto max-w-6xl space-y-1 px-4 py-6 text-xs text-muted sm:px-6">
          <p>© {year} {DEVELOPER_NAME}</p>
          <p>{t("footer.trademarks")}</p>
        </div>
      </div>
    </footer>
  );
}
