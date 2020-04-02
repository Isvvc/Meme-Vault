//
//  ActionSetsTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ActionSetsTableViewController: UITableViewController {
    
    var actionController: ActionController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        title = "Action Sets"
    }
    
    //MARK: Private
    
    private func setDefaultActionSet(at indexPath: IndexPath) {
        guard let actionController = actionController else { return }
        
        let oldIndex = actionController.defaultActionSetIndex
        actionController.defaultActionSetIndex = indexPath.row
        
        let oldIndexPath = IndexPath(row: oldIndex, section: 0)
        tableView.reloadRows(at: [oldIndexPath], with: .automatic)
        tableView.reloadRows(at: [indexPath], with: .right)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionController?.actionSets.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionSetCell", for: indexPath)

        if let actionSet = actionController?.actionSets[indexPath.row] {
            cell.textLabel?.text = actionSet.name
            if actionController?.defaultActionSetIndex == indexPath.row {
                cell.textLabel?.text? += " (default)"
            }
            
            cell.detailTextLabel?.text = "\(actionSet.actions.count) actions"
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            actionController?.actionSets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if let temp = actionController?.actionSets.remove(at: fromIndexPath.row) {
            actionController?.actionSets.insert(temp, at: to.row)
        }
    }
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let setDefault = UIContextualAction(style: .normal, title: "Set as default") { action, view, completionHandler in
            DispatchQueue.main.async {
                self.setDefaultActionSet(at: indexPath)
            }
            completionHandler(true)
        }
        setDefault.backgroundColor = UIColor.systemGreen

        return UISwipeActionsConfiguration(actions: [setDefault])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController,
            let actionSetVC = navigationVC.viewControllers.first as? ActionSetCollectionViewController {
            actionSetVC.actionController = actionController
            actionSetVC.delegate = self
            
            let actionSet: ActionSet?
            if let indexPath = tableView.indexPathForSelectedRow {
                actionSet = actionController?.actionSets[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                actionSet = actionController?.createActionSet()
                if let actionSets = actionController?.actionSets {
                    let newIndexPath = IndexPath(row: actionSets.count - 1, section: 0)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            }
            actionSetVC.actionSet = actionSet
        }
    }

}

//MARK: Action set view controller delegate

extension ActionSetsTableViewController: ActionSetViewControllerDelegate {
    func actionChanged(actionSet: ActionSet?) {
        if let actionSet = actionSet,
            let selectedActionSetIndex = actionController?.actionSets.firstIndex(of: actionSet) {
            let indexPath = IndexPath(row: selectedActionSetIndex, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
