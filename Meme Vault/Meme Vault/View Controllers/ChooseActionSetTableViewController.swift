//
//  ActionSetPickerTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol ChooseActionSetDelegate {
    func choose(actionSet: ActionSet)
}

class ActionSetPickerTableViewController: UITableViewController {
    
    var actionController: ActionController?
    var delegate: ChooseActionSetDelegate?
    var chosen: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let actionController = actionController else { return }
        
        let oldChosen = chosen
        chosen = indexPath.row
        let actionSet = actionController.actionSets[chosen]
        
        delegate?.choose(actionSet: actionSet)
        
        if let oldCell = tableView.cellForRow(at: IndexPath(row: oldChosen, section: 0)) {
            oldCell.accessoryType = .none
        }
        if let newCell = tableView.cellForRow(at: IndexPath(row: chosen, section: 0)) {
            newCell.accessoryType = .checkmark
        }
    }

}
