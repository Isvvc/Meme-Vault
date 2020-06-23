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
    
    var collection: AlbumCollection?
    var conditionIndex: Int?
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
        guard let conditionIndex = conditionIndex,
            let collection = collection else { return 0 }
        let condition = collection.conditions[conditionIndex]
        
        return 1
            + (condition.id != nil).int
            + (!collection.conditionIsFirst(index: conditionIndex)).int
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        
        let isFirst = collection?.conditionIsFirst(index: conditionIndex ?? 0) ?? false
        
        switch indexPath.row {
        case 0 - (isFirst).int:
            identifier = "ConjunctionCell"
        case 1 - (isFirst).int:
            identifier = "NotCell"
        default:
            identifier = "AlbumCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        guard let conditionIndex = conditionIndex,
            let condition = collection?.conditions[conditionIndex] else { return cell }
        
        switch indexPath.row {
        case 0 - (isFirst).int:
            if let conjunctionCell = cell as? ConjunctionTableViewCell {
                conjunctionCell.segmentedControl.selectedSegmentIndex = condition.conjunction?.rawValue ?? 0
                conjunctionCell.delegate = self
            }
            
        case 1 - (isFirst).int:
            if let notCell = cell as? NotTableViewCell {
                notCell.toggle.isOn = condition.not
                notCell.delegate = self
            }
            
        default:
            if let id = condition.id {
                let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
                cell.textLabel?.text = collections.firstObject?.localizedTitle
            } else {
                cell.textLabel?.text = "Select Album"
            }
        }

        return cell
    }
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 2 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
        guard let conditionIndex = conditionIndex,
            let condition = collection?.conditions[conditionIndex] else { return }
        condition.id = album.localIdentifier
        print(album.localIdentifier)
        navigationController?.popViewController(animated: true)
        let isFirst = collection?.conditionIsFirst(index: conditionIndex) ?? false
        tableView.reloadRows(at: [IndexPath(row: 2 - isFirst.int, section: 0)], with: .none)
        delegate?.update(condition)
    }
}

//MARK: Segmented control cell delegate

extension ConditionTableViewController: ControlCellDelegate {
    func valueChanged<Control: UIControl>(_ sender: Control) {
        guard let conditionIndex = conditionIndex,
            let condition = collection?.conditions[conditionIndex] else { return }
        
        if let segmentedControl = sender as? UISegmentedControl {
            condition.conjunction = Condition.Conjunction(rawValue: segmentedControl.selectedSegmentIndex)
            delegate?.update(condition)
        } else if let toggle = sender as? UISwitch {
            condition.not = toggle.isOn
            delegate?.update(condition)
        }
    }
}
