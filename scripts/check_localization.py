#!/usr/bin/env python3
"""Localization check for RugbyTimer.

1. Every catalog key is translated into each shipped language, and no key is stale.
2. Every string the compiler extracted is in the catalog (`xcodebuild` does not sync catalogs; Xcode does).
3. Swift string literals that look like UI text but were not extracted are reported as hardcoded.

Build both schemes first, then run:
    scripts/check_localization.py --derived-data <DerivedData path>

Mark an intentional non-localized literal (wire values, identifiers, email subjects) with `// l10n-ignore`.
"""
import argparse, glob, json, os, re, sys

LANGUAGES = ["es", "fr", "pt-BR"]
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGETS = {
    "RugbyTimer": ("RugbyTimer/Localizable.xcstrings", "Debug-iphonesimulator/RugbyTimer.build"),
    "RugbyTimerWatch Watch App": ("RugbyTimerWatch Watch App/Localizable.xcstrings",
                                  "Debug-watchsimulator/RugbyTimerWatch Watch App.build"),
    "RugbyTimerComplicationExtension": ("RugbyTimerComplication/Localizable.xcstrings",
                                        "Debug-watchsimulator/RugbyTimerComplicationExtension.build"),
    # No catalog: it only shows labels the app translated, so it must extract no strings.
    "RugbyTimerLiveActivityExtension": (None, "Debug-iphonesimulator/RugbyTimerLiveActivityExtension.build"),
}
SOURCE_DIRS = ["RugbyTimer", "RugbyTimerWatch Watch App", "RugbyTimerComplication", "RugbyTimerLiveActivity"]
LITERAL = re.compile(r'"((?:[^"\\]|\\.)*)"')
SPECIFIER = re.compile(r"%(?:\d+\$)?(?:lld|ld|d|@|f|\.\d+f)")
INTERPOLATION = re.compile(r"\\\((?:[^()]|\([^()]*\))*\)")
# Lines whose literals are never shown to people.
NON_UI_CONTEXT = re.compile(
    r"accessibilityIdentifier\(|systemName:|symbol:|Image\(\"|forKey|\.custom\(\"|Color\(hex:|URL\(string:"
    r"|print\(|context\[|Context\[|launchArguments|UserDefaults|static let \w+(ID|Key|Prefix)\b|static let kind = |log\.\w+\(|identifier:|id: \""
    # Values synced between devices or used as sample data stay English by design.
    r"|[tT]eamName: \"|[tT]eamName: String = \"|description: \"|== \"OFFICIAL\"|Team = \"|infoDictionary|info\?\[|arguments\.contains|WatchName = \"|watchName: String = \""
)


def catalog_problems(path):
    if path is None:
        return set(), []
    strings = json.load(open(os.path.join(ROOT, path)))["strings"]
    problems = []
    for key, entry in strings.items():
        if entry.get("extractionState") == "stale":
            problems.append(f"stale key {key!r}")
        if entry.get("shouldTranslate") is False:
            continue
        for lang in LANGUAGES:
            unit = entry.get("localizations", {}).get(lang)
            if unit is None:
                problems.append(f"{lang} missing for {key!r}")
            elif "stringUnit" in unit and unit["stringUnit"]["state"] != "translated":
                problems.append(f"{lang} not reviewed for {key!r}")
    return set(strings), problems


def extracted_keys(derived_data, build_dir):
    pattern = os.path.join(derived_data, "Build/Intermediates.noindex/RugbyTimer.build", build_dir,
                           "Objects-normal/*/*.stringsdata")
    keys = set()
    for path in glob.glob(pattern):
        for entries in json.load(open(path)).get("tables", {}).values():
            keys.update(entry["key"] for entry in entries)
    return keys


def looks_like_ui_text(text):
    bare = INTERPOLATION.sub("", text)
    if "\\(" in bare:  # a fragment of a literal nested inside an interpolation
        return False
    if not re.search(r"[A-Za-z]{2,}", bare):
        return False
    if re.fullmatch(r"[a-z][A-Za-z0-9]*([._-][A-Za-z0-9]+)*", bare):  # identifiers, keys, SF Symbols
        return False
    if re.fullmatch(r"[\w.+-]+@[\w.-]+|https?://\S+|@\w+", bare):
        return False
    return True


def as_pattern(literal):
    parts = INTERPOLATION.split(literal)
    return re.compile("^" + ".+".join(re.escape(p.replace('\\"', '"').replace("\\n", "\n")) for p in parts) + "$", re.S)


def hardcoded_literals(all_keys):
    normalized = {SPECIFIER.sub("\x00", key).replace("\x00", "X") for key in all_keys}
    findings = []
    for directory in SOURCE_DIRS:
        for path in sorted(glob.glob(os.path.join(ROOT, directory, "**/*.swift"), recursive=True)):
            if "/Tests/" in path:
                continue
            for number, line in enumerate(open(path), 1):
                if line.lstrip().startswith("#Preview"):
                    break
                stripped = line.strip()
                if stripped.startswith("//") or "l10n-ignore" in line or NON_UI_CONTEXT.search(line):
                    continue
                for literal in LITERAL.findall(line.split(" // ")[0]):
                    if not looks_like_ui_text(literal):
                        continue
                    pattern = as_pattern(literal)
                    if any(pattern.match(key) for key in normalized):
                        continue
                    findings.append(f"{os.path.relpath(path, ROOT)}:{number}: {literal!r}")
    return findings


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--derived-data", help="DerivedData folder of a build of both schemes")
    args = parser.parse_args()
    failed = False
    all_keys = set()
    for target, (catalog, build_dir) in TARGETS.items():
        keys, problems = catalog_problems(catalog)
        all_keys |= keys
        if args.derived_data:
            missing = extracted_keys(args.derived_data, build_dir) - keys
            if catalog is None:  # without a catalog a key shows as written: fine when it has no words
                missing = {key for key in missing if re.search(r"[A-Za-z]{2,}", SPECIFIER.sub("", key))}
            problems += [f"not in catalog: {key!r}" for key in sorted(missing)]
        print(f"{target}: {len(keys)} keys, {len(problems)} problems")
        for problem in problems:
            print(f"  {problem}")
        failed |= bool(problems)
    findings = hardcoded_literals(all_keys)
    print(f"Possible hardcoded UI text: {len(findings)}")
    for finding in findings:
        print(f"  {finding}")
    sys.exit(1 if failed or findings else 0)


if __name__ == "__main__":
    main()
