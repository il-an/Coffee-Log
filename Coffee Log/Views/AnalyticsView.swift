//
//  AnalyticsView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var beans: [CoffeeBean]
    @Query private var tastings: [Tasting]

    private var analytics: CoffeeAnalytics { CoffeeAnalytics(beans: beans, tastings: tastings) }

    var body: some View {
        NavigationStack {
            List {
                Section("Recommendations") {
                    ForEach(analytics.recommendations(), id: \.self) { Text($0) }
                }
                Section("Summary Statistics") {
                    LabeledValue("Average Rating", analytics.averageRating.formatted(.number.precision(.fractionLength(1))) + "/5.0")
                    LabeledValue("Favorite Origin", analytics.favoriteOrigin)
                    LabeledValue("Favorite Roast", analytics.favoriteRoast)
                    LabeledValue("Top Brew Method", analytics.topBrewMethod)
                }
                groupSection("Top Origins", analytics.originGroups)
                groupSection("Roast Preferences", analytics.roastGroups)
                groupSection("Top Brew Methods", analytics.methodGroups)
                Section("Most Common Flavor Tags") {
                    let flavors = Array(analytics.mostCommonFlavors.prefix(5))
                    if flavors.isEmpty { Text("No data yet").foregroundStyle(.secondary) }
                    ForEach(flavors) { LabeledValue(LocalizedStringKey($0.name), "\($0.count)×") }
                }
            }
            .navigationTitle("Analytics")
        }
    }

    @ViewBuilder
    private func groupSection(_ title: LocalizedStringKey, _ groups: [RatedGroup]) -> some View {
        Section(title) {
            if groups.isEmpty { Text("No data yet").foregroundStyle(.secondary) }
            ForEach(groups.prefix(5)) { group in
                LabeledContent(group.name) {
                    Text("\(group.averageRating.formatted(.number.precision(.fractionLength(1)))) (\(group.count))")
                }
            }
        }
    }
}
