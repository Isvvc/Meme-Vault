//
//  CollectionsController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos

class CollectionController {
    
    var collections: [AlbumCollection]
    var cache = Cache<String, Set<PHAsset>>()
    
    // Load a test collection based on albums I have on my phone.
    // This won't work on any other devices
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
    
    /// Fetches the first image in the user's photos that is in a collection.
    /// - Parameter collection: The `albumCollection` to find an image from.
    /// - Returns: a `PHAsset` of the first (oldest or newest depending on the collection's `oldestFirst` property) that is in a collection. If no images are in the collection, returns `nil`.
    func fetchFirstImage(from collection: AlbumCollection) -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: collection.oldestFirst)]
        let allAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        var i = 0
        while i < allAssets.count {
            let asset = allAssets.object(at: i)
            if collection.contains(asset: asset, cache: cache) {
                cache.clear()
                return asset
            }
            print(asset)
            
            i += 1
        }
        
        cache.clear()
        return nil
    }
    
}
