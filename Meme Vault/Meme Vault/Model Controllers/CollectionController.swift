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
            Condition(conjunction: .none, not: false, id: "C87BD295-F2CA-4D24-AEE3-A4371C6A2D7D/L0/040"),
            Condition(conjunction: .and, not: true, id: "47C055F1-FC48-4BFE-B219-0867BF37A74F/L0/040"),
            Condition(conjunction: .and, not: false, id: nil),
            Condition(conjunction: .none, not: false, id: "DB8FB850-AEA8-44A9-9246-0174FD551ACE/L0/040"),
            Condition(conjunction: .or, not: false, id: "54F882E2-B85A-4DD1-ACD2-852669EF406D/L0/040"),
            Condition(conjunction: .none, not: false, id: nil)
        ]
        let presetCollection = AlbumCollection(name: "Test", conditions: presetConditions)
        self.collections = [presetCollection]
    }
}
