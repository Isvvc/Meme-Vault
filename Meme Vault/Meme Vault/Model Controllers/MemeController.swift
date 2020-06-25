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
    
    /// Deletes a `Meme` object.
    /// - Parameters:
    ///   - meme: The meme to delete
    ///   - context: The managed object context to use to perform the deletion
    func delete(meme: Meme, context: NSManagedObjectContext) {
        context.delete(meme)
        CoreDataStack.shared.save(context: context)
    }
    
    /// Flags a meme for deletion. Note that this does not delete the `Meme` object, but rather flags it so its `PHAsset` can be deleted at a later time.
    /// - Parameters:
    ///   - meme: The meme to flag
    ///   - context: The managed object context to save
    func flagForDeletion(meme: Meme, context: NSManagedObjectContext) {
        meme.delete = true
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
    
    func fetchAsset(for meme: Meme) -> PHAsset? {
        guard let id = meme.id else { return nil }
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
    }
    
    //MARK: Assets
    
    func delete(asset: PHAsset, completion: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
        }, completionHandler: completion)
    }
    
    func deleteAsset(from meme: Meme, context: NSManagedObjectContext) {
        guard let asset = fetchAsset(for: meme) else { return }
        delete(asset: asset) { success, error in
            if let error = error {
                return NSLog("Error deleting asset: \(error)")
            }
            
            if success {
                self.delete(meme: meme, context: context)
            }
        }
    }
    
}
