//
//  Item.swift
//  Coffee Log
//
//  Created by Илья Анисимов on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
