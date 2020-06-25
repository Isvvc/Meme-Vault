//
//  ActionCollectionViewCell.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

protocol ActionCellDelegate {
    func switchToggle(sender: UISwitch)
}

class ActionCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var actionButton: UIButton!
    
    //MARK: Properties
    
    var delegate: ActionCellDelegate?
    var action: ActionSet.Action?
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeButton.tintColor = .lightGray
        
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.125
        layer.shadowOffset = CGSize(width:0,height: 2.0)
        layer.shadowRadius = 8
        layer.masksToBounds = false
        let bounds = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: UIScreen.main.bounds.width - (2 * 20), height: self.bounds.height)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        
        switch action {
        case .name(skipIfDone: let skip, preset: _):
            switchLabel.text = "Skip if done"
            toggleSwitch.isOn = skip
            
            switchLabel.isHidden = false
            enableAndShow(toggleSwitch)
            disableAndHide(actionButton)
        case .delete(askForConfirmation: let askForConfirmation):
            switchLabel.text = "Ask for confirmation"
            toggleSwitch.isOn = askForConfirmation
            
            switchLabel.isHidden = false
            enableAndShow(toggleSwitch)
            disableAndHide(actionButton)
        case .addToAlbum(id: let id), .removeFromAlbum(id: let id):
            disableAndHide(toggleSwitch)
            enableAndShow(actionButton)
            
            if let id = id {
                let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
                switchLabel.text = collections.firstObject?.localizedTitle
            } else {
                switchLabel.text = nil
            }
        default:
            switchLabel.isHidden = true
            disableAndHide(toggleSwitch)
            disableAndHide(actionButton)
        }
    }
    
    //MARK: Actions
    
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        self.delegate?.switchToggle(sender: sender)
    }
    
    //MARK: Private
    
    private func disableAndHide(_ control: UIControl) {
        control.isEnabled = false
        control.isHidden = true
    }
    
    private func enableAndShow(_ control: UIControl) {
        control.isEnabled = true
        control.isHidden = false
    }
}
