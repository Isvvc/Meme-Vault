//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class AlbumCollection {
    var name: String
    var conditions: [Condition]
    
    init(name: String, conditions: [Condition]) {
        self.name = name
        self.conditions = conditions
    }
}
