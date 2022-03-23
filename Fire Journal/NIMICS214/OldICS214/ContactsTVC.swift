//
//  ContactsTVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/12/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI


protocol ContactsTVCDelegate: AnyObject {

    func contactsCancelBTapped()
    func contactsSaveBTapped(team: [Resource])
}

class ContactsTVC: UITableViewController, CNContactPickerDelegate, CNContactViewControllerDelegate {

    weak var delegate: ContactsTVCDelegate? = nil
    var contactStore = CNContactStore()
    
    var modalCells:Array = [CellParts]()
    
    var contacts = [ContactChosen]()
    var selectedRows: Array<Array<String>>!
    var resources = [Resource]()
    var team =  [UserAttendees]()
    
    let p0 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.listHeader], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty], dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p1 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":""], type: ["Type": FormType.listCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty], dType:["Activity":Date()], objID: [ "objectID":nil ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resources = []
        tableView.register(UINib(nibName: "ContactHeaderCell", bundle: nil), forCellReuseIdentifier: "ContactHeaderCell")
        tableView.register(UINib(nibName: "ContactListCell", bundle: nil), forCellReuseIdentifier: "ContactListCell")
        selectedRows = []
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addNewContact(_:)))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewContact(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancel
        
        let backgroundImage = UIImage(named: "headerBar2")
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.title = "Choose Contacts"
    }
    
    
    
    @objc func cancelNewContact(_ sender:Any) {
        delegate?.contactsCancelBTapped()
    }
    
    
    
    @objc func addNewContact(_ sender:Any) {
        delegate?.contactsSaveBTapped(team: resources)
    }
    
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
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactChosen]?) -> Void) {
        var contacts = [ContactChosen]()
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactChosen(cnContact: cnContact) { contacts.append(contact)
                    
                }
            })
            completion(true, contacts)
        } catch {
            completion(false, nil)
        }
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named:"header")!)
        }
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 100
        default:
            return 90
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactHeaderCell", for: indexPath) as! ContactHeaderCell
            if contacts.count > 1 {
                cell.loadingContactL.isHidden = true
                cell.loadingContactL.alpha = 0.0
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListCell", for: indexPath) as! ContactListCell
            let entry = contacts[(indexPath as NSIndexPath).row]
            cell.configureWithContactEntry(entry)
            cell.layoutIfNeeded()
            
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row != 0 {
            let cellChecked = tableView.cellForRow(at: indexPath) as! ContactListCell
            cellChecked.contactChosenIV.isHidden = false
            cellChecked.contactChosenIV.alpha = 1.0
            let entry = contacts[(indexPath as NSIndexPath).row]
            var phone:String = ""
            var name:String = ""
            var email:String = ""
            if (entry.name) != nil {
                name = entry.name!
            }
            if entry.phone != nil {
                phone = entry.phone!
            }
            if entry.email != nil {
                email = entry.email!
            }
            let selected = Resource.init(contact: ["name" : name, "email": email, "phone": phone])
            resources.append(selected)
//            print(resources)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row != 0 {
            let cellChecked = tableView.cellForRow(at: indexPath) as! ContactListCell
            cellChecked.contactChosenIV.isHidden = true
            cellChecked.contactChosenIV.alpha = 0.0
            let entry = contacts[(indexPath as NSIndexPath).row]
            var phone:String = ""
            var name:String = ""
            var email:String = ""
            if (entry.name) != nil {
                name = entry.name!
            }
            if entry.phone != nil {
                phone = entry.phone!
            }
            if entry.email != nil {
                email = entry.email!
            }
            let selected = Resource.init(contact: ["name" : name, "email": email, "phone": phone])
            let i:Int = resources.firstIndex(where: { $0 == selected })!
            resources.remove(at: i)
        }
    }
    
}
