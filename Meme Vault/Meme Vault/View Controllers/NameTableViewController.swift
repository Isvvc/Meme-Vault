//
//  NameTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

//MARK: NameTableDelegate

protocol NameTableDelegate {
    func setName(_ name: String)
}

class NameTableViewController: UITableViewController {
    
    var textField: UITextField?
    var delegate: NameTableDelegate?
    var name: String?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let name = name,
            !name.isEmpty {
            delegate?.setName(name)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)

        if let cell = cell as? TextFieldTableViewCell {
            self.textField = cell.textField
            textField?.autocapitalizationType = .words
            textField?.returnKeyType = .done
            textField?.delegate = self
            textField?.text = name
            textField?.clearButtonMode = .whileEditing
            textField?.becomeFirstResponder()
        }

        return cell
    }

}

//MARK: Text field delegate

extension NameTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        name = textField.text
        dismiss(animated: true)
        return true
    }
}
