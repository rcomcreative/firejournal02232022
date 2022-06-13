//
//  SettingsContactsTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/25/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

protocol SettingsContactsDelegate: AnyObject {
    func settingsContactCancelled()
    func settingsContactSaved(crew:Array<CrewFromContact>)
}

class SettingsContactsTVC: UITableViewController,CellHeaderCancelSaveDelegate {

    func cellCancelled() {
        delegate?.settingsContactCancelled()
    }
    
    func cellSaved() {
        delegate?.settingsContactSaved(crew: selected)
    }
    
    weak var delegate:SettingsContactsDelegate? = nil
    
    var contactStore = CNContactStore()
    var contacts = [ContactChosen]()
    var newContacts = [CNContact]()
    var splitVC: UISplitViewController?
    
    var selected: [CrewFromContact] = []
    var settingType:FJSettings!
    
    let nc = NotificationCenter.default
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = splitVC
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.leftItemsSupplementBackButton = true
            let button3 = splitVC?.displayModeButtonItem
            navigationItem.setLeftBarButtonItems([button3!, button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        }
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            //            let backgroundImage = UIImage(named: "headerBar2")
            //            self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
        self.title = titleName
        
        tableView.register(UINib(nibName: "CrewContactListCell", bundle: nil), forCellReuseIdentifier: "CrewContactListCell")
        
        tableView.allowsMultipleSelection = true
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(doSomething), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func doSomething(refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    
    
    @objc func compactOrRegular(ns: Notification) {    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        if collapsed {
            delegate?.settingsContactCancelled()
        } else {
        nc.post(name:Notification.Name(rawValue:FJkSETTINGSCREWCalled),
                object: nil,
                userInfo: ["sizeTrait":compact])
        }
    }
    @IBAction func updateTheData(_ sender: Any) {
        for ( _, item ) in selected.enumerated() {
            let group = item
            let name = group.name
            //            TODO: save each CrewFromContact to UserAttendee
            let fjUserAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
            group.createGuid()
            fjUserAttendee.attendee = name
            fjUserAttendee.attendeeEmail = group.email
            fjUserAttendee.attendeePhone = group.phone
            fjUserAttendee.attendeeModDate = group.attendeeDate
            fjUserAttendee.attendeeGuid = group.attendeeGuid
            fjUserAttendee.defaultCrewMember = group.overtimeB
        }
        saveToCD()
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Settings Contacts TVC here"])
            }
            let nc = NotificationCenter.default
            if collapsed {
                delegate?.settingsContactSaved(crew: selected)
                DispatchQueue.main.async {
                    nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            } else {
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkSETTINGSCREWCalled),
                        object: nil,
                        userInfo: ["sizeTrait":self.compact])
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            }
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsContactsTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkPERSISTENT_STORE_ERROR_REPORTING), object: nil, userInfo:["errorMessage":errorMessage])
//            }
        }
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
                self.retrieveTheContacts()
//                self.retrieveContacts({ (success, contacts) in
//                    if success && (contacts?.count)! > 0 {
//                        self.contacts = contacts!
//                    } else {
//                        print("unable to load contacts")
//                    }
//                })
                self.title = "Choose Contacts"
            } else {
                self.title = "Loading Contacts"
            }
        }
        self.tableView.reloadData()
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
    private func retrieveTheContacts() {
        
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
//                for phoneNumber in contact.phoneNumbers {
//                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
//                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
//                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
//                    }
//                }
            }
//            print(contacts)
            newContacts = contacts
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print("here is settingsContactTVC line 251 error \(errorMessage)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactChosen]?) -> Void) {
        
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactChosen(cnContact: cnContact) {
                    
                    self.contacts.append(contact)
                    self.tableView.reloadData()
                    
                }
            })
            completion(true, contacts)
        }    catch let error as NSError {
            let nserror = error
            let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print("here is settingsContactsTVC line 275 error \(errorMessage)")
            completion(false, nil)
        }
        
        self.tableView.reloadData()
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newContacts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cellHeader = Bundle.main.loadNibNamed("CellHeaderCancelSave", owner: self, options: nil)?.first as! CellHeaderCancelSave
//        cellHeader.headerTitleL.text = "Choose Contacts"
//        cellHeader.delegate = self
//        return cellHeader
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewContactListCell", for: indexPath) as! CrewContactListCell
//        let contact = contacts[indexPath.row] as ContactChosen
        let contact = newContacts[indexPath.row] as CNContact
        cell.contact2 = contact
        
        //        tableView.reloadData()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewContactListCell
        cell.isSelected = true
//        let name = cell.contact?.name ?? ""
//        let phone = cell.contact?.phone ?? ""
//        let email = cell.contact?.email ?? ""
        let name = cell.contact1TF.text ?? ""
        let phone = cell.contact3TF.text ?? ""
        let email = cell.contact2TF.text ?? ""
        
        let group = CrewFromContact.init(name: name, phone: phone, email: email, crew: [] )
        if cell.contactIV.image != nil{
            group.image = cell.contactIV.image
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
//        let resource = cell.contact?.name
        let resource = cell.contact1TF.text
        selected = selected.filter { $0.name != resource }
        print("here is selected removed \(selected)")
    }

}
