//
//  ContactsModalDataTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/25/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

protocol ContactsModalDataTVCDelegate: AnyObject {
    func contactModalDataCancelled()
    func contactModalDataSaved(crew:Array<CrewFromContact>)
}

class ContactsModalDataTVC: UITableViewController,CellHeaderCancelSaveDelegate {
    
    func cellCancelled() {
        self.dismiss(animated: true, completion: nil)
        delegate?.contactModalDataCancelled()
    }
    
    func cellSaved() {
        self.dismiss(animated: true, completion: nil)
        delegate?.contactModalDataSaved(crew: selected)
    }
    
    weak var delegate: ContactsModalDataTVCDelegate? = nil
    
    var contactStore = CNContactStore()
    var contacts = [ContactChosen]()
    var selected: [CrewFromContact] = []
    
    let nc = NotificationCenter.default
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        
        tableView.register(UINib(nibName: "CrewContactListCell", bundle: nil), forCellReuseIdentifier: "CrewContactListCell")
        
        tableView.allowsMultipleSelection = true
        roundViews()
    }
        
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }

    //    MARK: -view will appear - look for contacts and request useage of contacts
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Loading Contacts.."
        requestAccessToContacts { (success) in
            if success {
                self.retrieveContacts({ (success, contacts) in
                    if success && (contacts?.count)! > 0 {
                        self.contacts = contacts!
                        DispatchQueue.main.async {
                            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                        }
                        self.title = "Choose Contacts"
                    } else {
                        print("unable to load contacts")
                    }
                })
            }
        }
    }
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
                    
                    contacts.append(contact)
                    self.tableView.reloadData()
                    
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
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeaderCancelSave", owner: self, options: nil)?.first as! CellHeaderCancelSave
        cellHeader.headerTitleL.text = "Choose Contacts"
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewContactListCell", for: indexPath) as! CrewContactListCell
        let contact = contacts[indexPath.row] as ContactChosen
        cell.contact = contact
        
//        tableView.reloadData()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewContactListCell
        cell.isSelected = true
        let name = cell.contact?.name ?? ""
        let phone = cell.contact?.phone ?? ""
        let email = cell.contact?.email ?? ""
        let group = CrewFromContact.init(name: name, phone: phone, email: email, crew: [] )
        if cell.contact?.image != nil{
            group.image = cell.contact?.image
        }
        
        if selected.contains(group) {
            print("already exist")
        } else {
            selected.append(group)
            print(group)
        }
//        let result = selected.filter { $0.name != name }
//        if result.isEmpty {
//            selected.append(group)
//        } else {
//            selected.append(group)x
//        }
//        let result = selected.filter { $0.name == name}
//        if !result.isEmpty {
//            selected.append(group)
//        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewContactListCell
        cell.isSelected = false
        let resource = cell.contact?.name
        selected = selected.filter { $0.name != resource }
        print("here is selected removed \(selected)")
    }
}
