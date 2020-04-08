//
//  DestinationController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class DestinationController {
    
    func createDestination(named name: String, path: String?, context: NSManagedObjectContext) {
        let destination = Destination(context: context)
        destination.name = name
        destination.path = path
        CoreDataStack.shared.save(context: context)
    }
    
    func delete(destination: Destination, context: NSManagedObjectContext) {
        context.delete(destination)
        CoreDataStack.shared.save(context: context)
    }
}