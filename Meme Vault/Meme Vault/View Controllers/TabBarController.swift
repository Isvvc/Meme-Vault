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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in viewControllers ?? [] {
            if let navigationVC = vc as? UINavigationController,
                let firstVC = navigationVC.viewControllers.first {
                if let albumsVC = firstVC as? AlbumsTableViewController {
                    albumsVC.actionController = actionController
                } else if let actionSetsVC = firstVC as? ActionSetsTableViewController {
                    actionSetsVC.actionController = actionController
                }
            }
        }
    }

}
