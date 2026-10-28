//
//  ExpiryNotifications.swift
//  Coffee Log
//

import Foundation
import UserNotifications

/// Schedules local notifications that warn about coffee approaching its expiration date.
enum ExpiryNotifications {
    private static let identifierPrefix = "expiry-"
    /// How many days before the expiration date the early warning fires.
    private static let warningDays = 7
    /// Local time of day the notifications are delivered.
    private static let deliveryHour = 9

    /// Shows notifications as banners even while the app is open.
    final class Delegate: NSObject, UNUserNotificationCenterDelegate {
        nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            [.banner, .list, .sound]
        }
    }

    static let delegate = Delegate()

    /// Replaces all pending expiry notifications with ones matching `inventory`.
    /// Safe to call whenever the inventory changes, including after a CloudKit sync.
    static func reschedule(for inventory: [Inventory]) async {
        let center = UNUserNotificationCenter.current()

        let pending = await center.pendingNotificationRequests()
        let stale = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: stale)

        // Empty bags no longer need a warning.
        let tracked = inventory.filter { $0.expirationDate != nil && $0.quantityGrams > 0 }
        guard !tracked.isEmpty, await isAuthorized(center) else { return }

        for item in tracked {
            guard let expiration = item.expirationDate else { continue }
            let name = item.coffeeBean?.name ?? String(localized: "Your coffee")

            if let warningDate = deliveryDate(daysBefore: warningDays, expiration: expiration) {
                await schedule(
                    id: "\(identifierPrefix)\(item.id.uuidString)-soon",
                    title: String(localized: "Coffee expiring soon"),
                    body: String(localized: "\(name) expires in \(warningDays) days. Time to brew it!"),
                    at: warningDate,
                    center: center
                )
            }
            if let expiryDate = deliveryDate(daysBefore: 0, expiration: expiration) {
                await schedule(
                    id: "\(identifierPrefix)\(item.id.uuidString)-expired",
                    title: String(localized: "Coffee expires today"),
                    body: String(localized: "\(name) expires today."),
                    at: expiryDate,
                    center: center
                )
            }
        }
    }

    /// Asks for permission the first time it is needed.
    private static func isAuthorized(_ center: UNUserNotificationCenter) async -> Bool {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        default:
            return false
        }
    }

    /// The delivery time `daysBefore` days ahead of the expiration date, or nil if it has already passed.
    private static func deliveryDate(daysBefore: Int, expiration: Date) -> Date? {
        let calendar = Calendar.current
        guard let day = calendar.date(byAdding: .day, value: -daysBefore, to: calendar.startOfDay(for: expiration)),
              let date = calendar.date(bySettingHour: deliveryHour, minute: 0, second: 0, of: day),
              date > .now else { return nil }
        return date
    }

    private static func schedule(id: String, title: String, body: String, at date: Date, center: UNUserNotificationCenter) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
