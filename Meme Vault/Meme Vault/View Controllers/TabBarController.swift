//
//  TabBarController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let actionController = ActionController()
    let providerController = ProviderController()
    let destinationController = DestinationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in viewControllers ?? [] {
            if let navigationVC = vc as? UINavigationController,
                let firstVC = navigationVC.viewControllers.first {
                if let albumsVC = firstVC as? AlbumsTableViewController {
                    albumsVC.actionController = actionController
                } else if let settingsVC = firstVC as? SettingsTableViewController {
                    settingsVC.actionController = actionController
                    settingsVC.providerController = providerController
                    settingsVC.destinationController = destinationController
                }
            }
        }
    }

}
