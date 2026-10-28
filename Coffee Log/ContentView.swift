//
//  ContentView.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var inventory: [Inventory]

    /// Changes whenever something that affects expiry notifications changes.
    private var notificationSignature: [String] {
        inventory.map { "\($0.id)|\($0.expirationDate?.timeIntervalSince1970 ?? 0)|\($0.quantityGrams > 0)|\($0.coffeeBean?.name ?? "")" }
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "cup.and.saucer") }
            CoffeeLibraryView()
                .tabItem { Label("Library", systemImage: "books.vertical") }
            JournalView()
                .tabItem { Label("Journal", systemImage: "book") }
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar") }
            InventoryView()
                .tabItem { Label("Inventory", systemImage: "shippingbox") }
        }
        .task {
            DefaultData.seedIfNeeded(in: modelContext)
        }
        .task(id: notificationSignature) {
            await ExpiryNotifications.reschedule(for: inventory)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CoffeeBean.self, Tasting.self, BrewLog.self, BrewMethod.self, GrindSize.self, Flavor.self, Inventory.self], inMemory: true)
}
