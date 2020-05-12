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
        switch contentMode {
        case .aspectFill:
            self.contentMode = .scaleAspectFill
        case .aspectFit:
            self.contentMode = .scaleAspectFit
        @unknown default:
            break
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { imageData, dataUTI, orientation, info in
            guard let imageData = imageData else { return }
            self.image = UIImage(data: imageData)

            if let dataUTI = dataUTI,
                let typeURL = URL(string: dataUTI) {
                print(typeURL.pathExtension)
            }
        }
    }
}
