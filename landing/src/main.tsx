import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { RouterProvider } from "react-router/dom";
import { MotionConfig } from "framer-motion";
import "./i18n";
import "./styles.css";
import { router } from "./router";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    {/* Follows the visitor's "reduce motion" setting. */}
    <MotionConfig reducedMotion="user">
      <RouterProvider router={router} />
    </MotionConfig>
  </StrictMode>,
);
