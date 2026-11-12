import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { afterEach, beforeEach, vi } from "vitest";
import i18n from "../i18n";

// jsdom lacks the browser APIs that Framer Motion and the layout's scrolling use.
class IntersectionObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
  takeRecords() {
    return [];
  }
}
vi.stubGlobal("IntersectionObserver", IntersectionObserverStub);
vi.stubGlobal(
  "matchMedia",
  (query: string) =>
    ({ matches: false, media: query, onchange: null, addEventListener() {}, removeEventListener() {}, addListener() {}, removeListener() {}, dispatchEvent: () => false }) as MediaQueryList,
);
window.scrollTo = (() => {}) as typeof window.scrollTo;
Element.prototype.scrollIntoView = () => {};

// Every test starts in English with nothing remembered.
beforeEach(async () => {
  localStorage.clear();
  await i18n.changeLanguage("en");
});

afterEach(() => {
  cleanup();
});
