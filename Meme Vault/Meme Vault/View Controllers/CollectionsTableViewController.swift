//
//  CollectionsTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/14/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class CollectionsTableViewController: UITableViewController {
    
    var collectionController: CollectionController?
    var editCollections = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionController?.collections.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath)

        cell.textLabel?.text = collectionController?.collections[indexPath.row].name

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            collectionController?.deleteCollection(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editCollections {
            performSegue(withIdentifier: "Collection", sender: self)
        } else {
            performSegue(withIdentifier: "Meme", sender: self)
        }
    }
    
    //MARK: Actions
    
    @IBAction func addCollection(_ sender: Any) {
        guard let collectionController = collectionController else { return }
        collectionController.createCollection()
        let indexPath = IndexPath(row: collectionController.collections.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            
            if let collectionVC = segue.destination as? CollectionTableViewController {
                collectionVC.collectionController = collectionController
                collectionVC.collection = collectionController?.collections[indexPath.row]
            } else if let memeVC = segue.destination as? MemeViewController {
                memeVC.collectionController = collectionController
                memeVC.collection = collectionController?.collections[indexPath.row]
            }
            
        }
    }

}
