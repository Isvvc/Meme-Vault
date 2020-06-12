//
//  ActionSet.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActionSet: NSObject {
    
    public enum Action: Equatable {
        case name(skipIfDone: Bool = true, preset: String? = nil)
        case share
        case destination
        case upload
        case delete
        
        static var allCases: [Action] {
            return [
                .name(),
                .share,
                .destination,
                .upload,
                .delete
            ]
        }
        
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
        
        var jsonRepresentation: JSON {
            switch self {
            case .name(skipIfDone: let skipIfDone, preset: _):
                return JSON(["skipIfDone": skipIfDone])
            case .share:
                return "share"
            case .destination:
                return "destination"
            case .upload:
                return "upload"
            case .delete:
                return "delete"
            }
        }
        
        init?(json: JSON) {
            if let string = json.string {
                switch string {
                case "share":
                    self = .share
                case "destination":
                    self = .destination
                case "upload":
                    self = .upload
                case "delete":
                    self = .delete
                default:
                    return nil
                }
            } else if let skipIfDone = json["skipIfDone"].bool {
                self = .name(skipIfDone: skipIfDone)
            } else {
                return nil
            }
        }
    }
    
    var name: String
    var actions: [Action]
    
    var jsonRepresentation: JSON {
        var actionsJSON = JSON([])
        
        for action in actions {
            actionsJSON.arrayObject?.append(action.jsonRepresentation)
        }
        
        return JSON([
            "name": name,
            "actions": actionsJSON
        ])
    }
    
    init(name: String, actions: [Action] = []) {
        self.name = name
        self.actions = actions
    }
    
    init?(json: JSON) {
        guard let name = json["name"].string,
            let actions = json["actions"].array else { return nil }
        
        self.name = name
        self.actions = actions.compactMap { Action(json: $0) }
    }
    
}
