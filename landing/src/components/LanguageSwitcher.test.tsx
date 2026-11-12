import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import i18n from "../i18n";
import { LanguageSwitcher } from "./LanguageSwitcher";

const button = () => screen.getByRole("button", { name: /^Language:|^Idioma:|^Langue/ });

describe("LanguageSwitcher", () => {
  it("shows the current language code and names it for screen readers", () => {
    render(<LanguageSwitcher />);
    expect(button()).toHaveTextContent("EN");
    expect(button()).toHaveAccessibleName("Language: English");
    expect(button()).toHaveAttribute("aria-expanded", "false");
  });

  it("opens a menu with the four languages and the current one checked", async () => {
    render(<LanguageSwitcher />);
    await userEvent.click(button());
    expect(button()).toHaveAttribute("aria-expanded", "true");
    const items = screen.getAllByRole("menuitemradio");
    expect(items.map((i) => i.textContent)).toEqual(["✓EnglishEN", "EspañolES", "FrançaisFR", "Português (Brasil)PT"]);
    expect(screen.getByRole("menuitemradio", { name: /English/ })).toHaveAttribute("aria-checked", "true");
    await waitFor(() => expect(screen.getByRole("menuitemradio", { name: /English/ })).toHaveFocus());
  });

  it("switches language, remembers it, closes and returns focus", async () => {
    render(<LanguageSwitcher />);
    await userEvent.click(button());
    await userEvent.click(screen.getByRole("menuitemradio", { name: /Español/ }));
    expect(i18n.resolvedLanguage).toBe("es");
    expect(document.documentElement.lang).toBe("es");
    expect(localStorage.getItem("rt-language")).toBe("es");
    await waitFor(() => expect(screen.queryByRole("menu")).not.toBeInTheDocument());
    expect(button()).toHaveTextContent("ES");
    expect(button()).toHaveAccessibleName("Idioma: Español");
    expect(button()).toHaveFocus();
  });

  it("works from the keyboard: arrows, Home, End, Enter and Escape", async () => {
    const user = userEvent.setup();
    render(<LanguageSwitcher />);
    button().focus();
    await user.keyboard("{ArrowDown}");
    await waitFor(() => expect(screen.getByRole("menuitemradio", { name: /English/ })).toHaveFocus());
    await user.keyboard("{ArrowDown}");
    expect(screen.getByRole("menuitemradio", { name: /Español/ })).toHaveFocus();
    await user.keyboard("{End}");
    expect(screen.getByRole("menuitemradio", { name: /Português/ })).toHaveFocus();
    await user.keyboard("{ArrowDown}");
    expect(screen.getByRole("menuitemradio", { name: /English/ })).toHaveFocus(); // wraps around
    await user.keyboard("{Escape}");
    await waitFor(() => expect(screen.queryByRole("menu")).not.toBeInTheDocument());
    expect(button()).toHaveFocus();
    expect(i18n.resolvedLanguage).toBe("en");

    await user.keyboard("{ArrowDown}");
    await waitFor(() => expect(screen.getByRole("menuitemradio", { name: /English/ })).toHaveFocus());
    await user.keyboard("{End}{Enter}");
    expect(i18n.resolvedLanguage).toBe("pt-BR");
    expect(button()).toHaveTextContent("PT");
  });

  it("closes when you click outside", async () => {
    render(
      <>
        <p>Outside</p>
        <LanguageSwitcher />
      </>,
    );
    await userEvent.click(button());
    expect(screen.getByRole("menu")).toBeInTheDocument();
    await userEvent.click(screen.getByText("Outside"));
    await waitFor(() => expect(screen.queryByRole("menu")).not.toBeInTheDocument());
  });
});
