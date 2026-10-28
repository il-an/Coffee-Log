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
        case id, brewMethod, dose, water, temperature, brewTime, grindSize
    }
    
    var id: UUID = UUID()
    var tasting: Tasting?
    var brewMethod: BrewMethod?
    /// Coffee dose in grams.
    var dose: Double?
    /// Water in grams.
    var water: Double?
    /// Water temperature in °C.
    var temperature: Double?
    /// Brew time in seconds.
    var brewTime: Int?
    var grindSize: GrindSize?
    
    init(id: UUID = UUID(), tasting: Tasting? = nil, brewMethod: BrewMethod? = nil, dose: Double? = nil, water: Double? = nil, temperature: Double? = nil, brewTime: Int? = nil, grindSize: GrindSize? = nil) {
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
        brewMethod = try container.decodeIfPresent(BrewMethod.self, forKey: .brewMethod)
        dose = try container.decodeIfPresent(Double.self, forKey: .dose)
        water = try container.decodeIfPresent(Double.self, forKey: .water)
        temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
        brewTime = try container.decodeIfPresent(Int.self, forKey: .brewTime)
        grindSize = try container.decodeIfPresent(GrindSize.self, forKey: .grindSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(brewMethod, forKey: .brewMethod)
        try container.encodeIfPresent(dose, forKey: .dose)
        try container.encodeIfPresent(water, forKey: .water)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(brewTime, forKey: .brewTime)
        try container.encodeIfPresent(grindSize, forKey: .grindSize)
    }
    
    /// Water-to-coffee ratio such as "1:16", when both amounts are known.
    var ratio: String? {
        guard let dose, let water, dose > 0 else { return nil }
        return "1:" + (water / dose).formatted(.number.precision(.fractionLength(0...1)))
    }
    
    /// Brew time formatted as m:ss.
    var brewTimeText: String? {
        guard let brewTime else { return nil }
        return String(format: "%d:%02d", brewTime / 60, brewTime % 60)
    }
}
