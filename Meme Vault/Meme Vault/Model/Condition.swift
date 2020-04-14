//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class Condition {
    
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
    
}
