/** Shown while a lazy page loads. */
export function RouteFallback() {
  return (
    <div className="flex min-h-[60dvh] items-center justify-center" role="status" aria-live="polite">
      <span className="size-10 animate-spin rounded-full border-2 border-line border-t-emerald" />
    </div>
  );
}
