import Foundation
import HealthKit

/// Runs the match as a Rugby workout. watchOS keeps a workout app running for as long as it
/// lasts, with the screen in always-on mode, and the workout (time, distance, heart rate,
/// energy) is saved to Health at full time.
final class WatchWorkoutSession {
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var isStarting = false
    private var didRequestAuthorization = false

    private static let shareTypes: Set<HKSampleType> = [
        .workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceWalkingRunning)
    ]
    private static let readTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceWalkingRunning)
    ]

    /// A workout is running, or about to.
    var isActive: Bool { session != nil || isStarting }

    /// Workouts need permission to save to Health; without it the runtime falls back.
    var isAuthorized: Bool {
        HKHealthStore.isHealthDataAvailable() && store.authorizationStatus(for: .workoutType()) == .sharingAuthorized
    }

    /// Asks once, before kick-off, so the prompt never shows up as play starts.
    func requestAuthorizationIfNeeded() async {
        guard HKHealthStore.isHealthDataAvailable(), !didRequestAuthorization,
              store.authorizationStatus(for: .workoutType()) == .notDetermined else { return }
        didRequestAuthorization = true
        try? await store.requestAuthorization(toShare: Self.shareTypes, read: Self.readTypes)
    }

    /// Starts the workout, or picks up the one still running after a crash or relaunch.
    /// Returns false when no workout could be started.
    func start() async -> Bool {
        if isActive { return true }
        guard isAuthorized else { return false }
        isStarting = true
        defer { isStarting = false }
        if let recovered = try? await store.recoverActiveWorkoutSession() {
            adopt(recovered)
            return true
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .rugby
        configuration.locationType = .outdoor
        guard let newSession = try? HKWorkoutSession(healthStore: store, configuration: configuration) else {
            return false
        }
        adopt(newSession)
        let start = Date()
        newSession.startActivity(with: start)
        try? await newSession.associatedWorkoutBuilder().beginCollection(at: start)
        return true
    }

    /// Ends the workout: saved to Health at full time, discarded when the match was abandoned
    /// before it finished (left on the Watch, or replaced by a new setup).
    func end(saving: Bool) async {
        guard let session, let builder else { return }
        self.session = nil
        self.builder = nil
        session.end()
        try? await builder.endCollection(at: Date())
        if saving {
            _ = try? await builder.finishWorkout()
        } else {
            builder.discardWorkout()
        }
    }

    private func adopt(_ workoutSession: HKWorkoutSession) {
        session = workoutSession
        let workoutBuilder = workoutSession.associatedWorkoutBuilder()
        if workoutBuilder.dataSource == nil {
            workoutBuilder.dataSource = HKLiveWorkoutDataSource(
                healthStore: store, workoutConfiguration: workoutSession.workoutConfiguration
            )
        }
        builder = workoutBuilder
    }
}
