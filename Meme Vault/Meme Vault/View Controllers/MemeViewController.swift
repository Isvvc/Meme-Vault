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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    var actionController: ActionController?
    var collectionController: CollectionController?
    var collection: AlbumCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the image
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
        
        // Adjust size based on keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            containerHeight.constant = 200
        } else {
            containerHeight.constant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let actionSetPicker = segue.destination as? ActionSetPickerTableViewController {
            actionSetPicker.actionController = actionController
        }
    }
    
}
