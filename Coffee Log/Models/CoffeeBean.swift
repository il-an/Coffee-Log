//
//  CoffeeBean.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class CoffeeBean {
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
}
