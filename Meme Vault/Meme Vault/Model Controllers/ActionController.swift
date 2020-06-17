//
//  ActionController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActionController {
    
    var actionSets: [ActionSet]
    private(set) var defaultActionSetIndex: Int
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
        self.actionSets = []
        self.defaultActionSetIndex = 0
        
        loadFromPersistentStore()
        
        if actionSets.isEmpty {
            let presetActionSet = ActionSet(name: "Queue", actions: [.name(), .destination, .upload, .share, .delete])
            self.actionSets = [presetActionSet]
            
            saveToPersistentStore()
        }
    }
    
    //MARK: CRUD
    
    @discardableResult func createActionSet(name: String = "New Action Set", actions: [ActionSet.Action] = []) -> ActionSet {
        let action = ActionSet(name: name, actions: actions)
        actionSets.append(action)
        saveToPersistentStore()
        return action
    }
    
    func deleteActionSet(at index: Int) {
        actionSets.remove(at: index)
        saveToPersistentStore()
    }
    
    func setDefault(actionSet: ActionSet) {
        guard let index = actionSets.firstIndex(of: actionSet) else { return }
        setDefault(index: index)
    }
    
    func setDefault(index: Int) {
        defaultActionSetIndex = index
        saveToPersistentStore()
    }
    
    //MARK: Persistent storage
    
    private var persistentFileURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        return documents.appendingPathComponent("actionSets.plist")
    }
    
    func saveToPersistentStore() {
        guard let url = persistentFileURL else { return }
        let actionSetsJSON = actionSets.map { $0.jsonRepresentation }
        let json = JSON(actionSetsJSON)
        
        do {
            let actionSetsData = try json.rawData()
            try actionSetsData.write(to: url)
            
            UserDefaults.standard.set(defaultActionSetIndex, forKey: "defaultActionSetIndex")
        } catch {
            NSLog("Error writing Action Sets data: \(error)")
        }
    }
    
    func loadFromPersistentStore() {
        let fileManager = FileManager.default
        guard let url = persistentFileURL,
            fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            let actionSetsData = try Data(contentsOf: url)
            let json = try JSON(data: actionSetsData)
            print(json)
            actionSets = json.arrayValue.compactMap { ActionSet(json: $0) }
            
            self.defaultActionSetIndex = UserDefaults.standard.integer(forKey: "defaultActionSetIndex")
        } catch {
            NSLog("Error loading Action Sets data: \(error)")
        }
    }
    
}
