//
//  AppLanguage.swift
//  RugbyTimer
//

import Foundation

/// The language picked in Settings. `system` follows the device and falls back to English
/// when the device language is not one the app ships. The Watch receives the iPhone's choice.
public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case system
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case portugueseBrazil = "pt-BR"

    /// Read by both apps; the Watch stores the value the iPhone sends.
    public static let defaultsKey = "settings.appLanguage"

    public var id: String { rawValue }

    public static var current: AppLanguage {
        UserDefaults.standard.string(forKey: defaultsKey).flatMap(AppLanguage.init(rawValue:)) ?? .system
    }

    /// The shipped localization in use: the choice, or the device's best match (English when none).
    public var resolvedIdentifier: String {
        guard self == .system else { return rawValue }
        return Bundle.main.preferredLocalizations.first ?? AppLanguage.english.rawValue
    }

    /// Text in the chosen language; dates and numbers keep the device's region where possible.
    public var locale: Locale {
        let language = resolvedIdentifier
        if Locale.current.identifier.hasPrefix(language.replacingOccurrences(of: "-", with: "_")) { return .current }
        guard !language.contains("-"), let region = Locale.current.region?.identifier else {
            return Locale(identifier: language)
        }
        return Locale(identifier: "\(language)_\(region)")
    }

    /// Each language in its own words, so people find theirs whatever the app is showing.
    public var nativeName: String? {
        switch self {
        case .system: nil
        case .english: "English" // l10n-ignore
        case .spanish: "Español" // l10n-ignore
        case .french: "Français" // l10n-ignore
        case .portugueseBrazil: "Português (Brasil)" // l10n-ignore
        }
    }
}

public extension String {
    /// Localized into the app language from Settings, falling back to English.
    /// Use this instead of `String(localized:)`, which only follows the device language.
    init(appLocalized resource: LocalizedStringResource) {
        var resource = resource
        resource.locale = AppLanguage.current.locale
        self.init(localized: resource)
    }
}
