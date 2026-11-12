import { useTranslation } from "react-i18next";
import privacy from "../../../PRIVACY.md?raw";
import { LegalDocument } from "../components/LegalDocument";
import { useDocumentTitle } from "../components/useDocumentTitle";

/** The app's privacy policy, rendered from the repository's PRIVACY.md (one source for both). */
export default function PrivacyPage() {
  const { t } = useTranslation();
  useDocumentTitle(t("nav.privacy"));
  return <LegalDocument source={privacy} />;
}
