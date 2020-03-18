//
//  ActionSet.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class ActionSet: Equatable {
    
    public enum Action: CaseIterable {
        case name
        case share
        case destination
        case upload
        case delete
        
        var name: String {
            switch self {
            case .name:
                return "Set name"
            case .share:
                return "Share square"
            case .destination:
                return "Choose upload destination"
            case .upload:
                return "Upload"
            case .delete:
                return "Delete"
            }
        }
    }
    
    var name: String
    var actions: [Action]
    
    init(name: String, actions: [Action] = []) {
        self.name = name
        self.actions = actions
    }
    
    static func == (lhs: ActionSet, rhs: ActionSet) -> Bool {
        return lhs.name == rhs.name && lhs.actions == rhs.actions
    }
    
}
