//
//  DefaultData.swift
//  Coffee Log
//

import Foundation
import SwiftData

/// Preset values for pickers and first-launch seed data.
enum DefaultData {
    static let roastLevels = ["Light", "Light-Medium", "Medium", "Medium-Dark", "Dark"]
    static let processingMethods = ["Washed", "Natural", "Honey", "Wet-Hulled", "Anaerobic"]
    static let origins = [
        "Ethiopia", "Colombia", "Kenya", "Brazil", "Guatemala", "Costa Rica",
        "Panama", "Honduras", "Peru", "Rwanda", "Burundi", "Tanzania", "Uganda"
    ]
    static let brewMethods = ["V60", "AeroPress", "Espresso", "French Press", "Cold Brew", "Chemex", "Moka Pot", "Pour Over"]
    static let flavors = [
        "Fruity", "Floral", "Nutty", "Chocolaty", "Spicy", "Caramel",
        "Honey", "Citrus", "Berry", "Blueberry", "Strawberry", "Bergamot",
        "Cocoa", "Almond", "Grapefruit", "Black Currant", "Vanilla", "Cinnamon"
    ]
    static let grindSizes = ["Extra Fine", "Fine", "Medium-Fine", "Medium", "Medium-Coarse", "Coarse"]

    private static let seededKey = "didSeedDefaultData"

    /// Inserts the default brew methods, flavors and grind sizes once per device.
    /// With CloudKit sync, a second device that launches before the first sync finishes
    /// could create duplicates, so each name is only inserted when it doesn't exist yet.
    @MainActor
    static func seedIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }

        let existingMethods = Set(((try? context.fetch(FetchDescriptor<BrewMethod>())) ?? []).map(\.name))
        let existingFlavors = Set(((try? context.fetch(FetchDescriptor<Flavor>())) ?? []).map(\.name))
        let existingGrinds = Set(((try? context.fetch(FetchDescriptor<GrindSize>())) ?? []).map(\.name))

        for name in brewMethods where !existingMethods.contains(name) {
            context.insert(BrewMethod(name: name))
        }
        for name in flavors where !existingFlavors.contains(name) {
            context.insert(Flavor(name: name))
        }
        for name in grindSizes where !existingGrinds.contains(name) {
            context.insert(GrindSize(name: name))
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: seededKey)
    }
}
