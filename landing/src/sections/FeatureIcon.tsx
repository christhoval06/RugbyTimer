/** Line icons for the feature cards, drawn to match the app's instrument look. */
const PATHS: Record<string, string> = {
  clock: "M12 21a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm0-12v4l2.5 2.5M9.5 2h5",
  card: "M7 3h7l3 3v15H7zM10 13h4",
  score: "M12 5v14M5 12h14",
  lock: "M7 11V8a5 5 0 0 1 10 0v3M5 11h14v10H5zM12 15v2",
  watch: "M8 6 9 2h6l1 4M8 18l1 4h6l1-4M6 6h12v12H6zM12 9v3l2 1",
  record: "M6 3h12v18H6zM9 8h6M9 12h6M9 16h4",
};

export function FeatureIcon({ name }: { name: string }) {
  return (
    <span className="flex size-11 items-center justify-center rounded-control border border-emerald/30 bg-emerald/10 text-emerald">
      <svg aria-hidden="true" viewBox="0 0 24 24" className="size-6" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <path d={PATHS[name] ?? PATHS.clock} />
      </svg>
    </span>
  );
}
