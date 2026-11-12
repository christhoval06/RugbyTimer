import { describe, expect, it } from "vitest";
import { LANGUAGES } from "./index";
import en from "./locales/en.json";
import es from "./locales/es.json";
import fr from "./locales/fr.json";
import ptBR from "./locales/pt-BR.json";

const locales: Record<string, unknown> = { en, es, fr, "pt-BR": ptBR };

/** Every leaf path, with list lengths, e.g. "faq.items[6]" and "faq.items[0].q". */
function shape(value: unknown, path = ""): string[] {
  if (Array.isArray(value)) return [`${path}[${value.length}]`, ...value.flatMap((v, i) => shape(v, `${path}[${i}]`))];
  if (value && typeof value === "object") return Object.entries(value).flatMap(([k, v]) => shape(v, path ? `${path}.${k}` : k));
  return [path];
}

function leaves(value: unknown, path = ""): [string, string][] {
  if (Array.isArray(value)) return value.flatMap((v, i) => leaves(v, `${path}[${i}]`));
  if (value && typeof value === "object") return Object.entries(value).flatMap(([k, v]) => leaves(v, path ? `${path}.${k}` : k));
  return [[path, String(value)]];
}

const placeholders = (text: string) => [...text.matchAll(/{{\s*(\w+)\s*}}/g)].map((m) => m[1]).sort();

describe("locales", () => {
  it("has a file for every language in the switcher", () => {
    expect(Object.keys(locales).sort()).toEqual(LANGUAGES.map((l) => l.code).sort());
  });

  it.each(["es", "fr", "pt-BR"])("%s has exactly the English keys and list lengths", (code) => {
    expect(shape(locales[code]).sort()).toEqual(shape(en).sort());
  });

  it.each(Object.keys(locales))("%s has no empty strings", (code) => {
    const empty = leaves(locales[code]).filter(([, text]) => text.trim() === "");
    expect(empty).toEqual([]);
  });

  it.each(["es", "fr", "pt-BR"])("%s keeps the same {{placeholders}} as English", (code) => {
    const english = new Map(leaves(en));
    for (const [path, text] of leaves(locales[code])) {
      expect(placeholders(text), path).toEqual(placeholders(english.get(path) ?? ""));
    }
  });

  it("feature icons are the same in every language", () => {
    const icons = (l: typeof en) => l.features.items.map((i) => i.icon);
    for (const code of ["es", "fr", "pt-BR"]) expect(icons(locales[code] as typeof en)).toEqual(icons(en));
  });
});
