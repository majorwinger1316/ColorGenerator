//
//  Item.swift
//  Color_Generator
//
//  Created by Akshat Dutt Kaushik on 30/07/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var hexCode: String
    var timestamp: Date
    var isSynced: Bool

    init(hexCode: String, timestamp: Date = Date(), isSynced: Bool = false) {
        self.hexCode = hexCode
        self.timestamp = timestamp
        self.isSynced = isSynced
    }
}
