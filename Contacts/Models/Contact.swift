//
//  Contact.swift
//  Contacts
//
//  Created by Darin Marcus Armstrong on 7/12/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

//ContactConstants
struct ContactConstants {
    static let recordType = "Contact"
    fileprivate static let nameKey = "Name"
    fileprivate static let phoneNumberKey = "PhoneNumber"
    fileprivate static let emailKey = "Email"
    fileprivate static let recordIDKey = "RecordID"
}

class Contact {
    
    //MARK: - Class Properties
    var name: String
    var phoneNumber: String
    var email: String
    var recordID: CKRecord.ID
    
    //Designated Initializer
    init(name: String, phoneNumber: String = "", email: String = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.recordID = recordID
    }
    
    //Convenience initializer to take in a CKRecord and initialize a contact object
    convenience init?(record: CKRecord) {
        guard let name = record[ContactConstants.nameKey] as? String,
        let phoneNumber = record[ContactConstants.phoneNumberKey] as? String,
        let email = record[ContactConstants.emailKey] as? String
            else {return nil}
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: record.recordID)
    }
}

// Extension on CKRecord to initialize a CKRecord from a Contact
extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactConstants.recordType, recordID: contact.recordID)
        self.setValue(contact.name, forKey: ContactConstants.nameKey)
        self.setValue(contact.phoneNumber, forKey: ContactConstants.phoneNumberKey)
        self.setValue(contact.email, forKey: ContactConstants.emailKey)
    }
}

//Extension on Contact to allow for Delete functionality
extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
