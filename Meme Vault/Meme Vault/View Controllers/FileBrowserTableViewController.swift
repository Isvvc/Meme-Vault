//
//  FileBrowserTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import FilesProvider

class FileBrowserTableViewController: UITableViewController {
    
    var webdavProvider: WebDAVFileProvider?
    var path: String?
    var folders: [FileObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if path == nil {
            path = "/"
        }
        
        if webdavProvider == nil {
            let host = "https://nextcloud.example.com/remote.php/webdav/"
            
            let credential: URLCredential
            
            let space = URLProtectionSpace(host: host, port: 443, protocol: nil, realm: nil, authenticationMethod: nil)
            if let spaceCred = URLCredentialStorage.shared.defaultCredential(for: space) {
                credential = spaceCred
            } else {
                credential = URLCredential(user: "test", password: "test", persistence: .permanent)
                URLCredentialStorage.shared.set(credential, for: space)
            }
            
            webdavProvider = WebDAVFileProvider(baseURL: URL(string: host)!, credential: credential)
            webdavProvider?.delegate = self
        }
        
        webdavProvider?.contentsOfDirectory(path: path!, completionHandler: { files, error in
            if let error = error {
                NSLog("\(error)")
            }
            
            for file in files where file.isDirectory {
                self.folders.append(file)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)

        let folder = folders[indexPath.row]
        cell.textLabel?.text = folder.name

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: File provider delegate

extension FileBrowserTableViewController: FileProviderDelegate {
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("\(source) copied to \(dest).")
        case .remove(path: let path):
            print("\(path) has been deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) succeed.")
            } else {
                print("\(operation.actionDescription) on \(operation.source) succeed.")
            }
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("copying \(source) to \(dest) has been failed.")
        case .remove:
            print("file can't be deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) failed.")
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
