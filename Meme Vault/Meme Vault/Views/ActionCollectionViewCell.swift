//
//  ActionCollectionViewCell.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ActionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.125
        layer.shadowOffset = CGSize(width:0,height: 2.0)
        layer.shadowRadius = 8
        layer.masksToBounds = false
        let bounds = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: UIScreen.main.bounds.width - (2 * 20), height: self.bounds.height)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
