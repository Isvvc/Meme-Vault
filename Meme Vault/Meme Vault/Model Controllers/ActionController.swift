//
//  ActionController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

class ActionController {
    
    var actionSets: [ActionSet]
    var defaultActionSetIndex: Int
    var defaultActionSet: ActionSet? {
        switch actionSets.count {
        case 0:
            return nil
        case 0...defaultActionSetIndex:
            defaultActionSetIndex = 0
        default:
            break
        }
        
        return actionSets[defaultActionSetIndex]
    }
    
    init() {
        let presetActionSet = ActionSet(name: "Queue", actions: [.name(), .destination, .upload, .share, .delete])
        self.actionSets = [presetActionSet]
        self.defaultActionSetIndex = 0
    }
    
    @discardableResult func createActionSet(name: String = "New Action Set", actions: [ActionSet.Action] = []) -> ActionSet {
        let action = ActionSet(name: name, actions: actions)
        actionSets.append(action)
        return action
    }
    
    func setDefault(actionSet: ActionSet) {
        guard let index = actionSets.firstIndex(of: actionSet) else { return }
        defaultActionSetIndex = index
    }
    
}
