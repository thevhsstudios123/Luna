import Foundation

// Protocol seam for future HealthKit integration. No HealthKit imports here
// so the prototype doesn't require the entitlement or the framework.
// When adding HealthKit later, create a HealthKitProvider that conforms to this
// protocol and inject it in LunaApp.swift via the environment or a service locator.
protocol HealthProvider {
    func requestAuthorization() async throws
    func fetchSleepHours(for day: Date) async throws -> Double?
    func fetchMenstrualFlow(on day: Date) async throws -> FlowIntensity?
}

final class NoOpHealthProvider: HealthProvider {
    func requestAuthorization() async throws { /* no-op in prototype */ }
    func fetchSleepHours(for day: Date) async throws -> Double? { nil }
    func fetchMenstrualFlow(on day: Date) async throws -> FlowIntensity? { nil }
}
