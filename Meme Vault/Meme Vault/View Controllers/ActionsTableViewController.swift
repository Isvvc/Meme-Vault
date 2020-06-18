//
//  ActionsTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 6/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ActionsTableViewController: UITableViewController {
    
    var actionController: ActionController?
    var actionSet: ActionSet?
    var delegate: ActionSetPickerDelegate?
    var currentActionIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = actionSet?.name
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(actionChanged(_:)), name: .actionChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.selectRow(at: IndexPath(row: currentActionIndex, section: 0), animated: true, scrollPosition: .none)
        delegate?.performAction(at: currentActionIndex)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionSet?.actions.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)

        if let action = actionSet?.actions[indexPath.row] {
            cell.textLabel?.text = action.name
        }

        return cell
    }
    
    //MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: IndexPath(row: currentActionIndex, section: 0), animated: true)
        currentActionIndex = indexPath.row
        delegate?.performAction(at: currentActionIndex)
    }
    
    //MARK: Private
    
    @objc private func actionChanged(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int else { return }
        
        tableView.deselectRow(at: IndexPath(row: currentActionIndex, section: 0), animated: true)
        currentActionIndex = index
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .bottom)
    }

}
