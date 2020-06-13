//
//  MemeController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 6/13/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData
import Photos

class MemeController {
    
    //MARK: CRUD
    
    @discardableResult func createMeme(id: String, creationDate: Date? = nil, name: String? = nil, destination: Destination? = nil, context: NSManagedObjectContext) -> Meme {
        let meme = Meme(context: context)
        meme.id = id
        meme.creationDate = creationDate
        meme.name = name
        meme.destination = destination
        CoreDataStack.shared.save(context: context)
        return meme
    }
    
    func setName(to name: String, for meme: Meme, context: NSManagedObjectContext) {
        meme.name = name
        CoreDataStack.shared.save(context: context)
    }
    
    func setDestination(to destination: Destination, for meme: Meme, context: NSManagedObjectContext) {
        meme.destination = destination
        CoreDataStack.shared.save(context: context)
    }
    
    func delete(meme: Meme, context: NSManagedObjectContext) {
        context.delete(meme)
        CoreDataStack.shared.save(context: context)
    }
    
    //MARK: Fetching
    
    func fetchMeme(for asset: PHAsset, context: NSManagedObjectContext) -> Meme? {
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", asset.localIdentifier)
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults.first
        } catch {
            NSLog("Error fetching meme: \(error)")
            return nil
        }
    }
    
    func fetchOrCreateMeme(for asset: PHAsset, context: NSManagedObjectContext) -> Meme {
        if let fetchedMeme = fetchMeme(for: asset, context: context) {
            return fetchedMeme
        }
        
        return createMeme(id: asset.localIdentifier, creationDate: asset.creationDate ?? Date(), context: context)
    }
    
}
