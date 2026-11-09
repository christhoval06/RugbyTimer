//
//  AppInfo.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/09/26.
//

import Foundation

/// Static app and developer details shown in Settings. Edit these to update the About screens.
enum AppInfo {
    static let developerName = "Christhoval Barba"
    static let developerHandle = "@christhoval"
    static let developerRole: LocalizedStringResource = "iOS developer · Rugby player · Referee"
    static let developerBio: LocalizedStringResource = "I've played rugby in Panama for more than 15 years with Titanes Rugby Club, and represented the national team from 2015 to 2022. Today I also referee. Rugby Timer is the tool I wanted with the whistle in my hand: the clock, the sin-bins and the score on my wrist, so my eyes stay on the game."

    /// Rugby career highlights shown on the developer page.
    static let rugbyCareer: [(symbol: String, title: String, detail: LocalizedStringResource)] = [
        ("figure.rugby", "Titanes Rugby Club", "Player · 15+ years in Panama"),
        ("flag.fill", "Panama National Team", "Player · 2015–2022"),
        ("stopwatch.fill", "Rugby Referee", "Officiating matches today")
    ]
    static let supportEmail = "support@christhoval.dev"
    static let websiteURL = URL(string: "https://christhoval.dev")!
    static let githubURL = URL(string: "https://github.com/christhoval")!

    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    static func mailURL(subject: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Rugby Timer · \(subject)"),
            URLQueryItem(name: "body", value: "\n\n—\nRugby Timer \(version)")
        ]
        return components.url
    }
}
