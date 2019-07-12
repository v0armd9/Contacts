//
//  ContactListTableViewController.swift
//  Contacts
//
//  Created by Darin Marcus Armstrong on 7/12/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        performFullSync(completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func performFullSync(completion:((Bool) -> Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ContactController.sharedInstance.fetchContacts { (contacts) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                completion?(contacts != nil)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ContactController.sharedInstance.contacts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.sharedInstance.contacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.phoneNumber

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = ContactController.sharedInstance.contacts[indexPath.row]
            
            ContactController.sharedInstance.delete(contact: contact) { (success) in
                if success {
                    print("Deletion was successful")
                }
            }
        }
            tableView.deleteRows(at: [indexPath], with: .fade)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditDetailView" {
            guard let indexPath = tableView.indexPathForSelectedRow?.row else {return}
            let destinationVC = segue.destination as? ContactDetailViewController
            let contact = ContactController.sharedInstance.contacts[indexPath]
            destinationVC?.contact = contact
        }
    }


}
