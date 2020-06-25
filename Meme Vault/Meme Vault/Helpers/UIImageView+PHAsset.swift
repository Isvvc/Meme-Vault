//
//  UIImageView+PHAsset.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 5/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

extension UIImageView {
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode) {
        let options = PHImageRequestOptions()
        options.version = .current
        
        let deviceScale = UIScreen.main.scale
        let targetSize = CGSize(width: self.frame.width * deviceScale, height: self.frame.height * deviceScale)
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            self.image = image
        }
    }
}
