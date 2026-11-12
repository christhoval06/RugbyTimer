import { act, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import i18n from "../i18n";
import { APPSTORE_URL } from "../config";
import { AppStoreButton } from "./AppStoreButton";

describe("AppStoreButton", () => {
  it("links to the App Store listing in a new tab, safely", () => {
    render(<AppStoreButton />);
    const link = screen.getByRole("link", { name: "Get it on the App Store" });
    expect(link).toHaveAttribute("href", APPSTORE_URL);
    expect(link).toHaveAttribute("target", "_blank");
    expect(link).toHaveAttribute("rel", "noopener noreferrer");
  });

  it("follows the page language", async () => {
    render(<AppStoreButton />);
    await act(() => i18n.changeLanguage("fr"));
    expect(screen.getByRole("link", { name: "Télécharger sur l'App Store" })).toBeInTheDocument();
  });

  it("uses the larger size when asked", () => {
    render(<AppStoreButton size="lg" />);
    expect(screen.getByRole("link")).toHaveClass("text-xl");
  });
});
