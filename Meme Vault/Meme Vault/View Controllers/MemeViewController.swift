//
//  MemeViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 5/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

class MemeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var collectionController: CollectionController?
    var collection: AlbumCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let collection = collection,
            let photo = collectionController?.fetchFirstImage(from: collection) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        imageView.fetchImage(asset: photo, contentMode: .aspectFit)
    }

}
