//
//  BrewLog.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class BrewLog {
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
}
