import { useTranslation } from "react-i18next";
import { appIcon } from "../assets/images";
import { AppStoreButton } from "../components/AppStoreButton";
import { Reveal } from "../components/Reveal";
import { CONTACT_ME_EMAIL } from "../config";

export function FinalCta() {
  const { t } = useTranslation();
  return (
    <section aria-labelledby="final-title" className="relative overflow-hidden border-t border-line">
      <div aria-hidden="true" className="pitch-lines absolute inset-0 opacity-60" />
      <div aria-hidden="true" className="absolute left-1/2 top-1/2 size-[40rem] -translate-x-1/2 -translate-y-1/2 rounded-full bg-emerald/10 blur-3xl" />
      <Reveal className="relative mx-auto max-w-3xl px-4 py-24 text-center sm:px-6 md:py-32">
        <img src={appIcon} alt="" width={96} height={96} className="mx-auto size-24 rounded-[22px] shadow-[0_20px_50px_-15px_rgb(16_185_129/0.45)]" />
        <h2 id="final-title" className="mt-8 font-display text-5xl font-extrabold uppercase leading-[0.9] tracking-tight sm:text-6xl">
          {t("final.title")}
        </h2>
        <p className="mx-auto mt-5 max-w-xl text-lg leading-relaxed text-muted">{t("final.body")}</p>
        <AppStoreButton size="lg" className="mt-9" />
        <p className="mt-8 text-sm text-muted">
          {t("final.contactLead")}{" "}
          <a href={`mailto:${CONTACT_ME_EMAIL}`} className="font-bold text-ice underline decoration-emerald underline-offset-4 hover:text-emerald">
            {CONTACT_ME_EMAIL}
          </a>
        </p>
      </Reveal>
    </section>
  );
}
