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
    
    var providerController: ProviderController?
    var path: String?
    var folders: [FileObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if path == nil {
            path = "/"
        }
        
        providerController?.webdavProvider?.contentsOfDirectory(path: path!, completionHandler: { files, error in
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
