import { useTranslation } from "react-i18next";
import { useDocumentTitle } from "../components/useDocumentTitle";
import { Hero } from "../sections/Hero";
import { FeatureGrid } from "../sections/FeatureGrid";
import { Showcase } from "../sections/Showcase";
import { WatchSection } from "../sections/WatchSection";
import { MoreFeatures } from "../sections/MoreFeatures";
import { PrivacyBand } from "../sections/PrivacyBand";
import { Faq } from "../sections/Faq";
import { FinalCta } from "../sections/FinalCta";

export default function HomePage() {
  const { t } = useTranslation();
  useDocumentTitle(t("meta.homeTitle"), true);
  return (
    <>
      <Hero />
      <FeatureGrid />
      <Showcase />
      <WatchSection />
      <MoreFeatures />
      <PrivacyBand />
      <Faq />
      <FinalCta />
    </>
  );
}
