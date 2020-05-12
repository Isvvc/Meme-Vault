//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos

class Condition: NSObject {
    
    public enum Conjunction: Int, CaseIterable {
        case and
        case or
        
        var string: String {
            switch self {
            case .and:
                return "and"
            default:
                return "or"
            }
        }
    }
    
    var conjunction: Conjunction?
    var not: Bool
    var id: String?
    
    init(conjunction: Conjunction? = .none, not: Bool, id: String?) {
        self.conjunction = conjunction
        self.not = not
        self.id = id
    }
    
    func matches(asset: PHAsset, cache: Cache<String, Set<PHAsset>>) -> Bool {
        guard let id = self.id  else { return false }
        let set: Set<PHAsset>
        
        if let cachedSet = cache.value(forKey: id) {
            set = cachedSet
        } else {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", id)
            let collections: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            if let collection = collections.firstObject {
                let assets = PHAsset.fetchAssets(in: collection, options: nil)
                set = Set(assets.objects(at: IndexSet(0..<assets.count)))
            } else {
                set = Set<PHAsset>()
            }
            
            cache.cache(set, forKey: id)
        }
        
        return set.contains(asset) != self.not
    }
    
}
