//
//  StaffContactVC.swift
//  StationCommand
//
//  Created by DuRand Jones on 7/27/21.
//

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI

protocol StaffContactsVCDelegate: AnyObject {
    func staffChosen(_ staff: NewStaff)
}


class StaffContactsVC: UIViewController {
    
    let contactSearchBar = UISearchBar()

    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard

    var newModalHeaderV: NewModalHeaderV!
    var alertUp: Bool = false
    var staffContactsTableView: UITableView! = nil
    var contactStore = CNContactStore()
    var contacts = [ContactChosen]()
    
    weak var delegate: StaffContactsVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNewModalHeaderV()
        configureContactSearchBar()
        configureStaffContactsTableView()
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
                                self.staffContactsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                            }
                        } else {
                            print("unable to load contacts")
                        }
                    })
                }
            }
        }
    
    func configureNewModalHeaderV() {
        newModalHeaderV = Bundle.main.loadNibNamed("NewModalHeaderV", owner: self, options: nil)?.first as? NewModalHeaderV
        newModalHeaderV.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
        newModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newModalHeaderV)
        newModalHeaderV.theTitle = "Contacts"
        newModalHeaderV.closeB.setTitleColor(.white, for: .normal)
        newModalHeaderV.saveB.setTitleColor(.white, for: .normal)
        newModalHeaderV.saveB.isHidden = true
        newModalHeaderV.saveB.isEnabled = false
        newModalHeaderV.saveB.alpha = 0.0
        newModalHeaderV.theView = .staffing
        newModalHeaderV.contentView.backgroundColor = UIColor(named: "FJBlueColor")
        newModalHeaderV.delegate = self
            NSLayoutConstraint.activate([
                newModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                newModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                newModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                newModalHeaderV.heightAnchor.constraint(equalToConstant: 60),
            ])
    }
    
    func configureContactSearchBar() {
        contactSearchBar.delegate = self
        contactSearchBar.barStyle = .default
        contactSearchBar.showsCancelButton = true
        contactSearchBar.placeholder = "Search by last name."
        contactSearchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactSearchBar)
        NSLayoutConstraint.activate([
            contactSearchBar.heightAnchor.constraint(equalToConstant: 58),
            contactSearchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            contactSearchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            contactSearchBar.topAnchor.constraint(equalTo: newModalHeaderV.bottomAnchor, constant: 5),
            ])
    }
    
    func configureStaffContactsTableView() {
        staffContactsTableView = UITableView(frame: .zero)
        registerCellsForTable()
        staffContactsTableView.translatesAutoresizingMaskIntoConstraints = false
        staffContactsTableView.backgroundColor = .systemBackground
        view.addSubview(staffContactsTableView)
        staffContactsTableView.delegate = self
        staffContactsTableView.dataSource = self
        
        staffContactsTableView.rowHeight = UITableView.automaticDimension
        staffContactsTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            staffContactsTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            staffContactsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            staffContactsTableView.topAnchor.constraint(equalTo: contactSearchBar.bottomAnchor, constant: 5),
            staffContactsTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
    func shiftAlert() {
        if !alertUp {
            let subject = InfoBodyText.newStaffSubject.rawValue
            let message = InfoBodyText.newStaffEntry.rawValue
            let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
   

}
