//
//  CoreDataStack.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // Let us access the CoreDataStack from anywhere in the app.
    static let shared = CoreDataStack()
    
    // Set up a persistent container
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Meme_Vault")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // Create easy access to the moc (managed object context)
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving context: \(error)")
                context.reset()
            }
        }
    }
}
