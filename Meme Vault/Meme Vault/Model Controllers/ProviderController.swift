//
//  ProviderController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Photos
import CoreData
import FilesProvider

class ProviderController {
    private(set) var webdavProvider: WebDAVFileProvider?
    
    private(set) var host: URL?
    private(set) var credential: URLCredential?
    
    private var uploadQueue: [String: Meme] = [:]
    private var contentRequestIDs: [PHAsset: PHContentEditingInputRequestID] = [:]
    
    init() {
        host = UserDefaults.standard.url(forKey: "host")
        loadCredentials()
        login()
    }
    
    //MARK: Credentials
    
    func login(host: URL, username: String, password: String) {
        self.host = host
        UserDefaults.standard.set(host, forKey: "host")
        
        setCredentials(username: username, password: password)
        login()
    }
    
    private func loadCredentials() {
        guard let host = host?.absoluteString else { return }
        
        let space = URLProtectionSpace(host: host, port: 443, protocol: nil, realm: nil, authenticationMethod: nil)
        if let spaceCred = URLCredentialStorage.shared.defaultCredential(for: space) {
            credential = spaceCred
        }
    }
    
    private func setCredentials(username: String, password: String) {
        guard let host = host?.absoluteString else { return }
        
        let space = URLProtectionSpace(host: host, port: 443, protocol: nil, realm: nil, authenticationMethod: nil)

        let credential = URLCredential(user: username, password: password, persistence: .permanent)
        URLCredentialStorage.shared.set(credential, for: space)
        
        self.credential = credential
    }
    
    private func login() {
        guard let host = host,
            let credential = credential else { return }
        
        webdavProvider = WebDAVFileProvider(baseURL: host, credential: credential)
        webdavProvider?.delegate = self
    }
    
    //MARK: Networking
    
    private func appendFileName(to path: String, name: String, fileExtension: String) -> String {
        var output = path
        
        if output.last != "/" {
            output.append("/")
        }
        
        output += "\(name).\(fileExtension)"
        return output
    }
    
    private func appendFileName(to path: String, name: String, sourceURL: URL) -> String {
        appendFileName(to: path, name: name, fileExtension: sourceURL.pathExtension.lowercased())
    }
    
    func upload(meme: Meme, asset givenAsset: PHAsset? = nil) {
        guard !meme.uploaded else {
            NotificationCenter.default.post(name: .uploadComplete, object: self, userInfo: ["success": true])
            return print("Meme already uploaded!")
        }
        
        guard let name = meme.name,
            let destinationPath = meme.destination?.path else { return }
        
        guard uploadQueue[destinationPath] == nil else { return print("Item already queued for \(destinationPath)") }
        
        let asset: PHAsset
        
        if let givenAsset = givenAsset {
            asset = givenAsset
        } else if let id = meme.id,
            let fetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject {
            asset = fetchedAsset
        } else {
            return
        }
        
        contentRequestIDs[asset] = asset.requestContentEditingInput(with: nil) { contentEditingInput, info in
            guard let sourceURL = contentEditingInput?.fullSizeImageURL else { return }
            print(sourceURL)
            let uploadPath = self.appendFileName(to: destinationPath, name: name, sourceURL: sourceURL)
            print(uploadPath)
            self.uploadQueue[uploadPath] = meme
            self.webdavProvider?.copyItem(localFile: sourceURL, to: uploadPath, overwrite: true, completionHandler: nil)
            
            // Cancel the content editing request since we don't actually want to edit the image.
            if let contentRequestID = self.contentRequestIDs[asset] {
                asset.cancelContentEditingInputRequest(contentRequestID)
            }
        }
    }
    
    /// Mark a `Meme` as having completed upload, whether it succeeded or failed.
    /// - Parameters:
    ///   - destination: The destination path of the upload.
    ///   - context: The `NSManagedObjectContext` to use to save the fact that the upload succeeded. **Important**: Leave this `nil` if the upload was not successful.
    func uploadComplete(destination: String, context: NSManagedObjectContext?) {
        var userInfo: [AnyHashable: Any] = [:]
        
        if let context = context {
            // Upload was successful
            let meme = uploadQueue[destination]
            meme?.uploaded = true
            CoreDataStack.shared.save(context: context)
            
            userInfo["success"] = true
        } else {
            userInfo["success"] = false
        }
        
        NotificationCenter.default.post(name: .uploadComplete, object: self, userInfo: userInfo)
        uploadQueue.removeValue(forKey: destination)
    }
}

//MARK: File provider delegate

extension ProviderController: FileProviderDelegate {
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("\(source) copied to \(dest).")
            uploadComplete(destination: dest, context: CoreDataStack.shared.mainContext)
        case .remove(path: let path):
            print("\(path) has been deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) succeed.")
                uploadComplete(destination: destination, context: CoreDataStack.shared.mainContext)
            } else {
                print("\(operation.actionDescription) on \(operation.source) succeed.")
            }
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("copying \(source) to \(dest) has been failed.")
            uploadComplete(destination: dest, context: nil)
        case .remove:
            print("file can't be deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) failed.")
                uploadComplete(destination: destination, context: nil)
            } else {
                print("\(operation.actionDescription) on \(operation.source) failed.")
            }
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .copy(source: let source, destination: let dest) where dest.hasPrefix("file://"):
            print("Downloading \(source) to \((dest as NSString).lastPathComponent): \(progress * 100) completed.")
        case .copy(source: let source, destination: let dest) where source.hasPrefix("file://"):
            print("Uploading \((source as NSString).lastPathComponent) to \(dest): \(progress * 100) completed.")
        case .copy(source: let source, destination: let dest):
            print("Copy \(source) to \(dest): \(progress * 100) completed.")
        default:
            break
        }
    }
}
