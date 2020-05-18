//
//  ToggleTableViewCell.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 5/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    
    var delegate: ControlCellDelegate?
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        delegate?.valueChanged(sender)
    }
}
