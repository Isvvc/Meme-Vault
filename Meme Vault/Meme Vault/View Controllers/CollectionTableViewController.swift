//
//  CollectionTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

class CollectionTableViewController: UITableViewController {
    
    //var collectionController: CollectionController?
    var collection: AlbumCollection?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let collection = collection {
            title = collection.name
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection?.conditions.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConditionCell", for: indexPath)

        if let collection = collection {
            let condition = collection.conditions[indexPath.row]
            
            if collection.conditionIsFirst(condition) {
                // Conditions that are first shouldn't have a conjunction
                condition.conjunction = .none
            } else if condition.id != nil,
                condition.conjunction == .none {
                // Conditions that aren't first should have a conjunction unless they're closing parenthases
                // If one is rearranged out of being first, default it to AND
                condition.conjunction = .and
            }
            
            var label = ""
            
            if let conjunction = condition.conjunction {
                label += conjunction.string + " "
            }
            
            if condition.not {
                label += "not "
                if indexPath.row == 0 {
                    label = label.capitalized
                }
            }
            
            if let id = condition.id {
                let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
                label += collections.firstObject?.localizedTitle ?? "Unknown Album"
            } else if condition.conjunction == .none,
                indexPath.row != 0 {
                label += ")"
                cell.accessoryType = .none
            } else {
                label += "("
            }
            
            cell.textLabel?.text = label
            
            let insetLevel = collection.insetLevel(for: condition)
            cell.contentView.layoutMargins.left = CGFloat(insetLevel % 4 * 40)
        }
        

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            collection?.conditions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let collection = collection else { return }
        let condition = collection.conditions[fromIndexPath.row]
        collection.conditions.remove(at: fromIndexPath.row)
        collection.conditions.insert(condition, at: to.row)
        
        // Ideally this should only be reloading the cells between the old and new positions,
        // but I can't for the life of me get it to do that right for some reason
        tableView.reloadData()
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collection = collection else { return }
        let condition = collection.conditions[indexPath.row]
        // Only segue if the row isn't a ')'
        if condition.id == nil && condition.conjunction == .none {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "Condition", sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let conditionVC = segue.destination as? ConditionTableViewController {
            conditionVC.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow {
                conditionVC.condition = collection?.conditions[indexPath.row]
            }
        }
    }

}

//MARK: Condition table view delegate

extension CollectionTableViewController: ConditionTableDelegate {
    func update(_ condition: Condition) {
        guard let index = collection?.conditions.firstIndex(of: condition) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}
