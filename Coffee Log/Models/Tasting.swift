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
        case id, rating, aroma, acidity, sweetness, timestamp, flavors
    }
    
    var id: UUID
    var rating: Int
    var aroma: String?
    var acidity: Int?
    var sweetness: Int?
    var timestamp: Date
    var flavors: [Flavor]
    
    init(id: UUID = UUID(), rating: Int, aroma: String? = nil, acidity: Int? = nil, sweetness: Int? = nil, timestamp: Date, flavors: [Flavor]) {
        self.id = id
        self.rating = rating
        self.aroma = aroma
        self.acidity = acidity
        self.sweetness = sweetness
        self.timestamp = timestamp
        self.flavors = flavors
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rating = try container.decode(Int.self, forKey: .rating)
        aroma = try container.decodeIfPresent(String.self, forKey: .aroma)
        acidity = try container.decodeIfPresent(Int.self, forKey: .acidity)
        sweetness = try container.decodeIfPresent(Int.self, forKey: .sweetness)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        flavors = try container.decode([Flavor].self, forKey: .flavors)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rating, forKey: .rating)
        try container.encodeIfPresent(aroma, forKey: .aroma)
        try container.encodeIfPresent(acidity, forKey: .acidity)
        try container.encodeIfPresent(sweetness, forKey: .sweetness)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(flavors, forKey: .flavors)
    }
}
