//
//  BrewLog.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class BrewLog: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id, tasting, brewMethod, dose, water, temperature, brewTime, grindSize
    }
    
    var id: UUID
    var tasting: Tasting
    var brewMethod: BrewMethod
    var dose: Int?
    var water: Int?
    var temperature: Int?
    var brewTime: Int?
    var grindSize: GrindSize?
    
    init(id: UUID = UUID(), tasting: Tasting, brewMethod: BrewMethod, dose: Int? = nil, water: Int? = nil, temperature: Int? = nil, brewTime: Int? = nil, grindSize: GrindSize? = nil) {
        self.id = id
        self.tasting = tasting
        self.brewMethod = brewMethod
        self.dose = dose
        self.water = water
        self.temperature = temperature
        self.brewTime = brewTime
        self.grindSize = grindSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        tasting = try container.decode(Tasting.self, forKey: .tasting)
        brewMethod = try container.decode(BrewMethod.self, forKey: .brewMethod)
        dose = try container.decodeIfPresent(Int.self, forKey: .dose)
        water = try container.decodeIfPresent(Int.self, forKey: .water)
        temperature = try container.decodeIfPresent(Int.self, forKey: .temperature)
        brewTime = try container.decodeIfPresent(Int.self, forKey: .brewTime)
        grindSize = try container.decodeIfPresent(GrindSize.self, forKey: .grindSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(tasting, forKey: .tasting)
        try container.encode(brewMethod, forKey: .brewMethod)
        try container.encodeIfPresent(dose, forKey: .dose)
        try container.encodeIfPresent(water, forKey: .water)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(brewTime, forKey: .brewTime)
        try container.encodeIfPresent(grindSize, forKey: .grindSize)
    }
}
