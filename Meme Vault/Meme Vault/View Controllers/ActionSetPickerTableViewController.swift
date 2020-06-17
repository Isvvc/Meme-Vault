//
//  ActionSetPickerTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol ActionSetPickerDelegate {
    func choose(actionSetAtIndex: Int)
}

class ActionSetPickerTableViewController: UITableViewController {
    
    var actionController: ActionController?
    var delegate: ActionSetPickerDelegate?
    var chosen: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chosen = actionController?.defaultActionSetIndex ?? 0
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionController?.actionSets.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionSetCell", for: indexPath)
        
        if let actionSet = actionController?.actionSets[indexPath.row] {
            cell.textLabel?.text = actionSet.name
            cell.detailTextLabel?.text = "\(actionSet.actions.count) actions"
        }
        
        if indexPath.row == chosen {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let oldChosen = chosen
        chosen = indexPath.row
        
        delegate?.choose(actionSetAtIndex: indexPath.row)
        
        if let oldCell = tableView.cellForRow(at: IndexPath(row: oldChosen, section: 0)) {
            oldCell.accessoryType = .none
        }
        if let newCell = tableView.cellForRow(at: IndexPath(row: chosen, section: 0)) {
            newCell.accessoryType = .checkmark
        }
    }

}
