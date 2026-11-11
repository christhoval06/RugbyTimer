//
//  WatchConnectivityService+Delegate.swift
//  RugbyTimer
//

import Foundation
import WatchConnectivity

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
