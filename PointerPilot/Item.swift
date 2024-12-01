//
//  Item.swift
//  PointerPilot
//
//  Created by Randall Noval on 12/1/24.
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
