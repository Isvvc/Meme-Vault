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

        DispatchQueue.global(qos: .userInitiated).async {
            // Doing this in a background thread because the fetchFirstImage function can take a while
            guard let collection = self.collection,
                let photo = self.collectionController?.fetchFirstImage(from: collection) else {
                    self.navigationController?.popViewController(animated: true)
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.fetchImage(asset: photo, contentMode: .aspectFit)
            }
        }
    }

}
