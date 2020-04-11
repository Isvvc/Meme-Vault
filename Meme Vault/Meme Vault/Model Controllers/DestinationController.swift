//
//  DestinationController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class DestinationController {
    
    func createDestination(named name: String, path: String?, parent: Destination? = nil, context: NSManagedObjectContext) {
        let destination = Destination(context: context)
        destination.name = name
        destination.path = path
        destination.parent = parent
        CoreDataStack.shared.save(context: context)
    }
    
    func delete(destination: Destination, context: NSManagedObjectContext) {
        deleteChildren(destination: destination, context: context)
        context.delete(destination)
        CoreDataStack.shared.save(context: context)
    }
    
    func deleteChildren(destination: Destination, context: NSManagedObjectContext) {
        guard let children = destination.children as? Set<Destination> else { return }
        
        for child in children {
            deleteChildren(destination: child, context: context)
            context.delete(child)
        }
    }
}
