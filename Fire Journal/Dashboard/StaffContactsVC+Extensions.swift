//
//  StaffContactsVC+Extensions.swift
//  StationCommand
//
//  Created by DuRand Jones on 7/27/21.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import Contacts
import ContactsUI

extension StaffContactsVC {
    
        //    MARK: -request access to users contacts
        func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
            let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            
            switch authorizationStatus {
            case .authorized: completion(true) // authorized previously
            case .denied, .notDetermined: // needs to ask for authorization
                self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) -> Void in
                    completion(accessGranted)
                })
            default: // not authorized.
                completion(false)
            }
        }
    
        //    MARK: -retrieve contacts
        func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactChosen]?) -> Void) {
            var contacts = [ContactChosen]()
            do {
                let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
                try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                    if let contact = ContactChosen(cnContact: cnContact) {
                        if contact.firstName != "" && contact.lastName != "" && !contact.lastName.isNumeric {
                            contacts.append(contact)
                            contacts = contacts.sorted { $0.lastName < $1.lastName }
//                            DispatchQueue.main.async {
//                                self.staffContactsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
//                            }
                        }
                        
                    }
                })
                completion(true, contacts)
            }    catch let error as NSError {
                let nserror = error
                let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
                print("here is contactsModalDataTVC line 111 error \(errorMessage)")
                completion(false, nil)
            }
        }
    
}

extension StaffContactsVC: NewModalHeaderVDelegate {
    
    func theInfoBTapped() {
        shiftAlert()
    }
    
    func modalSaveBTapped(_ theView: TheViews) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func modalCloseBTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension StaffContactsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchContacts(searchText)
    }
    
    func searchContacts(_ contactLast: String) {
        contacts = contacts.filter( { $0.lastName.contains(contactLast) })
        contacts = contacts.sorted { $0.lastName < $1.lastName }
        self.staffContactsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        contactSearchBar.text = ""
        requestAccessToContacts { (success) in
            if success {
                self.retrieveContacts({ (success, contacts) in
                    if success && (contacts?.count)! > 0 {
                        self.contacts = contacts!
                        DispatchQueue.main.async {
                            self.staffContactsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                        }
                    } else {
                        print("unable to load contacts")
                    }
                })
            }
        }
    }
    
}

extension StaffContactsVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        staffContactsTableView.register(UINib(nibName: "CrewContactListCell", bundle: nil), forCellReuseIdentifier: "CrewContactListCell")
    }
    
}

extension StaffContactsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewContactListCell", for: indexPath) as! CrewContactListCell
        let contact = contacts[indexPath.row] as ContactChosen
        cell.contact = contact
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewContactListCell
        cell.isSelected = true
        var newStaff = NewStaff.init()
        let contact = cell.contact
        newStaff.fullName = contact?.name ?? ""
        newStaff.firstName = contact?.firstName ?? ""
        newStaff.mInitial = contact?.middle ?? ""
        newStaff.lastName = contact?.lastName ?? ""
        newStaff.email = contact?.email ?? ""
        newStaff.phone = contact?.phone ?? ""
        newStaff.officerImage = contact?.image
        
        self.dismiss(animated: true, completion: {
            self.delegate?.staffChosen(newStaff)
        })
    }
    
    
}
