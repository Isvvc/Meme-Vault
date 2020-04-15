//
//  CollectionsController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class CollectionController {
    var collections: [AlbumCollection]
    
    init() {
        let presetConditions = [
            Condition(conjunction: .none, not: false, id: "Main Album"),
            Condition(conjunction: .and, not: true, id: "Excluded album"),
            Condition(conjunction: .and, not: false, id: nil),
            Condition(conjunction: .none, not: false, id: "Album 1"),
            Condition(conjunction: .or, not: false, id: "Album 2"),
            Condition(conjunction: .none, not: false, id: nil)
        ]
        let presetCollection = AlbumCollection(name: "Test", conditions: presetConditions)
        self.collections = [presetCollection]
    }
    
    func insetLevel(for inputCondition: Condition, in collection: AlbumCollection) -> Int {
        var inset = 0
        
        if inputCondition == collection.conditions.first {
            return 0
        }
        
        for i in 1..<collection.conditions.count {
            let previousCondition = collection.conditions[i - 1]
            if previousCondition.id == nil,
                previousCondition.conjunction != .none {
                // Previous condition was an open parenthesis
                inset += 1
            }
            
            let condition = collection.conditions[i]
            if condition.id == nil,
                condition.conjunction == .none {
                // This condition is a close parenthesis
                inset -= 1
            }
            
            if inputCondition == condition {
                return inset
            }
        }
        
        return 0
    }
}
