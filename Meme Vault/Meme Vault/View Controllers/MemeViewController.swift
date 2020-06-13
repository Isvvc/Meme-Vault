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
    
    //MARK: Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: Properties
    
    var actionController: ActionController?
    var actionSetIndex: Int = 0
    var currentActionIndex: Int = 0
    var collectionController: CollectionController?
    var collection: AlbumCollection?
    
    var actionSet: ActionSet? {
        actionController?.actionSets[actionSetIndex]
    }
    var currentAction: ActionSet.Action? {
        guard currentActionIndex < actionSet?.actions.count ?? 0,
            let action = actionSet?.actions[currentActionIndex] else { return nil }
        return action
    }
    
    //MARK: View loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let actionController = actionController {
            actionSetIndex = actionController.defaultActionSetIndex
        }
        
        setUpViews()
        performCurrentAction()
    }
    
    private func setUpViews() {
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
        
        nameTextField.delegate = self
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
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
    
    //MARK: Actions
    
    func performCurrentAction() {
        guard let action = currentAction else { return }
        
        switch action {
        case .name(skipIfDone: let skipIfDone, preset: _):
            if skipIfDone,
                !(nameTextField.text?.isEmpty ?? true) {
                break
            }
            nameTextField.becomeFirstResponder()
        
        case .upload:
            print("Uploading... (not really; this is just a placeholder)")
        
        default:
            break
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let actionSetPicker = segue.destination as? ActionSetPickerTableViewController {
            actionSetPicker.actionController = actionController
            actionSetPicker.delegate = self
        }
    }
    
}

//MARK: Text field delegate

extension MemeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let nameActionIndex: Int?
        
        switch currentAction {
        case .name(skipIfDone: _, preset: _):
            nameActionIndex = currentActionIndex
        default:
            nameActionIndex = actionSet?.actions.firstIndex(where: { action -> Bool in
                switch action {
                case .name(skipIfDone: _, preset: _):
                    return true
                default:
                    return false
                }
            })
        }
        
        if let nameActionIndex = nameActionIndex {
            currentActionIndex = nameActionIndex + 1
        }
        performCurrentAction()
        
        return true
    }
}

//MARK: Action Set picker delegate

extension MemeViewController: ActionSetPickerDelegate {
    func choose(actionSetAtIndex index: Int) {
        actionSetIndex = index
        currentActionIndex = 0
        performCurrentAction()
    }
}
