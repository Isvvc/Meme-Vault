//
//  ActionSetCollectionViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol ActionSetViewControllerDelegate {
    func actionChanged(actionSet: ActionSet?)
}

class ActionSetCollectionViewController: UICollectionViewController {
    
    //MARK: Properties
    
    var actionController: ActionController?
    var actionSet: ActionSet?
    var delegate: ActionSetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    //MARK: Actions
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction(_ sender: Any) {
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
    
    private func updateTags(afterIndex: Int) {
        let totalItems = collectionView.numberOfItems(inSection: 0)
        for index in afterIndex..<totalItems {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ActionCollectionViewCell else { continue }
            cell.removeButton.tag = index
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionSet?.actions.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionCell", for: indexPath) as? ActionCollectionViewCell else { return UICollectionViewCell() }
        
        cell.textLabel.text = actionSet?.actions[indexPath.row].name
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeAction(sender:)), for: .touchUpInside)
    
        return cell
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
        }
    }

}

//MARK: Collection view delegate flow layout

extension ActionSetCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - (2 * 20), height: 50)
    }
}
