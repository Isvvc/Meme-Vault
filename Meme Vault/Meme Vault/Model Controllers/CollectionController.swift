//
//  CollectionsController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos
import CoreData

class CollectionController {
    
    var collections: [AlbumCollection]
    var collectionDestinations: [AlbumCollection: Destination] = [:]
    
    private var collectionCache = Cache<String, Set<PHAsset>>()
    private var allAssetsCache: PHFetchResult<PHAsset>? = nil
    private var currentAssetIndex: Int = 0
    private var allMemesCache: [Meme] = []
    private var currentCollection: AlbumCollection?
    
    // Load a test collection based on albums I have on my phone.
    // This won't work on any other devices
    init() {
        self.collections = []
        
        loadFromPersistentStore()
        
        if self.collections.isEmpty {
            let presetConditions = [
                Condition(conjunction: .and, not: false, id: "C87BD295-F2CA-4D24-AEE3-A4371C6A2D7D/L0/040"),
                Condition(conjunction: .and, not: true, id: "47C055F1-FC48-4BFE-B219-0867BF37A74F/L0/040"),
                Condition(conjunction: .and, not: false, id: nil),
                Condition(conjunction: .and, not: false, id: "DB8FB850-AEA8-44A9-9246-0174FD551ACE/L0/040"),
                Condition(conjunction: .or, not: false, id: "54F882E2-B85A-4DD1-ACD2-852669EF406D/L0/040"),
                Condition(conjunction: .none, not: false, id: nil)
            ]
            let presetCollection = AlbumCollection(name: "Test", conditions: presetConditions)
            self.collections = [presetCollection]
            
            saveToPersistentStore()
        }
    }
    
    //MARK: Collection CRUD
    
    @discardableResult func createCollection() -> AlbumCollection {
        let collection = AlbumCollection()
        collections.append(collection)
        saveToPersistentStore()
        return collection
    }
    
    func deleteCollection(collection: AlbumCollection) {
        guard let index = collections.firstIndex(of: collection) else { return }
        deleteCollection(at: index)
    }
    
    func deleteCollection(at index: Int) {
        collections.remove(at: index)
        saveToPersistentStore()
    }
    
    func moveCollection(from fromIndex: Int, to toIndex: Int) {
        let collection = collections[fromIndex]
        collections.remove(at: fromIndex)
        collections.insert(collection, at: toIndex)
        saveToPersistentStore()
    }
    
    func rename(collection: AlbumCollection, to name: String) {
        collection.name = name
        saveToPersistentStore()
    }
    
    func set(destination: Destination, for collection: AlbumCollection) {
        collectionDestinations[collection] = destination
        //saveToPersistentStore()
    }
    
    func removeDestination(from collection: AlbumCollection) {
        collectionDestinations.removeValue(forKey: collection)
        //saveToPersistentStore()
    }
    
    func destination(for collection: AlbumCollection?) -> Destination? {
        guard let collection = collection else { return nil }
        return collectionDestinations[collection]
    }
    
    //MARK: Condition CRUD
    
    @discardableResult func deleteCondition(at conditionIndex: Int, fromCollectionAtIndex collectionIndex: Int) -> (reload: [Int], delete: [Int]) {
        let collection = collections[collectionIndex]
        return deleteCondition(at: conditionIndex, from: collection)
    }
    
    @discardableResult func deleteCondition(at index: Int, from collection: AlbumCollection) -> (reload: [Int], delete: [Int]) {
        let conditon = collection.conditions[index]
        var reload: [Int] = []
        var delete: [Int] = [index]
        
        let isFirst = collection.conditionIsFirst(index: index)
        
        if conditon.id == nil,
            conditon.conjunction != .none {
            // This is an opening parenthesis. Find its closing parenthesis, delete that, and reload all cells between.
            let closingParenthesisIndex = collection.indexOfCorrespondingClosingParenthesis(forConditionAt: index)
            for i in index..<closingParenthesisIndex-1 {
                reload.append(i)
            }
            
            collection.conditions.remove(at: closingParenthesisIndex)
            delete.append(closingParenthesisIndex)
        } else if isFirst {
            // The next cell (the new first) will have its condition hidden
            // After this cell is deleted, the next cell will have the indexPath that this one has now
            reload.append(index)
        }
        
        collection.conditions.remove(at: index)
        
        saveToPersistentStore()
        
        return (reload, delete)
    }
    
