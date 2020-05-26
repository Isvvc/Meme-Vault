//
//  ConjunctionTableViewCell.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/21/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ConjunctionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var delegate: ControlCellDelegate?

    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        delegate?.valueChanged(sender)
    }
    
}
