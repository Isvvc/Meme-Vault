//
//  ProviderController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import FilesProvider

class ProviderController {
    private(set) var webdavProvider: WebDAVFileProvider?
    
    private(set) var host: URL?
    private(set) var credential: URLCredential?
    
    init() {
        host = UserDefaults.standard.url(forKey: "host")
        loadCredentials()
        login()
    }
    
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
        guard let host = host, let credential = credential else { return }
        
        webdavProvider = WebDAVFileProvider(baseURL: host, credential: credential)
        webdavProvider?.delegate = self
    }
}

//MARK: File provider delegate

extension ProviderController: FileProviderDelegate {
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
