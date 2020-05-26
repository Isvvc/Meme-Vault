//
//  Cache.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 5/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    var dictionary: [Key: Value] = [:]
    
    func cache(_ value: Value, forKey key: Key) {
        dictionary[key] = value
    }
    
    func value(forKey key: Key) -> Value? {
        return dictionary[key]
    }
    
    func clear() {
        dictionary.removeAll()
    }
}
