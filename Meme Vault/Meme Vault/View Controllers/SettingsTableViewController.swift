//
//  SettingsTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var actionController: ActionController?
    var providerController: ProviderController?
    var destinationController: DestinationController?
    var collectionController: CollectionController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func identifier(for indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:
            return "Account"
        default:
            switch indexPath.row {
            case 0:
                return "ActionSets"
            case 1:
                return "Destinations"
            default:
                return "Collections"
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = self.identifier(for: indexPath) + "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        return cell
    }
    
    //MARK: Table view delegate
    
    // Using this instead of having segues linked directly from the cells in Storyboard
    // because that wasn't working consistenty
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = self.identifier(for: indexPath)
        performSegue(withIdentifier: identifier, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let actionSetsVC = segue.destination as? ActionSetsTableViewController {
            actionSetsVC.actionController = actionController
        } else if let loginVC = segue.destination as? LoginTableViewController {
            loginVC.providerController = providerController
        } else if let destinationVC = segue.destination as? DestinationsTableViewController {
            destinationVC.destinationController = destinationController
            destinationVC.providerController = providerController
        } else if let collectionsVC = segue.destination as? CollectionsTableViewController {
            collectionsVC.collectionController = collectionController
        }
    }

}
