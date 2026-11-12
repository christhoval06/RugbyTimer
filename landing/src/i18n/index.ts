import i18n from "i18next";
import LanguageDetector from "i18next-browser-languagedetector";
import { initReactI18next } from "react-i18next";
import en from "./locales/en.json";
import es from "./locales/es.json";
import fr from "./locales/fr.json";
import ptBR from "./locales/pt-BR.json";

/** The app's four languages; English is the base and the fallback. `short` is shown on the switcher button. */
export const LANGUAGES = [
  { code: "en", short: "EN", label: "English" },
  { code: "es", short: "ES", label: "Español" },
  { code: "fr", short: "FR", label: "Français" },
  { code: "pt-BR", short: "PT", label: "Português (Brasil)" },
] as const;

export type LanguageCode = (typeof LANGUAGES)[number]["code"];

void i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      es: { translation: es },
      fr: { translation: fr },
      "pt-BR": { translation: ptBR },
    },
    fallbackLng: { pt: ["pt-BR", "en"], default: ["en"] },
    // Exact codes, so "pt-BR" is supported. Regional codes still match: es-MX → es, pt-PT → pt-BR.
    supportedLngs: LANGUAGES.map((l) => l.code),
    interpolation: { escapeValue: false },
    // Remembers a language picked in the switcher; no cookies.
    detection: { order: ["localStorage", "navigator"], caches: ["localStorage"], lookupLocalStorage: "rt-language" },
    returnObjects: true,
  });

function syncDocumentLanguage(language: string) {
  document.documentElement.lang = language;
}
syncDocumentLanguage(i18n.resolvedLanguage ?? "en");
i18n.on("languageChanged", syncDocumentLanguage);

export default i18n;
