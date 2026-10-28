//
//  Inventory.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class Inventory: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id, quantityGrams, purchaseDate, expirationDate, dailyConsumptionGrams
    }
    
    var id: UUID = UUID()
    var quantityGrams: Double = 0
    var purchaseDate: Date?
    var expirationDate: Date?
    var dailyConsumptionGrams: Double?
    var coffeeBean: CoffeeBean?
    
    init(id: UUID = UUID(), coffeeBean: CoffeeBean? = nil, quantityGrams: Double, purchaseDate: Date? = nil, expirationDate: Date? = nil, dailyConsumptionGrams: Double? = nil) {
        self.id = id
        self.coffeeBean = coffeeBean
        self.quantityGrams = quantityGrams
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.dailyConsumptionGrams = dailyConsumptionGrams
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        quantityGrams = try container.decode(Double.self, forKey: .quantityGrams)
        purchaseDate = try container.decodeIfPresent(Date.self, forKey: .purchaseDate)
        expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate)
        dailyConsumptionGrams = try container.decodeIfPresent(Double.self, forKey: .dailyConsumptionGrams)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(quantityGrams, forKey: .quantityGrams)
        try container.encodeIfPresent(purchaseDate, forKey: .purchaseDate)
        try container.encodeIfPresent(expirationDate, forKey: .expirationDate)
        try container.encodeIfPresent(dailyConsumptionGrams, forKey: .dailyConsumptionGrams)
    }
    
    static let lowStockThresholdGrams = 100.0
    
    var isLowStock: Bool { quantityGrams < Self.lowStockThresholdGrams }
    
    var isExpiringSoon: Bool {
        guard let expirationDate else { return false }
        return expirationDate <= Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    }
    
    var estimatedDepletionDate: Date? {
        guard let dailyConsumptionGrams, dailyConsumptionGrams > 0 else { return nil }
        return Calendar.current.date(byAdding: .day, value: Int((quantityGrams / dailyConsumptionGrams).rounded(.up)), to: .now)
    }
}
