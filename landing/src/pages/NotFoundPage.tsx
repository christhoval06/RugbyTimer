import { Link } from "react-router";
import { useTranslation } from "react-i18next";
import { useDocumentTitle } from "../components/useDocumentTitle";

export default function NotFoundPage() {
  const { t } = useTranslation();
  useDocumentTitle(t("notFound.title"));
  return (
    <section className="relative flex min-h-[70dvh] items-center overflow-hidden">
      <div aria-hidden="true" className="pitch-lines absolute inset-0 opacity-60" />
      <div className="relative mx-auto max-w-xl px-4 text-center">
        <p className="font-display text-8xl font-extrabold text-red tabular">404</p>
        <h1 className="mt-4 font-display text-4xl font-extrabold uppercase tracking-tight">{t("notFound.title")}</h1>
        <p className="mt-4 text-lg text-muted">{t("notFound.body")}</p>
        <Link to="/" className="mt-8 inline-flex rounded-control bg-emerald px-6 py-3 font-display text-lg font-extrabold uppercase tracking-wide text-void hover:bg-emerald/90">
          {t("notFound.back")}
        </Link>
      </div>
    </section>
  );
}
