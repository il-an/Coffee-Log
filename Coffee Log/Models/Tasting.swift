//
//  Tasting.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class Tasting: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id, rating, aroma, acidity, sweetness, body, aftertaste, notes, timestamp, flavors, brewLog
    }
    
    var id: UUID = UUID()
    /// Overall rating, 0...5.
    var rating: Double = 0
    /// Attribute scores, 1...10.
    var aroma: Int?
    var acidity: Int?
    var sweetness: Int?
    var body: Int?
    var aftertaste: Int?
    var notes: String = ""
    var timestamp: Date = Date.now
    
    var coffeeBean: CoffeeBean?
    var flavors: [Flavor]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \BrewLog.tasting)
    var brewLog: BrewLog?
    
    init(id: UUID = UUID(), rating: Double, aroma: Int? = nil, acidity: Int? = nil, sweetness: Int? = nil, body: Int? = nil, aftertaste: Int? = nil, notes: String = "", timestamp: Date = .now, coffeeBean: CoffeeBean? = nil, flavors: [Flavor] = [], brewLog: BrewLog? = nil) {
        self.id = id
        self.rating = rating
        self.aroma = aroma
        self.acidity = acidity
        self.sweetness = sweetness
        self.body = body
        self.aftertaste = aftertaste
        self.notes = notes
        self.timestamp = timestamp
        self.coffeeBean = coffeeBean
        self.flavors = flavors
        self.brewLog = brewLog
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rating = try container.decode(Double.self, forKey: .rating)
        aroma = try container.decodeIfPresent(Int.self, forKey: .aroma)
        acidity = try container.decodeIfPresent(Int.self, forKey: .acidity)
        sweetness = try container.decodeIfPresent(Int.self, forKey: .sweetness)
        body = try container.decodeIfPresent(Int.self, forKey: .body)
        aftertaste = try container.decodeIfPresent(Int.self, forKey: .aftertaste)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        flavors = try container.decode([Flavor].self, forKey: .flavors)
        brewLog = try container.decodeIfPresent(BrewLog.self, forKey: .brewLog)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rating, forKey: .rating)
        try container.encodeIfPresent(aroma, forKey: .aroma)
        try container.encodeIfPresent(acidity, forKey: .acidity)
        try container.encodeIfPresent(sweetness, forKey: .sweetness)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(aftertaste, forKey: .aftertaste)
        try container.encode(notes, forKey: .notes)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(flavors ?? [], forKey: .flavors)
        try container.encodeIfPresent(brewLog, forKey: .brewLog)
    }
}
