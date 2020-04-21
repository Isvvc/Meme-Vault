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
        return 1 + (condition?.id != nil).int + (condition?.conjunction != nil).int
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        
        switch indexPath.row {
        case 0 - (condition?.conjunction == nil).int:
            identifier = "ConjunctionCell"
        case 1 - (condition?.conjunction == nil).int:
            identifier = "NotCell"
        default:
            identifier = "AlbumCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch indexPath.row {
        case 0 - (condition?.conjunction == nil).int:
            if let conjunctionCell = cell as? ConjunctionTableViewCell {
                conjunctionCell.segmentedControl.selectedSegmentIndex = condition?.conjunction?.rawValue ?? 0
                conjunctionCell.delegate = self
            }
            
        case 1 - (condition?.conjunction == nil).int:
            if let notCell = cell as? NotTableViewCell {
                notCell.toggle.isOn = condition?.not ?? false
                notCell.delegate = self
            }
            
        default:
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

//MARK: Segmented control cell delegate

extension ConditionTableViewController: ControlCellDelegate {
    func valueChanged<Control: UIControl>(_ sender: Control) {
        
        if let segmentedControl = sender as? UISegmentedControl {
            guard let condition = condition else { return }
            condition.conjunction = Condition.Conjunction(rawValue: segmentedControl.selectedSegmentIndex)
            delegate?.update(condition)
            
        } else if let toggle = sender as? UISwitch {
            guard let condition = condition else { return }
            condition.not = toggle.isOn
            delegate?.update(condition)
            
        }
    }
}
