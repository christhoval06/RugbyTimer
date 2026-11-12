import { act, render, screen, within } from "@testing-library/react";
import { createMemoryRouter } from "react-router";
import { RouterProvider } from "react-router/dom";
import { describe, expect, it } from "vitest";
import i18n from "./i18n";
import { APPSTORE_URL, CONTACT_ME_EMAIL } from "./config";
import { routes } from "./router";

function renderAt(path: string) {
  const router = createMemoryRouter(routes, { initialEntries: [path] });
  render(<RouterProvider router={router} />);
  return router;
}

describe("routes", () => {
  it("home: hero, App Store links and contact email", async () => {
    renderAt("/");
    expect(await screen.findByRole("heading", { level: 1, name: "The match clock that keeps up with the game" })).toBeInTheDocument();
    expect(document.title).toBe("Rugby Timer · Match clock for rugby referees");
    const storeLinks = screen.getAllByRole("link", { name: "Get it on the App Store" });
    expect(storeLinks.length).toBeGreaterThanOrEqual(2);
    storeLinks.forEach((link) => expect(link).toHaveAttribute("href", APPSTORE_URL));
    expect(screen.getAllByRole("link", { name: CONTACT_ME_EMAIL })[0]).toHaveAttribute("href", `mailto:${CONTACT_ME_EMAIL}`);
  });

  it("home: every section is there, with the price in the FAQ", async () => {
    renderAt("/");
    await screen.findByRole("heading", { level: 2, name: "Frequently asked" });
    for (const id of ["features", "watch", "faq"]) expect(document.getElementById(id)).toBeInTheDocument();
    expect(screen.getByText(/one-time purchase of US\$1\.99/)).toBeInTheDocument();
    expect(screen.getAllByRole("img").every((img) => img.hasAttribute("alt"))).toBe(true);
  });

  it("privacy: renders PRIVACY.md, including the website section", async () => {
    renderAt("/privacy");
    expect(await screen.findByRole("heading", { level: 1, name: "Privacy Policy" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 2, name: "This website" })).toBeInTheDocument();
    expect(screen.getByRole("table")).toBeInTheDocument();
    expect(document.title).toBe("Privacy Policy · Rugby Timer");
  });

  it("terms: renders TERMS.md and links internally to the privacy page", async () => {
    renderAt("/terms");
    expect(await screen.findByRole("heading", { level: 1, name: "Terms and Conditions" })).toBeInTheDocument();
    const policy = within(screen.getByRole("article"));
    expect(policy.getByRole("link", { name: "Privacy Policy" })).toHaveAttribute("href", "/privacy");
  });

  it("legal pages in another language say the policy is in English, marked lang=en", async () => {
    await i18n.changeLanguage("es");
    renderAt("/terms");
    const heading = await screen.findByRole("heading", { level: 1, name: "Terms and Conditions" });
    expect(screen.getByText(/Este documento se publica en inglés/)).toBeInTheDocument();
    expect(heading.closest("[lang]")).toHaveAttribute("lang", "en");
    expect(document.title).toBe("Términos y condiciones · Rugby Timer");
  });

  it("unknown paths show the 404 page with a way home", async () => {
    renderAt("/no-such-page");
    expect(await screen.findByText("404")).toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 1, name: "Out of play" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Back to home" })).toHaveAttribute("href", "/");
  });

  it("follows a language change on the page", async () => {
    renderAt("/no-such-page");
    await screen.findByText("404");
    await act(() => i18n.changeLanguage("pt-BR"));
    expect(screen.getByRole("heading", { level: 1, name: "Bola fora" })).toBeInTheDocument();
  });
});
