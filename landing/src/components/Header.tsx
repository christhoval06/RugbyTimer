import { Link } from "react-router";
import { useTranslation } from "react-i18next";
import { appIcon } from "../assets/images";
import { AppStoreButton } from "./AppStoreButton";
import { LanguageSwitcher } from "./LanguageSwitcher";

const NAV = [
  { to: "/#features", key: "nav.features" },
  { to: "/#watch", key: "nav.watch" },
  { to: "/#faq", key: "nav.faq" },
] as const;

export function Header() {
  const { t } = useTranslation();
  return (
    <header className="sticky top-0 z-40 border-b border-line/70 bg-void/80 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-6xl items-center gap-4 px-4 sm:px-6">
        <Link to="/" className="flex items-center gap-2.5" aria-label={t("a11y.home")}>
          <img src={appIcon} alt="" width={36} height={36} className="size-9 rounded-[9px]" />
          <span className="font-display text-2xl font-extrabold uppercase tracking-wide">Rugby Timer</span>
        </Link>
        <nav aria-label={t("a11y.mainNav")} className="ml-6 hidden items-center gap-6 md:flex">
          {NAV.map((item) => (
            <Link key={item.to} to={item.to} className="text-sm text-muted transition hover:text-ice">
              {t(item.key)}
            </Link>
          ))}
        </nav>
        <div className="ml-auto flex items-center gap-3">
          <LanguageSwitcher />
          {/* Wrapped so "hidden" isn't fighting the button's own inline-flex. The hero has the CTA on phones. */}
          <div className="hidden sm:block">
            <AppStoreButton />
          </div>
        </div>
      </div>
    </header>
  );
}
