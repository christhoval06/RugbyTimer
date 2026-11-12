import { describe, expect, it } from "vitest";
import i18n, { LANGUAGES } from "./index";

describe("i18n setup", () => {
  it.each(LANGUAGES.map((l) => l.code))("%s is selectable and resolves to itself", async (code) => {
    await i18n.changeLanguage(code);
    expect(i18n.resolvedLanguage).toBe(code);
    expect(document.documentElement.lang).toBe(code);
  });

  it.each([
    ["es-MX", "es"],
    ["es-ES", "es"],
    ["fr-CA", "fr"],
    ["pt", "pt-BR"],
    ["pt-PT", "pt-BR"],
    ["en-GB", "en"],
  ])("a browser set to %s gets %s", async (browser, expected) => {
    await i18n.changeLanguage(browser);
    expect(i18n.resolvedLanguage).toBe(expected);
  });

  it("falls back to English for other languages", async () => {
    await i18n.changeLanguage("de-DE");
    expect(i18n.resolvedLanguage).toBe("en");
    expect(i18n.t("hero.eyebrow")).toBe("Built for rugby referees");
  });

  it("returns lists as arrays for the sections that map over them", () => {
    expect(i18n.t("faq.items", { returnObjects: true })).toHaveLength(6);
    expect(i18n.t("hero.badges", { returnObjects: true })).toContain("One-time purchase");
  });
});
