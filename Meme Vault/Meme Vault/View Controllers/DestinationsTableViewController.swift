//
//  DestinationsTableViewController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 4/2/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

protocol DestinationsTableDelegate {
    func enter(vc: DestinationsTableViewController)
    func choose(destination: Destination)
}

extension DestinationsTableDelegate {
    func enter(vc: DestinationsTableViewController) {}
}

class DestinationsTableViewController: UITableViewController {
    
    var destinationController: DestinationController?
    var providerController: ProviderController?
    var parentDestination: Destination?
    var delegate: DestinationsTableDelegate?
    var editDestinations = true
    var givenDestinations: [Destination]?
    
    var newDestinationName: String?
    
    lazy var frc: NSFetchedResultsController<Destination> = {
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let givenDestinations = givenDestinations {
            fetchRequest.predicate = NSPredicate(format: "SELF in %@", givenDestinations)
        } else if let parentDestination = parentDestination {
            fetchRequest.predicate = NSPredicate(format: "parent == %@", parentDestination)
        } else {
            fetchRequest.predicate = NSPredicate(format: "parent == nil")
        }
       
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataStack.shared.mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for destinations frc: \(error)")
        }
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentName = parentDestination?.name {
            title = parentName
        }
        
        if !editDestinations {
            if parentDestination == nil {
                navigationItem.rightBarButtonItem = nil
            } else {
                let chooseButton = UIBarButtonItem(title: "Choose", style: .done, target: self, action: #selector(chooseParentDestination(sender:)))
                navigationItem.rightBarButtonItem = chooseButton
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Appear")
        delegate?.enter(vc: self)
    }
    
    //MARK: Actions
    
    @IBAction func addDestination(_ sender: Any) {
        newDestinationName = nil
        
        let alert = UIAlertController(title: "New Destination", message: nil, preferredStyle: .alert)

        var nameTextField: UITextField?
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
            nameTextField = textField
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let save = UIAlertAction(title: "Save without path", style: .default) { _ in
            guard let name = nameTextField?.text,
                !name.isEmpty else { return }
            
            self.destinationController?.createDestination(named: name, path: nil, parent: self.parentDestination, context: CoreDataStack.shared.mainContext)
        }
        
        let pathAction = UIAlertAction(title: "Choose Path", style: .default) { _ in
            guard let name = nameTextField?.text,
                !name.isEmpty else { return }
            
            self.newDestinationName = name
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ChoosePath", sender: self)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        alert.addAction(pathAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func chooseParentDestination(sender: Any) {
        guard let parentDestination = parentDestination else { return }
        delegate?.choose(destination: parentDestination)
    }
    
    func set(destinations: [Destination]) {
        guard !destinations.isEmpty else { return }
        
        // Show these destinations first
        self.givenDestinations = destinations
        
        let givenDestinationsButton = UIBarButtonItem(title: "Specific", style: .plain, target: self, action: #selector(openGivenDestinations))
        navigationItem.rightBarButtonItem = givenDestinationsButton
        title = "All"
        
        openGivenDestinations()
    }
    
    @objc func openGivenDestinations() {
        guard let destinationsVC = storyboard?.instantiateViewController(withIdentifier: "Destinations") as? DestinationsTableViewController else { return }
        
        prepareSegueToDestinationsVC(destinationsVC)
        destinationsVC.givenDestinations = givenDestinations
        
        navigationController?.pushViewController(destinationsVC, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath)

        let destination = frc.object(at: indexPath)
        cell.textLabel?.text = destination.name
        cell.detailTextLabel?.text = destination.path

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return editDestinations
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let destination = frc.object(at: indexPath)
            destinationController?.delete(destination: destination, context: CoreDataStack.shared.mainContext)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController,
            let fileBrowserVC = navigationVC.viewControllers.first as? FileBrowserTableViewController {
            fileBrowserVC.providerController = providerController
            fileBrowserVC.delegate = self
            
            if let parentComponents = parentDestination?.path?.split(separator: "/") {
                for i in 0..<parentComponents.count {
                    let pathComponents = parentComponents.prefix(through: i)
                    let path = "/" + pathComponents.joined(separator: "/")
                    
                    guard let childFileBrowserVC = storyboard?.instantiateViewController(identifier: "FileBrowser") as? FileBrowserTableViewController else { return }
                    childFileBrowserVC.providerController = providerController
                    childFileBrowserVC.delegate = self
                    childFileBrowserVC.path = path
                    childFileBrowserVC.title = String(pathComponents.last!)
                    
                    navigationVC.pushViewController(childFileBrowserVC, animated: false)
                }
            }
        } else if let destinationsVC = segue.destination as? DestinationsTableViewController {
            prepareSegueToDestinationsVC(destinationsVC)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = frc.object(at: indexPath)
                destinationsVC.parentDestination = destination
            }
        }
    }
    
    private func prepareSegueToDestinationsVC(_ destinationsVC: DestinationsTableViewController) {
        destinationsVC.destinationController = destinationController
        destinationsVC.providerController = providerController
        destinationsVC.delegate = delegate
        destinationsVC.editDestinations = editDestinations
    }

}

//MARK: File browser view controller delegate

extension DestinationsTableViewController: FileBrowserViewControllerDelegate {
    func pickFolder(path: String) {
        guard let name = newDestinationName else { return }
        newDestinationName = nil
        
        destinationController?.createDestination(named: name, path: path, parent: self.parentDestination, context: CoreDataStack.shared.mainContext)
    }
}
