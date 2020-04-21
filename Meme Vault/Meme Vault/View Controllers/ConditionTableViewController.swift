//
//  ConditionTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/21/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

protocol ConditionTableDelegate {
    func update(_ condition: Condition)
}

class ConditionTableViewController: UITableViewController {
    
    var condition: Condition?
    var delegate: ConditionTableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        
        switch indexPath.row {
        case 0:
            identifier = "ConjunctionCell"
        case 1:
            identifier = "NotCell"
        default:
            identifier = "AlbumCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if indexPath.row == 2 {
            if let id = condition?.id {
                let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
                cell.textLabel?.text = collections.firstObject?.localizedTitle
            } else {
                cell.textLabel?.text = "Select Album"
            }
        }

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let albumsVC = segue.destination as? AlbumsTableViewController {
            albumsVC.delegate = self
        }
    }

}

//MARK: Albums table delegate

extension ConditionTableViewController: AlbumsTableDelegate {
    func selectAlbum(_ album: PHAssetCollection) {
        guard let condition = condition else { return }
        condition.id = album.localIdentifier
        print(album.localIdentifier)
        navigationController?.popViewController(animated: true)
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        delegate?.update(condition)
    }
}
