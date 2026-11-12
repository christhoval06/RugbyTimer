import { useEffect } from "react";

/** Sets the browser tab title for a page: "Page · Rugby Timer", or the plain title on the home page. */
export function useDocumentTitle(title: string, isHome = false) {
  useEffect(() => {
    document.title = isHome ? title : `${title} · Rugby Timer`;
  }, [title, isHome]);
}
