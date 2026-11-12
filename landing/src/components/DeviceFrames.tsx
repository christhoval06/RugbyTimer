import type { Screen } from "../assets/images";

/** A plain dark phone body around a real app screen (no Apple product artwork). */
export function PhoneFrame({ screen, className = "", priority = false }: { screen: Screen; className?: string; priority?: boolean }) {
  return (
    <div className={`rounded-[2.6rem] border border-line-strong/70 bg-[#141920] p-2.5 shadow-[0_40px_80px_-30px_rgb(0_0_0/0.9),0_0_0_1px_rgb(255_255_255/0.03)] ${className}`}>
      <img
        src={screen.src}
        alt={screen.alt}
        width={screen.width}
        height={screen.height}
        loading={priority ? "eager" : "lazy"}
        decoding="async"
        fetchPriority={priority ? "high" : "auto"}
        className="block h-auto w-full rounded-[2.1rem]"
      />
    </div>
  );
}

/** A plain dark watch case with a crown around a real Watch screen. */
export function WatchFrame({ screen, className = "" }: { screen: Screen; className?: string }) {
  return (
    <div className={`relative ${className}`}>
      <span aria-hidden="true" className="absolute -right-1.5 top-[24%] h-[16%] w-2.5 rounded-r-md bg-[#2a313d]" />
      <div className="rounded-[2.4rem] border border-line-strong/70 bg-[#141920] p-3 shadow-[0_30px_60px_-25px_rgb(0_0_0/0.9)]">
        <img
          src={screen.src}
          alt={screen.alt}
          width={screen.width}
          height={screen.height}
          loading="lazy"
          decoding="async"
          className="block h-auto w-full rounded-[1.8rem]"
        />
      </div>
    </div>
  );
}
