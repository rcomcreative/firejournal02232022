//
//  ContactsChosen.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import Contacts
import ContactsUI

struct ContactChosen {
    var name: String!
    var firstName: String!
    var middle: String!
    var lastName: String!
    var email: String?
    var phone: String?
    var image: UIImage?
    
    
    init?(cnContact: CNContact) {
        // name
        if !cnContact.isKeyAvailable(CNContactGivenNameKey) && !cnContact.isKeyAvailable(CNContactFamilyNameKey) { return nil }
        self.firstName = cnContact.givenName
        self.lastName = cnContact.familyName
        if cnContact.isKeyAvailable(CNContactMiddleNameKey) {
            if cnContact.middleName.count > 0 {
                self.middle = cnContact.middleName
            }
        }
        self.name = (cnContact.givenName + " " + cnContact.familyName).trimmingCharacters(in: CharacterSet.whitespaces)
        // image
        self.image = (cnContact.isKeyAvailable(CNContactImageDataKey) && cnContact.imageDataAvailable) ? UIImage(data: cnContact.imageData!) : nil
        // email
        if cnContact.isKeyAvailable(CNContactEmailAddressesKey) {
            for possibleEmail in cnContact.emailAddresses {
                let properEmail = possibleEmail.value as String
                if properEmail.isEmail() { self.email = properEmail; break }
            }
        }
        // phone
        if cnContact.isKeyAvailable(CNContactPhoneNumbersKey) {
            if cnContact.phoneNumbers.count > 0 {
                let phone = cnContact.phoneNumbers.first?.value
                self.phone = phone?.stringValue
            }
        }
    }
}
