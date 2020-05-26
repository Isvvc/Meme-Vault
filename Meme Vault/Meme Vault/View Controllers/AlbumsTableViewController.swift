//
//  AlbumsTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 3/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Photos

protocol AlbumsTableDelegate {
    func selectAlbum(_ album: PHAssetCollection)
}

class AlbumsTableViewController: UITableViewController {
    
    var actionController: ActionController?
    var delegate: AlbumsTableDelegate?
    
    var userCollections: PHFetchResult<PHCollection>?
    var albums: PHFetchResult<PHAssetCollection>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"

        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Good to proceed")
                self.fetchAlbums()
            case .denied, .restricted:
                print("Not allowed")
                //TODO: Tell user how to enable access
            case .notDetermined:
                print("Not determined yet")
            @unknown default:
                break
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)

        if let collection = albums?.object(at: indexPath.row) {
            cell.textLabel?.text = collection.localizedTitle
        }

        return cell
    }
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let collection = albums?.object(at: indexPath.row) {
            delegate?.selectAlbum(collection)
        }
    }
    
    //MARK: Private
    
    private func fetchAlbums() {
        self.userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        self.albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
