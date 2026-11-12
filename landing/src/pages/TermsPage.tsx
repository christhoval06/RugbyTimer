import { useTranslation } from "react-i18next";
import terms from "../../../TERMS.md?raw";
import { LegalDocument } from "../components/LegalDocument";
import { useDocumentTitle } from "../components/useDocumentTitle";

/** Terms and conditions, rendered from the repository's TERMS.md. */
export default function TermsPage() {
  const { t } = useTranslation();
  useDocumentTitle(t("nav.terms"));
  return <LegalDocument source={terms} />;
}
