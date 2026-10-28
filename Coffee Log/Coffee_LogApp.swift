//
//  Coffee_LogApp.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct Coffee_LogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CoffeeBean.self,
            Tasting.self,
            BrewLog.self,
            BrewMethod.self,
            GrindSize.self,
            Flavor.self,
            Inventory.self,
        ])
        // Syncs through the CloudKit container declared in the entitlements.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        UNUserNotificationCenter.current().delegate = ExpiryNotifications.delegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
