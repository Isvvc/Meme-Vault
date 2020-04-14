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
}
