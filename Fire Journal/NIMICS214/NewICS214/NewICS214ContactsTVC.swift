//
//  NewICS214ContactsTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

protocol NewICS214ContactsTVCDelegate: AnyObject {
    func newICS214ContactsExit()
    func newICS214ContactsSave(crew: [CrewFromContact])
}

class NewICS214ContactsTVC: UITableViewController {
    
    weak var delegate: NewICS214ContactsTVCDelegate? = nil
    var alertUp: Bool = false
    var contactStore = CNContactStore()
    var contacts = [ContactChosen]()
    var selected = [CrewFromContact]()
    
    let nc = NotificationCenter.default
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }

        registerCells()
        roundViews()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "CrewContactListCell", bundle: nil), forCellReuseIdentifier: "CrewContactListCell")
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
                        self.reloadingTheTable()
                    } else {
                        print("unable to load contacts")
                    }
                })
            }
        }
    }
    
    private func reloadingTheTable() {
        contacts.sort(by: { $0.name < $1.name })
        DispatchQueue.main.async {
            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        }
    }
    
    private func reloadingTheData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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

            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [
                CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor,
            ])
            
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactChosen(cnContact: cnContact) {
                    
                    contacts.append(contact)
                    self.reloadingTheData()
                }
            })
            completion(true, contacts)
        }    catch let error as NSError {
            let nserror = error
            let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print("here is contactsModalDataTVC line 107 error \(errorMessage)")
            completion(false, nil)
        }
    }

    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
     override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerV = Bundle.main.loadNibNamed("RelieveSupervisorContactsHeaderV", owner: self, options: nil)?.first as! RelieveSupervisorContactsHeaderV
         headerV.delegate = self
         headerV.backgroundIV.image = UIImage(named: "EDF0F6-D8E7FA_CellBkgrnd4sq")
           headerV.subjectL.text = "Contacts"
         return headerV
     }
     
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 100
     }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CrewContactListCell", for: indexPath) as! CrewContactListCell
            let contact = contacts[indexPath.row] as ContactChosen
            cell.contact = contact
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
            }
        }
        
        override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let cell = tableView.cellForRow(at: indexPath)! as! CrewContactListCell
            cell.isSelected = false
            let resource = cell.contact?.name
            selected = selected.filter { $0.name != resource }
            print("here is selected removed \(selected)")
        }

}

extension NewICS214ContactsTVC: RelieveSupervisorContactsHeaderVDelegate {
    
    func relieveSupervisorContactsSaveBTapped() {
        delegate?.newICS214ContactsSave(crew:selected )
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorContactsCancelBTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorContactsInfoBTapped() {
        if !alertUp {
               presentAlert()
       }
   }
       
   func presentAlert() {
       let title: InfoBodyText = .contactsSupportNotesSubject
       let message: InfoBodyText = .contactsSupportNotes
       let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
           let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
               self.alertUp = false
           })
           alert.addAction(okAction)
           alertUp = true
           self.present(alert, animated: true, completion: nil)
   }
    
    
}
