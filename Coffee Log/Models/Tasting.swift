//
//  Tasting.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class Tasting {
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
}
