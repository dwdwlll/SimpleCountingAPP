//
//  CountItem.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import Foundation

struct CountItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var count: Int
    
    init(id: UUID = UUID(), name: String, count: Int = 0) {
        self.id = id
        self.name = name
        self.count = count
    }
}
