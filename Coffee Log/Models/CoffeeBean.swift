//
//  CoffeeBean.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class CoffeeBean: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id, name, roaster, originCountry, region, variety, processingMethod, roastLevel, elevationMeters, price, tastings, inventory
    }
    
    var id: UUID = UUID()
    var name: String = ""
    var roaster: String = ""
    var originCountry: String = ""
    var region: String?
    var variety: String?
    var processingMethod: String = ""
    var roastLevel: String = ""
    var elevationMeters: Int?
    var price: Double?
    
    @Relationship(deleteRule: .cascade, inverse: \Tasting.coffeeBean)
    var tastings: [Tasting]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Inventory.coffeeBean)
    var inventory: Inventory?
    
    init(
        id: UUID = UUID(),
        name: String,
        roaster: String,
        originCountry: String,
        region: String? = nil,
        variety: String? = nil,
        processingMethod: String,
        roastLevel: String,
        elevationMeters: Int? = nil,
        price: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.roaster = roaster
        self.originCountry = originCountry
        self.region = region
        self.variety = variety
        self.processingMethod = processingMethod
        self.roastLevel = roastLevel
        self.elevationMeters = elevationMeters
        self.price = price
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        roaster = try container.decode(String.self, forKey: .roaster)
        originCountry = try container.decode(String.self, forKey: .originCountry)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        variety = try container.decodeIfPresent(String.self, forKey: .variety)
        processingMethod = try container.decode(String.self, forKey: .processingMethod)
        roastLevel = try container.decode(String.self, forKey: .roastLevel)
        elevationMeters = try container.decodeIfPresent(Int.self, forKey: .elevationMeters)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        tastings = try container.decode([Tasting].self, forKey: .tastings)
        inventory = try container.decodeIfPresent(Inventory.self, forKey: .inventory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(roaster, forKey: .roaster)
        try container.encode(originCountry, forKey: .originCountry)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(variety, forKey: .variety)
        try container.encode(processingMethod, forKey: .processingMethod)
        try container.encode(roastLevel, forKey: .roastLevel)
        try container.encodeIfPresent(elevationMeters, forKey: .elevationMeters)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encode(tastings ?? [], forKey: .tastings)
        try container.encodeIfPresent(inventory, forKey: .inventory)
    }
    
    /// Mean rating across all tastings, or 0 when there are none.
    var averageRating: Double {
        let tastings = tastings ?? []
        guard !tastings.isEmpty else { return 0 }
        return tastings.map(\.rating).reduce(0, +) / Double(tastings.count)
    }
    
    var latestTasting: Tasting? {
        (tastings ?? []).max { $0.timestamp < $1.timestamp }
    }
    
    /// The highest-rated tasting that has brew details, used as the "best recipe".
    var bestRecipeTasting: Tasting? {
        (tastings ?? [])
            .filter { $0.brewLog != nil }
            .max { $0.rating < $1.rating }
    }
}
