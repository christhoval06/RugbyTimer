import { useLayoutEffect, useRef } from "react";
import { Outlet, useLocation } from "react-router";
import { useTranslation } from "react-i18next";
import { Header } from "./Header";
import { Footer } from "./Footer";

/**
 * Shared page frame. On each new page, scrolls to the top, or to the "#section" in the link.
 * (ScrollRestoration runs before a lazy page renders, so it can leave a new page scrolled down.)
 */
export function Layout() {
  const { t } = useTranslation();
  const { hash, pathname } = useLocation();

  const lastPath = useRef(pathname);

  // The router commits the new location together with the loaded page, so its sections exist here.
  // Glide to a section on the same page; jump when arriving from another page.
  useLayoutEffect(() => {
    const behavior: ScrollBehavior = lastPath.current === pathname ? "smooth" : "instant";
    lastPath.current = pathname;
    const target = hash ? document.getElementById(decodeURIComponent(hash.slice(1))) : null;
    if (target) target.scrollIntoView({ behavior });
    else window.scrollTo({ top: 0, behavior: "instant" });
  }, [hash, pathname]);

  return (
    <div className="flex min-h-dvh flex-col bg-void">
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-control focus:bg-emerald focus:px-4 focus:py-2 focus:font-bold focus:text-void"
      >
        {t("a11y.skip")}
      </a>
      <Header />
      <main id="main" className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
