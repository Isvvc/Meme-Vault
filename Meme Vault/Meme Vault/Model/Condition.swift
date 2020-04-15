//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class Condition: Equatable {
    
    public enum Conjunction: String, CaseIterable {
        case and
        case or
    }
    
    var conjunction: Conjunction?
    var not: Bool
    var id: String?
    
    init(conjunction: Conjunction? = .none, not: Bool, id: String?) {
        self.conjunction = conjunction
        self.not = not
        self.id = id
    }
    
    static func == (lhs: Condition, rhs: Condition) -> Bool {
        return lhs.id == rhs.id && lhs.conjunction == rhs.conjunction && lhs.not == rhs.not
    }
    
}
