import { useEffect, useId, useRef, useState, type KeyboardEvent } from "react";
import { AnimatePresence, motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { LANGUAGES } from "../i18n";
import { ChevronIcon, GlobeIcon } from "./LanguageIcons";

type Props = { placement?: "down" | "up"; className?: string };

/**
 * Globe button with the current language code; opens a menu of the four languages.
 * Keyboard: arrows move, Home/End jump, Enter picks, Escape closes and returns focus.
 */
export function LanguageSwitcher({ placement = "down", className = "" }: Props) {
  const { t, i18n } = useTranslation();
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);
  const itemRefs = useRef<(HTMLButtonElement | null)[]>([]);
  const menuId = useId();
  const currentIndex = Math.max(0, LANGUAGES.findIndex((l) => l.code === i18n.resolvedLanguage));
  const current = LANGUAGES[currentIndex];

  // Focus the current language when the menu opens; close on a click outside.
  useEffect(() => {
    if (!open) return;
    itemRefs.current[currentIndex]?.focus();
    const onPointer = (e: PointerEvent) => {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("pointerdown", onPointer);
    return () => document.removeEventListener("pointerdown", onPointer);
  }, [open, currentIndex]);

  function close(returnFocus: boolean) {
    setOpen(false);
    if (returnFocus) buttonRef.current?.focus();
  }

  function choose(code: string) {
    void i18n.changeLanguage(code);
    close(true);
  }

  function onMenuKey(e: KeyboardEvent<HTMLDivElement>) {
    const items = itemRefs.current;
    const index = items.indexOf(document.activeElement as HTMLButtonElement);
    const move: Record<string, number> = { ArrowDown: index + 1, ArrowUp: index - 1, Home: 0, End: items.length - 1 };
    if (e.key in move) {
      e.preventDefault();
      items[(move[e.key] + items.length) % items.length]?.focus();
    } else if (e.key === "Escape" || e.key === "Tab") {
      if (e.key === "Escape") e.preventDefault();
      close(e.key === "Escape");
    }
  }

  return (
    <div ref={rootRef} className={`relative ${className}`}>
      <button
        ref={buttonRef}
        type="button"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={open ? menuId : undefined}
        aria-label={t("a11y.languageCurrent", { language: current.label })}
        onClick={() => setOpen((o) => !o)}
        onKeyDown={(e) => (e.key === "ArrowDown" || e.key === "ArrowUp") && (e.preventDefault(), setOpen(true))}
        className="flex h-10 items-center gap-2 rounded-control border border-line bg-surface px-3 font-display text-base font-bold tracking-wider text-ice transition hover:border-line-strong aria-expanded:border-emerald"
      >
        <GlobeIcon />
        {current.short}
        <ChevronIcon open={open} />
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            id={menuId}
            role="menu"
            aria-label={t("a11y.language")}
            onKeyDown={onMenuKey}
            initial={{ opacity: 0, y: placement === "down" ? -6 : 6, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: placement === "down" ? -6 : 6, scale: 0.98 }}
            transition={{ duration: 0.16, ease: "easeOut" }}
            className={`absolute z-50 min-w-56 overflow-hidden rounded-control border border-line-strong bg-surface p-1.5 shadow-[0_20px_40px_-12px_rgb(0_0_0/0.8)] ${
              placement === "down" ? "right-0 top-full mt-2 origin-top-right" : "bottom-full left-0 mb-2 origin-bottom-left"
            }`}
          >
            {LANGUAGES.map((l, i) => {
              const selected = l.code === current.code;
              return (
                <button
                  key={l.code}
                  ref={(el) => void (itemRefs.current[i] = el)}
                  type="button"
                  role="menuitemradio"
                  aria-checked={selected}
                  lang={l.code}
                  tabIndex={-1}
                  onClick={() => choose(l.code)}
                  className={`flex w-full items-center gap-3 rounded-[4px] px-3 py-2.5 text-left text-sm outline-none transition hover:bg-void focus-visible:bg-void focus-visible:outline-none ${
                    selected ? "text-emerald" : "text-ice"
                  }`}
                >
                  <span aria-hidden="true" className="w-4 text-emerald">{selected ? "✓" : ""}</span>
                  <span className="flex-1">{l.label}</span>
                  <span aria-hidden="true" className="font-display text-xs font-bold tracking-wider text-muted">{l.short}</span>
                </button>
              );
            })}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
