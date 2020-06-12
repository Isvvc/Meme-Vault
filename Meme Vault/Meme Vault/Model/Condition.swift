//
//  AlbumCollection.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos

class Condition: NSObject, Codable {
    
    public enum Conjunction: Int, CaseIterable, Codable {
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
    
    /// Checks if the given asset meets this conditon.
    /// - Parameters:
    ///   - asset: The asset to check
    ///   - cache: A cache for storing `PHAssets` from specific albums
    /// - Returns: `true` if the asset meets this condition.
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
    
    override var description: String {
        var output = String()
        if let conjunction = conjunction {
            output += conjunction.string + " "
        }
        if not {
            output += "not "
        }
        if let id = id {
            output += "album ID: \(id)"
        }
        return output
    }
    
}
