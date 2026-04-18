import Foundation
import UserNotifications

// Wrapper around UNUserNotificationCenter so copy runs through the VoicePack.
enum LunaNotifications {
    static func requestAuth() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleMorningForecast(at hour: Int = 8, minute: Int = 0, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "luna"
        content.body = body
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "luna.morning.forecast", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { _ in }
    }

    static func scheduleDayHeadsUp(on date: Date, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "luna"
        content.body = body
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "luna.headsup.\(date.timeIntervalSince1970)"
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req) { _ in }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
