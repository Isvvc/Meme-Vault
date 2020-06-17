//
//  MemeViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 5/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos
import OverlayContainer

class MemeViewController: UIViewController {
    
    //MARK: Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: Properties
    
    var overlayContainerView: PassThroughView?
    var overlayController: OverlayContainerViewController?
    
    var actionController: ActionController?
    var actionSetIndex: Int = 0
    var currentActionIndex: Int = 0
    
    var collectionController: CollectionController?
    var collection: AlbumCollection?
    
    var memeController: MemeController?
    var meme: Meme?
    var asset: PHAsset?
    var contentRequestID: PHContentEditingInputRequestID?
    
    var providerController: ProviderController?
    
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
    
    override func viewSafeAreaInsetsDidChange() {
        guard let overlayContainerView = overlayContainerView else { return }
        overlayContainerView.pinToSuperview(with: view.safeAreaInsets)
    }
    
    private func setUpViews() {
        // Load the image
        DispatchQueue.global(qos: .userInitiated).async {
            // Doing this in a background thread because the fetchFirstImage function can take a while
            guard let collection = self.collection,
                let photo = self.collectionController?.fetchFirstImage(from: collection, context: CoreDataStack.shared.mainContext) else {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
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
        
        // Add Destinations overlay
        if let navigationVC = storyboard?.instantiateViewController(identifier: "DestinationsNav") as? UINavigationController,
            let destinationsVC = navigationVC.viewControllers.first as? DestinationsTableViewController {
            
            destinationsVC.editDestinations = false
            destinationsVC.delegate = self

            let overlayContainerView = PassThroughView()
            self.overlayContainerView = overlayContainerView
            view.addSubview(overlayContainerView)
            
            let overlayController = OverlayContainerViewController()
            overlayController.delegate = self
            overlayController.viewControllers = [navigationVC]
            addChild(overlayController, in: overlayContainerView)
            overlayController.drivingScrollView = destinationsVC.tableView
            self.overlayController = overlayController
            
            // Add shadow
            let navLayer = navigationVC.view.layer
            // navLayer.cornerRadius = 8 // Doesn't work because `masksToBounds` is set to `false`
            navLayer.shadowColor = UIColor.black.cgColor
            navLayer.shadowOpacity = 0.125
            navLayer.shadowRadius = 8
            navLayer.masksToBounds = false
        }
        
//        overlayController?.moveOverlay(toNotchAt: 1, animated: true)
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
            } else {
                title = "Name"
                // For some reason this causes the view controller to lag out if this is the first action called
//                nameTextField.becomeFirstResponder()
            }
        
        case .upload:
            title = "Uplading"
            guard let meme = meme else { return }
            providerController?.upload(meme: meme, asset: asset)
        
        case .share:
            title = "Share"
            shareAsset()
            
        case .destination:
            title = "Destination"
            if meme?.destination != nil {
                currentActionIndex += 1
                performCurrentAction()
            } else {
                overlayController?.moveOverlay(toNotchAt: 2, animated: true)
            }
        
        case .delete:
            guard let meme = meme else { return }
            memeController?.flagForDeletion(meme: meme, context: CoreDataStack.shared.mainContext)
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
    
    @discardableResult func setName() -> Bool {
        guard let name = name,
            let meme = meme else { return false }
        memeController?.setName(to: name, for: meme, context: CoreDataStack.shared.mainContext)
        return true
    }
    
    func setDestination(_ destination: Destination) {
        guard let meme = meme else { return }
        memeController?.setDestination(to: destination, for: meme, context: CoreDataStack.shared.mainContext)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController,
            let actionSetPicker = navigationVC.viewControllers.first as? ActionSetPickerTableViewController {
            actionSetPicker.actionController = actionController
            actionSetPicker.delegate = self
        }
    }
    
}

//MARK: Text field delegate

extension MemeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        overlayController?.moveOverlay(toNotchAt: 1, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Save the name
        guard setName() else { return true }
        
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
//        performCurrentAction()
    }
    
    func performAction(at index: Int) {
        currentActionIndex = index
        performCurrentAction()
    }
}

//MARK: Overlay container view controller delegate

extension MemeViewController: OverlayContainerViewControllerDelegate {
    
    enum OverlayNotch: Int, CaseIterable {
        case minimum, medium, maximum
    }

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch OverlayNotch.allCases[index] {
        case .maximum:
            return availableSpace * 7 / 8
        case .medium:
            return 200
        case .minimum:
            return 40
        }
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController, didMoveOverlay overlayViewController: UIViewController, toNotchAt index: Int) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (index != 2)
    }
}

//MARK: Destinations table delegate

extension MemeViewController: DestinationsTableDelegate {
    func choose(destination: Destination) {
        setDestination(destination)
        overlayController?.moveOverlay(toNotchAt: 1, animated: true)
        
        // Move to the action after the `destination` action
        if let destinationActionIndex = actionSet?.actions.firstIndex(of: .destination) {
            currentActionIndex = destinationActionIndex + 1
        }
        
        performCurrentAction()
    }
}
