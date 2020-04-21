//
//  ControlCellDelegate.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/21/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

protocol ControlCellDelegate {
    func valueChanged<Control: UIControl>(_ sender: Control)
}
