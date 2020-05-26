//
//  NotTableViewCell.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/21/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class NotTableViewCell: UITableViewCell {

    @IBOutlet weak var toggle: UISwitch!
    
    var delegate: ControlCellDelegate?

    @IBAction func valueChanged(_ sender: UISwitch) {
        delegate?.valueChanged(sender)
    }
}
