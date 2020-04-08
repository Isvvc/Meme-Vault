//
//  LoginTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import FilesProvider

class LoginTableViewController: UITableViewController {
    
    var serverTextField: UITextField?
    var usernameTextField: UITextField?
    var passwordTextField: UITextField?
    
    var providerController: ProviderController?

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    //MARK: Actions
    
    private func login() {
        guard let providerController = providerController,
            let serverString = serverTextField?.text,
            let server = URL(string: serverString),
            let username = usernameTextField?.text,
            let password = passwordTextField?.text else { return }
        
        providerController.login(host: server, username: username, password: password)
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
            login()
        }
        
        return true
    }
}
