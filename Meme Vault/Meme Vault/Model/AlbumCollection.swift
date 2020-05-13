//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos

class AlbumCollection {
    var name: String
    var conditions: [Condition]
    
    init(name: String, conditions: [Condition]) {
        self.name = name
        self.conditions = conditions
    }
    
    func insetLevel(for inputCondition: Condition) -> Int {
        var inset = 0
        
        if inputCondition == conditions.first {
            return 0
        }
        
        for i in 1..<conditions.count {
            let previousCondition = conditions[i - 1]
            if previousCondition.id == nil,
                previousCondition.conjunction != .none {
                // Previous condition was an open parenthesis
                inset += 1
            }
            
            let condition = conditions[i]
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
    
    func conditionIsFirst(_ condition: Condition) -> Bool {
        guard let index = conditions.firstIndex(of: condition) else { return false }
        if index == 0 {
            return true
        }
        
        let previousCondition = conditions[index - 1]
        if previousCondition.id == nil,
            previousCondition.conjunction != .none {
            return true
        }
        
        return false
    }
    
    func contains(asset: PHAsset, cache: Cache<String, Set<PHAsset>>) -> Bool {
        var i = 0
        var failed = false
        
//        for condition in conditions {
        while i < conditions.count {
            let condition = conditions[i]
            
            if condition.conjunction == .or, !failed {
                // Everything up to this point matched,
                // so we don't need to check anything after the OR
                return true
            }
            
            failed = false
            
            if !condition.matches(asset: asset, cache: cache) {
                // Move i to the next OR to see if that matches
                if let j = conditions.dropFirst(i + 1).firstIndex(where: { $0.conjunction == .or }) {
                    i += j
                    failed = true
                    continue
                }
                
                // If there is no OR later
                return false
            }
            
            i += 1
        }
        
        // If all the conditions matched
        return true
    }
}
