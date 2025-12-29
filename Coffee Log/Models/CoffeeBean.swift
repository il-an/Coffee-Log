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
        case id, name, roaster, originCountry, region, processingMethod, roastLevel, tastings
    }
    
    var id: UUID
    var name: String
    var roaster: String
    var originCountry: String
    var region: String?
    var processingMethod: String
    var roastLevel: String
    var tastings: [Tasting]
    
    init(
        id: UUID = UUID(),
        name: String,
        roaster: String,
        originCountry: String,
        region: String? = nil,
        processingMethod: String,
        roastLevel: String
    ) {
        self.id = id
        self.name = name
        self.roaster = roaster
        self.originCountry = originCountry
        self.region = region
        self.processingMethod = processingMethod
        self.roastLevel = roastLevel
        self.tastings = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        roaster = try container.decode(String.self, forKey: .roaster)
        originCountry = try container.decode(String.self, forKey: .originCountry)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        processingMethod = try container.decode(String.self, forKey: .processingMethod)
        roastLevel = try container.decode(String.self, forKey: .roastLevel)
        tastings = try container.decode([Tasting].self, forKey: .tastings)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(roaster, forKey: .roaster)
        try container.encode(originCountry, forKey: .originCountry)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encode(processingMethod, forKey: .processingMethod)
        try container.encode(roastLevel, forKey: .roastLevel)
        try container.encode(tastings, forKey: .tastings)
    }
}
