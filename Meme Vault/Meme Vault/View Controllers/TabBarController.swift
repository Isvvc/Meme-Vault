//
//  TabBarController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

class TabBarController: UITabBarController {
    
    let actionController = ActionController()
    let providerController = ProviderController()
    let destinationController = DestinationController()
    let collectionController = CollectionController(context: CoreDataStack.shared.mainContext)
    let memeController = MemeController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in viewControllers ?? [] {
            if let navigationVC = vc as? UINavigationController,
                let firstVC = navigationVC.viewControllers.first {
                if let collectionsVC = firstVC as? CollectionsTableViewController {
                    collectionsVC.actionController = actionController
                    collectionsVC.collectionController = collectionController
                    collectionsVC.memeController = memeController
                    collectionsVC.providerController = providerController
                } else if let settingsVC = firstVC as? SettingsTableViewController {
                    settingsVC.actionController = actionController
                    settingsVC.providerController = providerController
                    settingsVC.destinationController = destinationController
                    settingsVC.collectionController = collectionController
                } else if let memesVC = firstVC as? MemesTableViewController {
                    memesVC.memeController = memeController
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         This is a weird workaround for a weird issue.
         For some reason, if the first time a Core Data fetch request
         is made is in the `DestinationsTableViewController` in
         the `MemeViewController`'s overlay, the shared instance of
         `CoreDataStack`'s `NSPersistentContainer` will change
         some time after the FRC is created and before cells are loaded.
         Setting `container` to `private(set)` didn't make a difference.
         I have no idea how that happens, but performing a fetch request
         when the app first starts prevents it from happening.
         */
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            let _ = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
        } catch {
            NSLog("Workaround to prevent crash when setting Destination failed: \(error)")
        }
    }

}
