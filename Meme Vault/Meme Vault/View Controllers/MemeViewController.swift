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
    var memeController: MemeController?
    var meme: Meme?
    var asset: PHAsset?
    var contentRequestID: PHContentEditingInputRequestID?
    
    var actionSet: ActionSet? {
        actionController?.actionSets[actionSetIndex]
    }
    var currentAction: ActionSet.Action? {
        guard currentActionIndex < actionSet?.actions.count ?? 0,
            let action = actionSet?.actions[currentActionIndex] else { return nil }
        return action
    }
    
    var name: String? {
        guard let name = nameTextField.text,
            !name.isEmpty else { return nil }
        return name
    }
    
    //MARK: View loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let actionController = actionController {
            actionSetIndex = actionController.defaultActionSetIndex
        }
        
        setUpViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let contentRequestID = contentRequestID {
            asset?.cancelContentEditingInputRequest(contentRequestID)
        }
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
            
            self.asset = photo
            self.meme = self.memeController?.fetchOrCreateMeme(for: photo, context: CoreDataStack.shared.mainContext)
            
            DispatchQueue.main.async {
                self.imageView.fetchImage(asset: photo, contentMode: .aspectFit)
                if let name = self.meme?.name {
                    self.nameTextField.text = name
                }
                
                self.performCurrentAction()
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
        
        // Name text field
        nameTextField.delegate = self
        nameTextField.autocapitalizationType = .sentences
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
                name != nil {
                currentActionIndex += 1
                performCurrentAction()
                break
            }
            nameTextField.becomeFirstResponder()
        
        case .upload:
            print("Uploading... (not really; this is just a placeholder)")
        
        case .share:
            shareAsset()
        
        default:
            break
        }
    }
    
    
    /// Returns the name the current image's file should have based on the `textField` and original file extension.
    /// - Parameter contentEditingInput: The content editing input from the asset's `requestContentEditingInput` call.
    /// - Returns: the name inputted with the file extension if the name in the text field is not empty, otherwise `nil`.
    func fileName(contentEditingInput: PHContentEditingInput) -> String? {
        guard let name = name,
            let url = contentEditingInput.fullSizeImageURL else { return nil }
        return "\(name).\(url.pathExtension.lowercased())"
    }
    
    
    /// Copies the current asset to the Documents directory, opens it in a Share Sheet, then deletes the copy.
    func shareAsset() {
        // I fell like a lot of this "should" be done in a controller class,
        // but as far as I can tell, it would require an escaping closure within another escaping closure
        // to handle opening the copied file in the share sheet and then deleting it once it's gone.
        // That feels like it'd just make things too complicated,
        // so I'm doing it all here the in the view controller.
        
        let fileManager = FileManager.default
        
        contentRequestID = asset?.requestContentEditingInput(with: nil) { contentEditingInput, _ in
            guard let contentEditingInput = contentEditingInput,
                let url = contentEditingInput.fullSizeImageURL,
                let fileName = self.fileName(contentEditingInput: contentEditingInput),
                let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            do {
                // Save a copy to the Documents directory
                let filePath = documents.appendingPathComponent(fileName)
                let data = try Data(contentsOf: url)
                try data.write(to: filePath)
                print("Saved copy of file.")
                
                // Share the copy in the Share Sheet
                DispatchQueue.main.async {
                    let activityController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
                    activityController.popoverPresentationController?.sourceView = self.view
                    activityController.completionWithItemsHandler = { _, _, _, _ in
                        // Delete the copy in the Documents directory
                        do {
                            try fileManager.removeItem(at: filePath)
                            print("Deleted copy of file.")
                        } catch {
                            NSLog("\(error)")
                        }
                    }
                    
                    self.present(activityController, animated: true, completion: nil)
                }
            } catch {
                NSLog("\(error)")
            }
        }
    }
    
    func setName() {
        guard let name = name,
            let meme = meme else { return }
        memeController?.setName(to: name, for: meme, context: CoreDataStack.shared.mainContext)
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
        
        // Save the name
        setName()
        
        // Move to the action after the `name` action
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
