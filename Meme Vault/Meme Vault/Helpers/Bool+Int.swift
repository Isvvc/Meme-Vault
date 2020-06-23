//
//  Bool+Int.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/21/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

extension Bool {
    var int: Int { self ? 1 : 0 }
}

extension Int {
    var bool: Bool { self == 0 ? false : true }
}
