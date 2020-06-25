//
//  CollectionRepresentation.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 6/25/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class CollectionRepresentation: Codable {
    var name: String
    var conditions: [Condition]
    var oldestFirst: Bool
    var destination: String?
    
    init(collection: AlbumCollection) {
        name = collection.name
        conditions = collection.conditions
        oldestFirst = collection.oldestFirst
        destination = collection.destination?.path
    }
}
