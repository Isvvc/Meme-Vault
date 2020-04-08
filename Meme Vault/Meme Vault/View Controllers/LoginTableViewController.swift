//
//  LoginTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {
    
    var serverTextField: UITextField?
    var usernameTextField: UITextField?
    var passwordTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Server" : "Credentials"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)

        if let cell = cell as? TextFieldTableViewCell {
            cell.textField.delegate = self
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            
            switch (indexPath.section, indexPath.row) {
            case (0,0):  // Server
                cell.textField.placeholder = "https://nextcloud.example.com/remote.php/webdav/"
                cell.textField.returnKeyType = .next
                serverTextField = cell.textField
            case (1, 0): // Username
                cell.textField.placeholder = "Username"
                cell.textField.returnKeyType = .next
                usernameTextField = cell.textField
            case (1, 1): // Password
                cell.textField.placeholder = "Password"
                cell.textField.returnKeyType = .send
                cell.textField.isSecureTextEntry = true
                passwordTextField = cell.textField
            default:
                break
            }
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: Text field delegate

extension LoginTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case serverTextField:
            usernameTextField?.becomeFirstResponder()
        case usernameTextField:
            passwordTextField?.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            // Login
        }
        
        return true
    }
}
