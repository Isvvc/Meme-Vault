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
    
    //MARK: Outlets
    
    @IBOutlet weak var addConditionButton: UIButton!
    
    //MARK: Properties
    
    var collectionController: CollectionController?
    var collection: AlbumCollection?
    var newConditionIndex: Int?

    override func viewDidLoad() {
        guard let collection = collection else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ToggleTableViewCell", bundle: nil), forCellReuseIdentifier: "ToggleCell")
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let navBarTap = UITapGestureRecognizer(target: self, action: #selector(updateName(sender:)))
        navigationController?.navigationBar.addGestureRecognizer(navBarTap)
        
        title = collection.name
        
        if collection.isNewCollection {
            updateName(sender: self)
        }
    }
    
    //MARK: Cell loading
    
    /// Loads the content of the cells at the given index paths.
    /// - Parameter indexPaths: An array of the index paths of the cells to load data into
    private func loadCells(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            loadCell(at: indexPath)
        }
    }
    
    /// Loads the content of the cell at the given index path.
    /// - Parameter indexPath: The index path of the cell to load data into
    private func loadCell(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        loadCell(cell, for: indexPath)
    }
    
    /// Loads the content of the given cell.
    /// - Parameters:
    ///   - cell: The cell to load data into
    ///   - indexPath: The index path of the cell
    private func loadCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        guard let collection = collection else { return }
        let condition = collection.conditions[indexPath.row]
        
        let label = collection.textForCondition(at: indexPath.row)
        cell.textLabel?.text = label
        cell.detailTextLabel?.text = nil
        
        if condition.conjunction == .none,
            condition.id == .none {
            cell.accessoryType = .none
        }
        
        let insetLevel = collection.insetLevel(for: condition)
        cell.contentView.layoutMargins.left = CGFloat(insetLevel % 4 * 40)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : collection?.conditions.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // "Oldest first" toggle cell
                cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath)
                guard let toggleCell = cell as? ToggleTableViewCell else { break }
                toggleCell.delegate = self
                toggleCell.label.text = "Oldest first"
                toggleCell.toggle.isOn = collection?.oldestFirst ?? true
            default:
                // Destination cell
                cell = tableView.dequeueReusableCell(withIdentifier: "ConditionCell", for: indexPath)
                cell.textLabel?.text = "Destination"
                cell.detailTextLabel?.text = collection?.destination?.name
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ConditionCell", for: indexPath)
            loadCell(cell, for: indexPath)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section != 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let collection = collection,
                let collectionController = collectionController else { return }
            
            let cellsToUpdate = collectionController.deleteCondition(at: indexPath.row, from: collection)
            
            let cellsToDelete: [IndexPath] = cellsToUpdate.delete.map { IndexPath(row: $0, section: indexPath.section) }
            let cellsToReload: [IndexPath] = cellsToUpdate.reload.map { IndexPath(row: $0, section: indexPath.section) }
            
            tableView.deleteRows(at: cellsToDelete, with: .automatic)
            loadCells(at: cellsToReload)
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let collection = collection else { return }
        collectionController?.moveCondition(from: fromIndexPath.row, to: to.row, in: collection)
        
        // Ideally this should only be reloading the cells between the old and new positions,
        // but I can't for the life of me get it to do that right for some reason
        tableView.reloadData()
    }
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collection = collection else { return }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                tableView.deselectRow(at: indexPath, animated: true)
                
                guard let toggleCell = tableView.cellForRow(at: indexPath) as? ToggleTableViewCell else { return }
                let toggle = toggleCell.toggle!
                toggle.setOn(!toggle.isOn, animated: true)
                valueChanged(toggle)
            default:
                performSegue(withIdentifier: "Destinations", sender: self)
            }
        default:
            let condition = collection.conditions[indexPath.row]
            // Only segue if the row isn't a ')'
            if condition.id == nil && condition.conjunction == .none {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                performSegue(withIdentifier: "Condition", sender: self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard indexPath.section == 1 else { return .none }
        let label = collection?.textForCondition(at: indexPath.row)
        return label == ")" ? .none : .delete
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let collection = collection else { return proposedDestinationIndexPath }
        let condition = collection.conditions[sourceIndexPath.row]
        
        if condition.id == nil {
            if condition.conjunction != .none {
                let closingParenthesisIndex = collection.indexOfCorrespondingClosingParenthesis(forConditionAt: sourceIndexPath.row)
                return proposedDestinationIndexPath.row >= closingParenthesisIndex ? sourceIndexPath : proposedDestinationIndexPath
            } else {
                let openingParenthesisIndex = collection.indexOfCorrespondingOpeningParenthesis(forConditionAt: sourceIndexPath.row)
                return proposedDestinationIndexPath.row <= openingParenthesisIndex ? sourceIndexPath : proposedDestinationIndexPath
            }
        }
        
        return proposedDestinationIndexPath
    }
    
    //MARK: Actions
    
    @IBAction func addCondition(_ sender: Any) {
        guard let collectionController = collectionController,
            let collection = collection else { return }
        
        let alertController = UIAlertController(title: "Add Condition", message: nil, preferredStyle: .actionSheet)
        
        let conditionAction = UIAlertAction(title: "Condition", style: .default) { _ in
            DispatchQueue.main.async {
                guard collectionController.addCondition(to: collection) != nil else { return }
                self.newConditionIndex = collection.conditions.count - 1
                self.tableView.insertRows(at: [IndexPath(row: collection.conditions.count - 1, section: 1)], with: .automatic)
                self.performSegue(withIdentifier: "Condition", sender: self)
            }
        }
        
        let parenthesesAction = UIAlertAction(title: "Parentheses", style: .default) { _ in
            DispatchQueue.main.async {
                collectionController.addParentheses(to: collection)
                
                let count = collection.conditions.count
                let indexPaths: [IndexPath] = [
                    IndexPath(row: count - 1, section: 1),
                    IndexPath(row: count - 2, section: 1)
                ]
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(conditionAction)
        alertController.addAction(parenthesesAction)
        alertController.addAction(cancelAction)
        
        alertController.pruneNegativeWidthConstraints()
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            let buttonBounds = addConditionButton.convert(addConditionButton.bounds, to: self.view)
            popoverController.sourceRect = buttonBounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func updateName(sender: Any) {
        guard navigationController?.topViewController == self,
            let collection = collection else { return }
        
        let alert = UIAlertController(title: "Collection Name", message: nil, preferredStyle: .alert)
        
        var nameTextField: UITextField?
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
            nameTextField = textField
        }
        
        let cancelHandler: ((UIAlertAction) -> Void) = { _ in
            if collection.isNewCollection {
                self.collectionController?.deleteCollection(collection: collection)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
                
        let save = UIAlertAction(title: "Save", style: .default) { alertAction in
            guard let name = nameTextField?.text,
                !name.isEmpty else {
                return cancelHandler(alertAction)
            }
            
            self.collectionController?.rename(collection: collection, to: name)
            DispatchQueue.main.async {
                self.title = name
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let conditionVC = segue.destination as? ConditionTableViewController {
            conditionVC.delegate = self
            conditionVC.collection = collection
            if let indexPath = tableView.indexPathForSelectedRow {
                conditionVC.conditionIndex = indexPath.row
            } else if let newConditionIndex = newConditionIndex {
                conditionVC.conditionIndex = newConditionIndex
            }
        } else if let destinationsVC = segue.destination as? DestinationsTableViewController {
            destinationsVC.editDestinations = false
            destinationsVC.delegate = self
        }
    }

}

//MARK: Condition table view delegate

extension CollectionTableViewController: ConditionTableDelegate {
    func update(_ condition: Condition) {
        guard let index = collection?.conditions.firstIndex(of: condition) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
        collectionController?.saveToPersistentStore()
    }
}

//MARK: Control cell delegate

extension CollectionTableViewController: ControlCellDelegate {
    func valueChanged<Control>(_ sender: Control) where Control : UIControl {
        if let toggle = sender as? UISwitch {
            collection?.oldestFirst = toggle.isOn
            collectionController?.saveToPersistentStore()
        }
    }
}

extension CollectionTableViewController: DestinationsTableDelegate {
    func choose(destination: Destination) {
        navigationController?.popToViewController(self, animated: true)
        guard let collection = collection else { return }
        
        collectionController?.set(destination: destination, for: collection)
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
}
