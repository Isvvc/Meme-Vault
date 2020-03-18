//
//  ActionSetCollectionViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ActionCell"

class ActionSetCollectionViewController: UICollectionViewController {
    
    //MARK: Properties
    
    var tempData: [String] = ["Test 1", "Test two", "Test III"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    //MARK: Actions
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Add Action", message: nil, preferredStyle: .actionSheet)
        
        let actions = ["Enter a name", "Share Square", "Choose upload destination", "Upload", "Delete"]
        
        for action in actions {
            let alertAction = UIAlertAction(title: action, style: .default) { _ in
                self.tempData.append(action)
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: self.tempData.count - 1, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
            actionSheet.addAction(alertAction)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        
        actionSheet.pruneNegativeWidthConstraints()
        present(actionSheet, animated: true, completion: nil)
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ActionCollectionViewCell else { return UICollectionViewCell() }
    
        cell.textLabel.text = tempData[indexPath.row]
    
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
        let temp = tempData.remove(at: sourceIndexPath.item)
        tempData.insert(temp, at: destinationIndexPath.item)
    }

}

//MARK: Collection view delegate flow layout

extension ActionSetCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - (2 * 20), height: 50)
    }
}
