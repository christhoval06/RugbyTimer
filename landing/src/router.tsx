import { createBrowserRouter, type RouteObject } from "react-router";
import { Layout } from "./components/Layout";
import { RouteFallback } from "./components/RouteFallback";

/** Every page is a lazy route: each loads its own chunk on first visit. Exported for tests. */
export const routes: RouteObject[] = [
  {
    Component: Layout,
    HydrateFallback: RouteFallback,
    children: [
      { index: true, lazy: () => import("./pages/HomePage").then((m) => ({ Component: m.default })) },
      { path: "privacy", lazy: () => import("./pages/PrivacyPage").then((m) => ({ Component: m.default })) },
      { path: "terms", lazy: () => import("./pages/TermsPage").then((m) => ({ Component: m.default })) },
      { path: "*", lazy: () => import("./pages/NotFoundPage").then((m) => ({ Component: m.default })) },
    ],
  },
];

export const router = createBrowserRouter(routes);
