import { describe, expect, it } from "vitest";
import manifest from "./manifest.json";
import { appIcon, screen } from "./images";

// vite-imagetools serves /@imagetools/<hash> in dev and tests, and .webp files in the build.
const IMAGE_URL = /^\/@imagetools\/\w+$|\.webp$/;

describe("screen()", () => {
  it("returns the image with its size and the alt text in the page language", () => {
    const image = screen("phone", "match-clock", "es");
    expect(image.src).toMatch(IMAGE_URL);
    expect(image).toMatchObject({ width: 1320, height: 2868, alt: manifest.phone[0].alt.es });
  });

  it("falls back to English alt text for an unsupported language", () => {
    expect(screen("watch", "score", "de").alt).toBe(manifest.watch.find((w) => w.id === "score")!.alt.en);
  });

  it("throws for a screen that isn't in the manifest", () => {
    expect(() => screen("phone", "missing", "en")).toThrow(/Unknown screen phone\/missing/);
  });

  it.each([
    ...manifest.phone.map((e) => ["phone", e.id] as const),
    ...manifest.watch.map((e) => ["watch", e.id] as const),
  ])("resolves %s/%s to an imported image", (device, id) => {
    for (const language of manifest.locales) {
      const image = screen(device, id, language);
      expect(image.src).toBeTruthy();
      expect(image.alt.length).toBeGreaterThan(20);
    }
  });

  it("exports the app icon", () => {
    expect(appIcon).toMatch(IMAGE_URL);
  });
});
