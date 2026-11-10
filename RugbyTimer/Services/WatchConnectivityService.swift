import Foundation
import WatchConnectivity
import Combine

public struct MatchConfiguration: Codable, Equatable {
    public var matchID: UUID
    public var home: String
    public var away: String
    public var duration: Int
    // Optional so setups from an older companion retain the 10-minute default.
    public var sinBinDurationSeconds: Int? = nil
    // Optional so older companions keep the default shirt-number range.
    public var maxPlayerNumber: Int? = nil
    // Optional so older companions keep plain taps on the Watch.
    public var tapLockEnabled: Bool? = nil
    // Optional so older companions skip the Watch coin toss.
    public var coinTossEnabled: Bool? = nil
    // Optional so older companions get the standard 2-minute half-time break.
    public var halfTimeBreakSeconds: Int? = nil
}

public struct MatchSnapshot: Codable, Equatable {
    public var updatedAt = Date()
    public var matchID: UUID
    public var home: String
    public var away: String
    public var duration: Int
    public var period: MatchPeriod
    public var remaining: Int
    public var isRunning: Bool
    public var homeScore: Int
    public var awayScore: Int
    public var cards: [MatchCard]
    public var rejectedConfigurationID: UUID? = nil
    public var sinBinDurationSeconds: Int? = nil
    // Optional so snapshots from an older Watch app keep decoding; the iPhone needs it for the match record.
    public var events: [MatchEvent]? = nil
    // When the running period reaches zero, so the iPhone keeps counting while out of range.
    public var clockEndDate: Date? = nil
}

public class WatchConnectivityService: NSObject, ObservableObject {
    @Published public var receivedConfiguration: MatchConfiguration?
    @Published public var receivedSnapshot: MatchSnapshot?
    @Published public var isWatchReachable = false
    @Published public var connectedWatchName = "APPLE WATCH"
    @Published public var watchBatteryLevel = 0
    /// iPhone only: a Watch is paired and has RugbyTimer installed, so the match can run on it.
    /// When false the iPhone offers iPhone-only mode as the main way to run a match.
    @Published public var isWatchAvailable = false

    private let session = WCSession.default
    private var outgoingContext: [String: Any] = [:]

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
        flushContext()
    }

    public func sendMatchSnapshot(_ snapshot: MatchSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        outgoingContext["snapshot"] = data
        flushContext()
    }

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

    private func flushContext() {
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

    private func updateWatchAvailability() {
        #if os(iOS)
        isWatchAvailable = session.activationState == .activated && session.isPaired && session.isWatchAppInstalled
        #endif
    }

    private func receive(_ context: [String: Any]) {
        #if os(watchOS)
        if let data = context["configuration"] as? Data,
           let configuration = try? JSONDecoder().decode(MatchConfiguration.self, from: data) {
            receivedConfiguration = configuration
        }
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

extension WatchConnectivityService: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
            self.updateWatchAvailability()
            self.receive(session.receivedApplicationContext)
            self.flushContext()
        }
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
            self.flushContext()
        }
    }

    #if os(iOS)
    public func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.updateWatchAvailability() }
    }

    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.receive(applicationContext) }
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { self.receive(message) }
    }
}
