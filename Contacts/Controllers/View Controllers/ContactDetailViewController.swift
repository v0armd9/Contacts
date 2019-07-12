//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by Darin Marcus Armstrong on 7/12/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    var contact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let contact = contact else {return}
        nameTextField.text = contact.name
        phoneNumberTextField.text = contact.phoneNumber
        emailAddressTextField.text = contact.email
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let name =  nameTextField.text, !name.isEmpty,
        let phoneNumber = phoneNumberTextField.text,
        let email = emailAddressTextField.text
            else {return}
        if let contact = contact {
            ContactController.sharedInstance.update(contact: contact, withName: name, phoneNumber: phoneNumber, email: email)
            self.navigationController?.popViewController(animated: true)
        } else {
            ContactController.sharedInstance.createContactWith(name: name, phoneNumber: phoneNumber, email: email) { (contact) in
                if contact != nil {
                    DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
