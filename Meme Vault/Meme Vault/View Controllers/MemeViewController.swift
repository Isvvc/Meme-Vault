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
    var collection: AlbumCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let collection = collection else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", collection.conditions.first!.id!)
        let excludeCollection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        let allMatches = PHAsset.fetchAssets(in: excludeCollection.firstObject!, options: nil)
        imageView.fetchImage(asset: allMatches.firstObject!, contentMode: .aspectFit)
    }

}
