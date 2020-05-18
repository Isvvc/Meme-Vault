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
    var oldestFirst: Bool = true
    
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
    
    /// Checks if the collection contains the given `PHAsset`. In other words, checks if the given `PHAsset` matches the requirements for this collection.
    /// - Parameters:
    ///   - asset: The asset to be checking
    ///   - cache: A cache for storing `PHAssets` from specific albums
    ///   - inputConditions: The conditions to be checking the asset against. If left empty or set to `nil`, uses this collection's assets.
    /// - Returns: `true` if this collection contains the given `asset`.
    func contains(asset: PHAsset, cache: Cache<String, Set<PHAsset>>, conditions inputConditions: [Condition]? = nil) -> Bool {
        let conditions: [Condition]
        if let inputConditions = inputConditions {
            conditions = inputConditions
        } else {
            conditions = self.conditions
        }
        
        var i = 0
        var failed = false
        
        while i < conditions.count {
            let condition = conditions[i]
            
            // `failed` being true means a condition wasn't met,
            // so it's moving forward to the next "OR" to see if that condition is met
            
            if condition.conjunction == .or, !failed {
                // Everything up to this point matched,
                // so we don't need to check anything after the OR
                return true
            }
            
            failed = false
            
            let matches: Bool
            
            if condition.id == nil {
                // Opening parenthesis
                // Get index of the closing parenthesis
                let splitConditions = conditions.dropFirst(i + 1)
                guard let j = splitConditions.lastIndex(where: { $0.conjunction == nil && $0.id == nil }) else { return false }
                let newConditions = Array(splitConditions.prefix(upTo: j))
                
                matches = contains(asset: asset, cache: cache, conditions: newConditions)
                i += j
            } else {
                matches = condition.matches(asset: asset, cache: cache)
            }
            
            if !matches {
                // Move i to the next OR to see if that matches
                if let j = findNextOr(startingAt: i + 1, conditions: conditions) {
                    i = j
                    failed = true
                    continue
                }
                
                // If there is no OR later
                return false
            }
            
            i += 1
        }
        
        // If all the conditions matched
        return !failed
    }
    
    /// Finds the next `or` condition in an array of conditions. Useful if a condition fails so the next condition can be checked.
    /// - Parameters:
    ///   - startIndex: The index of the input conditons array to start searching from
    ///   - inputConditions: The conditions to be checking the asset against. If left empty or set to `nil`, uses this collection's assets.
    /// - Returns: The index of the next `or` condition in the array if one exists, otherwise `nil`.
    func findNextOr(startingAt startIndex: Int, conditions inputConditions: [Condition]? = nil) -> Int? {
        let conditions: [Condition]
        if let inputConditions = inputConditions {
            conditions = inputConditions
        } else {
            conditions = self.conditions
        }
        
        var i = startIndex
        while i < conditions.count {
            let condition = conditions[i]
            
            if condition.conjunction == .or {
                return i
            }
            
            if condition.id == nil {
                // Opening parenthesis
                // Get index of the closing parenthesis to continue from there
                guard let j = conditions.dropFirst(i + 1).lastIndex(where: { $0.conjunction == nil && $0.id == nil }) else { return nil }
                i = j
            }
            
            i += 1
        }
        
        return nil
    }
}
