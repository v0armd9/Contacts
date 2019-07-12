//
//  ContactController.swift
//  Contacts
//
//  Created by Darin Marcus Armstrong on 7/12/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit
import CloudKit

class ContactController {
    
    //Shared instance (singleton)
    static let sharedInstance = ContactController()
    
    //Local source of truth
    var contacts: [Contact] = []
    
    //Database constant
    let publicDB = CKContainer.default().privateCloudDatabase
    
    // CRUD: - Functions
    
    //Create Functions
    
    func createContactWith(name: String, phoneNumber: String, email: String, completion: @escaping(Contact?) -> Void) {
        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        self.contacts.append(newContact)
        let record = CKRecord(contact: newContact)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record,
                let contact = Contact(record: record) else {completion(nil); return}
            completion(contact)
        }
    }
    
    //Read Functions
    
    func fetchContacts(completion: @escaping([Contact]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ContactConstants.recordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            let contacts = records.compactMap{ Contact(record: $0) }
            self.contacts = contacts
            completion(contacts)
        }
    }
    
    //Update Functions
    
    func update(contact: Contact, withName name: String, phoneNumber: String, email: String) {
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        
        let recordToSave = CKRecord(contact: contact)
        
        updateCloud(record: recordToSave, database: publicDB) { (success) in
            if success {
                print("Contact successfully updated")
            }
        }
    }
    
    func updateCloud(record: CKRecord, database: CKDatabase, completion: @escaping (Bool) -> Void) {
        let modifyOperation = CKModifyRecordsOperation()
        modifyOperation.recordsToSave = [record]
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.qualityOfService = .userInteractive
        modifyOperation.queuePriority = .high
        modifyOperation.completionBlock = {
            completion(true)
        }
        publicDB.add(modifyOperation)
    }
    
    //Delete Functions
    
    func delete(contact: Contact, completion: @escaping(Bool) -> Void) {
        guard let index = contacts.firstIndex(of: contact) else {return}
        contacts.remove(at: index)
        
        deleteFromCloud(recordID: contact.recordID, database: publicDB) { (success) in
            completion(success ? true : false)
        }
    }
    
    func deleteFromCloud(recordID: CKRecord.ID, database: CKDatabase, completion: @escaping (Bool) -> Void) {
        database.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
    
}
