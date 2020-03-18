//
//  ActionController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class ActionController {
    var actionSets: [ActionSet] = [ActionSet(name: "Queue", actions: [.name, .destination, .upload, .share, .delete])]
    
    @discardableResult func createActionSet(name: String = "New Action Set", actions: [ActionSet.Action] = []) -> ActionSet {
        let action = ActionSet(name: name, actions: actions)
        actionSets.append(action)
        return action
    }
}