    func moveCondition(from fromIndex: Int, to toIndex: Int, in collection: AlbumCollection) {
        let condition = collection.conditions[fromIndex]
        collection.conditions.remove(at: fromIndex)
        collection.conditions.insert(condition, at: toIndex)
        
        saveToPersistentStore()
    }
    
    @discardableResult func addCondition(to collection: AlbumCollection) -> Condition? {
        guard let collection = collection.addCondition() else { return nil }
        saveToPersistentStore()
        return collection
    }
    
    @discardableResult func addParentheses(to collection: AlbumCollection) -> (opening: Condition, closing: Condition) {
        let result = collection.addParentheses()
        saveToPersistentStore()
        return result
    }
    
    //MARK: Fetching
    
    func fetchImage() -> PHAsset? {
        guard let collection = currentCollection,
            let allAssetsCache = allAssetsCache else { return nil }
        
        while currentAssetIndex < allAssetsCache.count {
            let asset = allAssetsCache.object(at: currentAssetIndex)
            
            if collection.contains(asset: asset, cache: collectionCache) {
                let meme = allMemesCache.first(where: { $0.id == asset.localIdentifier })
                
                // If there is an existing meme object for this asset,
                // skip it if it's marked for delete.
                // If there is not, return it
                if !(meme?.delete ?? false) {
                    return asset
                }
            }
            
            currentAssetIndex += 1
        }
        
        return nil
    }
    
    func beginFetchingImages(from collection: AlbumCollection, context: NSManagedObjectContext) {
        collectionCache.clear()
        
        currentCollection = collection
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: collection.oldestFirst)]
        allAssetsCache = PHAsset.fetchAssets(with: fetchOptions)
        currentAssetIndex = 0
        
        do {
            let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
            allMemesCache = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching Meme objects: \(error)")
        }
    }
    
    /// Fetches the first image in the user's photos that is in a collection.
    /// - Parameter collection: The `albumCollection` to find an image from.
    /// - Returns: a `PHAsset` of the first (oldest or newest depending on the collection's `oldestFirst` property) that is in a collection. If no images are in the collection, returns `nil`.
    func fetchFirstImage(from collection: AlbumCollection, context: NSManagedObjectContext) -> PHAsset? {
        beginFetchingImages(from: collection, context: context)
        return fetchNextImage()
    }
    
    func fetchNextImage() -> PHAsset? {
        let asset = fetchImage()
        currentAssetIndex += 1
        return asset
    }
    
    //MARK: Asset collections
    
    func add(asset: PHAsset, toAssetCollectionWithID assetCollectionID: String) {
        guard let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionID], options: nil).firstObject else { return }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest(for: collection)
            request?.addAssets([asset] as NSFastEnumeration)
        })
    }
    
    func remove(asset: PHAsset, fromAssetCollectionWithID assetCollectionID: String) {
        guard let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionID], options: nil).firstObject else { return }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest(for: collection)
            request?.removeAssets([asset] as NSFastEnumeration)
        })
    }
    
    //MARK: Persistent storage
    
    private var persistentFileURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        return documents.appendingPathComponent("collections.plist")
    }
    
    func saveToPersistentStore() {
        guard let url = persistentFileURL else { return }
        
        do {
            let collectionsData = try PropertyListEncoder().encode(collections)
            try collectionsData.write(to: url)
            
        } catch {
            NSLog("Error writing Collections data: \(error)")
        }
    }
    
    func loadFromPersistentStore() {
        guard let url = persistentFileURL,
            FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let collectionsData = try Data(contentsOf: url)
            let collections = try PropertyListDecoder().decode([AlbumCollection].self, from: collectionsData)
            self.collections = collections
        } catch {
            NSLog("Error reading Collections data: \(error)")
        }
    }
    
}
