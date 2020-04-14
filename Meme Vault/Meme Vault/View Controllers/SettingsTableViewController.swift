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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        
        switch indexPath.section {
        case 0:
            identifier = "AccountCell"
        case 1:
            identifier = "ActionSetsCell"
        default:
            identifier = "DestinationsCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        return cell
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
        }
    }

}
