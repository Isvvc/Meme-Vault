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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        
        switch indexPath.section {
        case 0:
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
        }
    }

}
