//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos

class AlbumCollection: NSObject, Codable {
    var name: String
    var conditions: [Condition]
    var oldestFirst: Bool = true
    
    init(name: String, conditions: [Condition]) {
        self.name = name
        self.conditions = conditions
    }
    
    //MARK: CRUD
    
    @discardableResult func addCondition(conjunction: Condition.Conjunction? = .and, not: Bool = false, id: String? = nil) -> Condition {
        let condition = Condition(conjunction: conjunction, not: not, id: id)
        conditions.append(condition)
        return condition
    }
    
    @discardableResult func addParentheses() -> (opening: Condition, closing: Condition) {
        let opening = Condition(conjunction: .and, not: false, id: nil)
        let closing = Condition(conjunction: .none, not: false, id: nil)
        conditions.append(opening)
        conditions.append(closing)
        return (opening: opening, closing: closing)
    }
    
    //MARK: Helper functions
    
    private func insetLevel(startingAt: Int = 0, reversed: Bool = false, shouldBreak: (Int, Condition) -> Bool) -> (inset: Int, index: Int)? {
        let conditions: [Condition] = reversed ? self.conditions.reversed() : self.conditions
        
        var inset = 0
        
        let startingIndex = reversed ? conditions.count - startingAt - 1 : startingAt
        
        for i in startingIndex+1..<conditions.count {
            // Check for an open parenthesis
            // If the conditions are reversed, check the current condition
            // Otherwise, check the previous condition
            let potentialOpen = conditions[reversed ? i : i - 1]
            if potentialOpen.id == nil,
                potentialOpen.conjunction != .none {
                inset += 1
            }
            
            // Check for a close parenthesis
            // If the conditions are reversed, check the previous condition
            // Otherwise, check the current condition
            let potentialClosed = conditions[reversed ? i - 1 : i]
            if potentialClosed.id == nil,
                potentialClosed.conjunction == .none {
                inset -= 1
            }
            
            if shouldBreak(inset, potentialClosed) {
                let index = reversed ? conditions.count - i - 1 : i
                return (inset, index)
            }
        }
        
        return nil
    }
    
    /// Checks how deep a condition is in parentheses.
    /// - Parameter inputCondition: The condition to check the inset level of.
    /// - Returns: an `Int` of how many parenthetical layers deep the condition is.
    func insetLevel(for inputCondition: Condition) -> Int {
        if inputCondition == conditions.first {
            return 0
        }
        
        let inset = insetLevel { _, condition -> Bool in
            inputCondition == condition
        }
        
        return inset?.inset ?? 0
    }
    
    func indexOfCorrespondingClosingParenthesis(forConditionAt index: Int) -> Int {
        let inset = insetLevel(startingAt: index) { inset, condition -> Bool in
            inset == 0
        }
        
        return inset?.index ?? index
    }
    
    func indexOfCorrespondingOpeningParenthesis(forConditionAt index: Int) -> Int {
        let inset = insetLevel(startingAt: index, reversed: true) { inset, condition -> Bool in
            inset == 0
        }
        
        return inset?.index ?? index
    }
    
    /// Checks if a condition is the first, either of a whole collection or the inside of parentheses.
    /// - Parameter index: The index of the condition in the `conditions` array.
    /// - Returns: `true` if the condition is the first in the collection or the first after an opening parenthesis.
    func conditionIsFirst(index: Int) -> Bool {
        if index == 0 {
            // The first condition
            return true
        }
        
        let previousCondition = conditions[index - 1]
        if previousCondition.id == nil,
            previousCondition.conjunction != .none {
            // The condition is directly after an opening parenthesis
            return true
        }
        
        return false
    }
    
    /// Checks if a condition is the first, either of a whole collection or the inside of parentheses.
    /// - Parameter condition: The condition to check.
    /// - Returns: `true` if the condition is the first in the collection or the first after an opening parenthesis; `false` if the condition is not in this collection.
    func conditionIsFirst(_ condition: Condition) -> Bool {
        guard let index = conditions.firstIndex(of: condition) else { return false }
        return conditionIsFirst(index: index)
    }
    
    /// Generates the text representation for a condition in the collection.
    /// - Parameter index: The index of the condition in the `conditions` array.
    /// - Returns: A `String` of the text representing the condition.
    func textForCondition(at index: Int) -> String {
        let condition = conditions[index]
        
        var output = ""
        
        if let conjunction = condition.conjunction {
            if conditionIsFirst(index: index) {
                // If a condition is first, it should be treated as if it's an and
                // Don't show that "and" when printing
                condition.conjunction = .and
            } else {
                output += conjunction.string + " "
            }
        }
        
        if condition.not {
            output += "not "
            if index == 0 {
                output = output.capitalized
            }
        }
        
        if let id = condition.id {
            let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
            output += collections.firstObject?.localizedTitle ?? "Unknown Album"
        } else if condition.conjunction == .none {
            output += ")"
        } else {
            output += "("
        }
        
        return output
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
