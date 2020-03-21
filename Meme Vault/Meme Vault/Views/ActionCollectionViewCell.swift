//
//  ActionCollectionViewCell.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol ActionCellDelegate {
    func switchToggle(sender: UISwitch)
}

class ActionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    var delegate: ActionCellDelegate?
    var action: ActionSet.Action?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
            toggleSwitch.isEnabled = true
            toggleSwitch.isHidden = false
        default:
            switchLabel.isHidden = true
            toggleSwitch.isEnabled = false
            toggleSwitch.isHidden = true
        }
    }
    
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        self.delegate?.switchToggle(sender: sender)
    }
}
