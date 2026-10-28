//
//  CoffeeAnalytics.swift
//  Coffee Log
//

import Foundation

/// A named group with its average rating and sample count.
struct RatedGroup: Identifiable {
    let name: String
    let averageRating: Double
    let count: Int
    var id: String { name }
}

/// Aggregate statistics and recommendations computed from the user's beans and tastings.
struct CoffeeAnalytics {
    let beans: [CoffeeBean]
    let tastings: [Tasting]

    var averageRating: Double {
        guard !tastings.isEmpty else { return 0 }
        return tastings.map(\.rating).reduce(0, +) / Double(tastings.count)
    }

    /// The bean tasted most recently.
    var todayCoffee: CoffeeBean? {
        beans
            .filter { !($0.tastings ?? []).isEmpty }
            .max { ($0.latestTasting?.timestamp ?? .distantPast) < ($1.latestTasting?.timestamp ?? .distantPast) }
    }

    func favorites(count: Int = 3) -> [CoffeeBean] {
        Array(
            beans
                .filter { ($0.tastings ?? []).contains { $0.rating >= 4.5 } }
                .sorted { $0.averageRating > $1.averageRating }
                .prefix(count)
        )
    }

    // MARK: Grouped averages

    private func groupBeans(by key: (CoffeeBean) -> String) -> [RatedGroup] {
        Dictionary(grouping: beans.filter { !($0.tastings ?? []).isEmpty }, by: key)
            .filter { !$0.key.isEmpty }
            .map { RatedGroup(name: $0.key, averageRating: $0.value.map(\.averageRating).reduce(0, +) / Double($0.value.count), count: $0.value.count) }
            .sorted { $0.averageRating > $1.averageRating }
    }

    private func groupTastings(by key: (Tasting) -> [String]) -> [RatedGroup] {
        var buckets: [String: [Double]] = [:]
        for tasting in tastings {
            for name in key(tasting) { buckets[name, default: []].append(tasting.rating) }
        }
        return buckets
            .map { RatedGroup(name: $0.key, averageRating: $0.value.reduce(0, +) / Double($0.value.count), count: $0.value.count) }
            .sorted { $0.averageRating > $1.averageRating }
    }

    var originGroups: [RatedGroup] { groupBeans { $0.originCountry } }
    var roastGroups: [RatedGroup] { groupBeans { $0.roastLevel } }
    var processingGroups: [RatedGroup] { groupBeans { $0.processingMethod } }
    var methodGroups: [RatedGroup] { groupTastings { [$0.brewLog?.brewMethod?.name].compactMap { $0 } } }
    var flavorGroups: [RatedGroup] { groupTastings { ($0.flavors ?? []).map(\.name) } }
    var ratioGroups: [RatedGroup] { groupTastings { [$0.brewLog?.ratio].compactMap { $0 } } }

    /// Flavors sorted by how often they were tagged.
    var mostCommonFlavors: [RatedGroup] {
        flavorGroups.sorted { $0.count > $1.count }
    }

    var favoriteOrigin: String { originGroups.first?.name ?? "N/A" }
    var favoriteRoast: String { roastGroups.first?.name ?? "N/A" }
    var topBrewMethod: String { methodGroups.first?.name ?? "None logged" }
    var flavorHighlight: String { mostCommonFlavors.first?.name ?? "Untracked" }

    // MARK: Recommendations

    func recommendations() -> [String] {
        guard !tastings.isEmpty else {
            return ["Start logging tastings to get personalized recommendations!"]
        }

        func avg(_ group: RatedGroup) -> String { group.averageRating.formatted(.number.precision(.fractionLength(1))) }
        var result: [String] = []

        if let top = roastGroups.first, top.count >= 2 {
            result.append("You seem to enjoy \(top.name.lowercased()) roasts the most (avg \(avg(top))/5).")
        }
        if let top = originGroups.first, top.count >= 2 {
            result.append("Your highest-rated coffees come from \(top.name) (avg \(avg(top))/5).")
        }
        if let top = processingGroups.first, top.count >= 2 {
            result.append("You prefer \(top.name.lowercased()) processed beans (avg \(avg(top))/5).")
        }
        if let top = methodGroups.first, top.count >= 2 {
            result.append("Your highest-rated brews use \(top.name) (avg \(avg(top))/5).")
        }
        if let top = flavorGroups.first, top.count >= 2 {
            result.append("You consistently rate \(top.name.lowercased()) notes highly (avg \(avg(top))/5).")
        }
        if let top = ratioGroups.first, top.count >= 2 {
            result.append("Your best results come from a \(top.name) brew ratio (avg \(avg(top))/5).")
        }

        return result.isEmpty ? ["Keep logging tastings to discover your preferences!"] : result
    }
}
