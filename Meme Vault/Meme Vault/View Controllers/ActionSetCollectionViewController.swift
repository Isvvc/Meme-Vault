//
//  ActionSetCollectionViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

protocol ActionSetViewControllerDelegate {
    func actionChanged(actionSet: ActionSet?)
}

class ActionSetCollectionViewController: UICollectionViewController {
    
    //MARK: Properties
    
    var actionController: ActionController?
    var actionSet: ActionSet?
    var delegate: ActionSetViewControllerDelegate?
    var activeActionIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = actionSet?.name {
            title = name
        }
        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    //MARK: Actions
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addAction(_ sender: Any) {
        guard let actionSet = actionSet else { return }
        
        let actionSheet = UIAlertController(title: "Add Action", message: nil, preferredStyle: .actionSheet)
        
        let actions = ActionSet.Action.allCases
        for action in actions {
            let alertAction = UIAlertAction(title: action.name, style: .default) { _ in
                self.actionSet?.actions.append(action)
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: actionSet.actions.count - 1, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                    self.delegate?.actionChanged(actionSet: self.actionSet)
                }
            }
            actionSheet.addAction(alertAction)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        
        actionSheet.pruneNegativeWidthConstraints()
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func removeAction(sender: UIButton) {
        actionSet?.actions.remove(at: sender.tag)
        let indexPath = IndexPath(item: sender.tag, section: 0)
        collectionView.deleteItems(at: [indexPath])
        updateTags(afterIndex: sender.tag)
        delegate?.actionChanged(actionSet: actionSet)
    }
    
    @objc private func chooseAlbum(sender: UIControl) {
        activeActionIndex = sender.tag
        performSegue(withIdentifier: "Albums", sender: self)
    }
    
    private func updateTags(afterIndex: Int) {
        let totalItems = collectionView.numberOfItems(inSection: 0)
        for index in afterIndex..<totalItems {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ActionCollectionViewCell else { continue }
            cell.removeButton.tag = index
            cell.toggleSwitch.tag = index
            cell.actionButton.tag = index
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionSet?.actions.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionCell", for: indexPath) as? ActionCollectionViewCell else { return UICollectionViewCell() }
        
        let action = actionSet?.actions[indexPath.row]
        cell.textLabel.text = action?.name
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeAction(sender:)), for: .touchUpInside)
        
        cell.action = action
        cell.toggleSwitch.tag = indexPath.row
        cell.actionButton.tag = indexPath.row
        cell.actionButton.addTarget(self, action: #selector(chooseAlbum(sender:)), for: .touchUpInside)
        cell.delegate = self
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AddAction", for: indexPath) as! ButtonCollectionReusableView
            footer.button.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
            return footer
        default:
            assert(false, "Invalid element type")
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let temp = actionSet?.actions.remove(at: sourceIndexPath.item) {
            actionSet?.actions.insert(temp, at: destinationIndexPath.item)
            actionController?.saveToPersistentStore()
        }
        
        let reloadStartIndex = min(sourceIndexPath.row, destinationIndexPath.row)
        updateTags(afterIndex: reloadStartIndex)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nameVC = segue.destination as? NameTableViewController {
            nameVC.delegate = self
            nameVC.name = actionSet?.name
        } else if let albumsVC = segue.destination as? AlbumsTableViewController {
            albumsVC.delegate = self
        }
    }

}

//MARK: Collection view delegate flow layout

extension ActionSetCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let action = actionSet?.actions[indexPath.row]
        
        let height: CGFloat
        switch action {
        case .name, .addToAlbum, .removeFromAlbum:
            height = 96
        default:
            //height = 64
            height = 96
        }
        return CGSize(width: UIScreen.main.bounds.width - (2 * 20), height: height)
    }
}

//MARK: Action cell delegate

extension ActionSetCollectionViewController: ActionCellDelegate {
    func switchToggle(sender: UISwitch) {
        let oldAction = actionSet?.actions[sender.tag]
        switch oldAction {
        case .name(skipIfDone: _, preset: let preset):
            actionSet?.actions[sender.tag] = .name(skipIfDone: sender.isOn, preset: preset)
            actionController?.saveToPersistentStore()
        default:
            break
        }
        
        updateTags(afterIndex: sender.tag)
    }
}

//MARK: Name table delegate

extension ActionSetCollectionViewController: NameTableDelegate {
    func setName(_ name: String) {
        actionSet?.name = name
        delegate?.actionChanged(actionSet: actionSet)
    }
}

extension ActionSetCollectionViewController: AlbumsTableDelegate {
    func selectAlbum(_ album: PHAssetCollection) {
        guard let actionSet = actionSet,
            let activeActionIndex = activeActionIndex else { return }
        
        let action: ActionSet.Action
        switch actionSet.actions[activeActionIndex] {
        case .addToAlbum:
            action = .addToAlbum(id: album.localIdentifier)
        case .removeFromAlbum:
            action = .removeFromAlbum(id: album.localIdentifier)
        default:
            return
        }
        
        actionSet.actions[activeActionIndex] = action
        actionController?.saveToPersistentStore()
        
        let cell = collectionView.cellForItem(at: IndexPath(item: activeActionIndex, section: 0)) as? ActionCollectionViewCell
//        cell?.switchLabel.text = album.localizedTitle
        cell?.action = action
        cell?.layoutSubviews()
        
        navigationController?.popViewController(animated: true)
    }
}
