import Foundation
import WatchConnectivity
import Combine

public class WatchConnectivityService: NSObject, ObservableObject {
    @Published public var receivedConfiguration: MatchConfiguration?
    @Published public var receivedSnapshot: MatchSnapshot?
    /// Watch only: the iPhone went back to Match Setup for this match (see `+MatchReset`).
    @Published public var receivedMatchReset: UUID?
    /// iPhone only: a Watch Quick Match that reached full time, for the match history.
    @Published public var receivedFinishedMatch: FinishedMatch?
    @Published public var isWatchReachable = false
    @Published public var connectedWatchName = "APPLE WATCH"
    @Published public var watchBatteryLevel = 0
    /// iPhone only: a Watch is paired and has RugbyTimer installed, so the match can run on it.
    /// When false the iPhone offers iPhone-only mode as the main way to run a match.
    @Published public var isWatchAvailable = false

    private let session = WCSession.default
    var outgoingContext: [String: Any] = [:]

    public override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    public func sendMatchConfig(_ configuration: MatchConfiguration) {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        outgoingContext["configuration"] = data
        outgoingContext.removeValue(forKey: Self.matchResetKey)
        flushContext()
    }

    public func sendMatchSnapshot(_ snapshot: MatchSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        outgoingContext["snapshot"] = data
        flushContext()
    }

    /// Watch only: hands a finished Quick Match to the iPhone for its history. Queued by
    /// WatchConnectivity, so it arrives even if the iPhone is out of range right now.
    public func sendFinishedMatch(_ match: FinishedMatch) {
        guard session.activationState == .activated, let data = try? JSONEncoder().encode(match) else { return }
        session.transferUserInfo([Self.finishedMatchKey: data])
    }

    static let finishedMatchKey = "finishedMatch" // l10n-ignore: message key

    /// iPhone only: the Watch shows text in the language picked in iPhone Settings.
    public func sendAppLanguage(_ language: AppLanguage) {
        outgoingContext["language"] = language.rawValue
        flushContext()
    }

    public func sendWatchTelemetry(watchName: String, battery: Int) {
        outgoingContext["watchName"] = watchName
        outgoingContext["battery"] = battery
        flushContext()
    }

    func flushContext() {
        guard session.activationState == .activated, !outgoingContext.isEmpty else { return }
        // Retain the latest configuration/state for an unreachable companion.
        do {
            try session.updateApplicationContext(outgoingContext)
        } catch {
            print("Companion sync failed: \(error.localizedDescription)")
        }
        if session.isReachable {
            session.sendMessage(outgoingContext, replyHandler: nil, errorHandler: nil)
        }
    }

    func updateWatchAvailability() {
        #if os(iOS)
        isWatchAvailable = session.activationState == .activated && session.isPaired && session.isWatchAppInstalled
        #endif
    }

    func receive(_ context: [String: Any]) {
        #if os(watchOS)
        if let data = context["configuration"] as? Data,
           let configuration = try? JSONDecoder().decode(MatchConfiguration.self, from: data) {
            receivedConfiguration = configuration
        }
        receiveMatchReset(from: context)
        #else
        if let data = context["snapshot"] as? Data,
           let snapshot = try? JSONDecoder().decode(MatchSnapshot.self, from: data) {
            receivedSnapshot = snapshot
        }
        #endif
        if let language = context["language"] as? String { UserDefaults.standard.set(language, forKey: AppLanguage.defaultsKey) }
        if let name = context["watchName"] as? String { connectedWatchName = name.uppercased() }
        if let battery = context["battery"] as? Int { watchBatteryLevel = battery }
    }
}
