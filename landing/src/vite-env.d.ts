/// <reference types="vite/client" />

// vite-imagetools: "?w=…&format=webp" imports resolve to a URL string.
declare module "*&format=webp" {
  const src: string;
  export default src;
}
