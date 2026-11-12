import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";
import { APPSTORE_URL } from "../config";

// Vitest runs from the landing folder (import.meta.url is an http: URL under jsdom).
const root = process.cwd();
const manifest = JSON.parse(readFileSync(resolve(root, "public/manifest.webmanifest"), "utf8"));

/** Width and height from a PNG's IHDR chunk. */
function pngSize(path: string) {
  const bytes = readFileSync(path);
  return `${bytes.readUInt32BE(16)}x${bytes.readUInt32BE(20)}`;
}

describe("web app manifest", () => {
  it("is linked from index.html", () => {
    expect(readFileSync(resolve(root, "index.html"), "utf8")).toContain('<link rel="manifest" href="/manifest.webmanifest" />');
  });

  it("has the fields browsers need to install the site", () => {
    expect(manifest).toMatchObject({ name: expect.any(String), short_name: "Rugby Timer", start_url: "/", display: "standalone" });
    expect(manifest.short_name.length).toBeLessThanOrEqual(12);
  });

  it("uses the app's Pitch Void color", () => {
    expect(manifest.theme_color).toBe("#0B0E14");
    expect(manifest.background_color).toBe("#0B0E14");
  });

  it("has 192 and 512 icons, plus a maskable one, that exist at their stated size", () => {
    const sizes = manifest.icons.map((i: { sizes: string }) => i.sizes);
    expect(sizes).toEqual(expect.arrayContaining(["192x192", "512x512"]));
    expect(manifest.icons.some((i: { purpose: string }) => i.purpose === "maskable")).toBe(true);
    for (const icon of manifest.icons) {
      const file = resolve(root, "public", icon.src.slice(1));
      expect(existsSync(file), icon.src).toBe(true);
      expect(pngSize(file), icon.src).toBe(icon.sizes);
    }
  });

  it("points to the App Store listing", () => {
    expect(manifest.related_applications[0]).toMatchObject({ platform: "itunes", url: APPSTORE_URL });
  });
});
