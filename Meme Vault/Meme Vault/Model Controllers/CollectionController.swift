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
        let presetCollection = AlbumCollection(name: "Test", conditions: [])
        self.collections = [presetCollection]
    }
}
