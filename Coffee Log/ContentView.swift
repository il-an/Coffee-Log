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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CoffeeBean.self, Tasting.self, BrewLog.self, BrewMethod.self, GrindSize.self, Flavor.self, Inventory.self], inMemory: true)
}
