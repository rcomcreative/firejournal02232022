//
//  ICS214ResourceEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/24/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol ICS214ResourceEditVCDelegate: AnyObject {
    func cancelResourceEditVC()
    func saveResourceEdit(_ userAttendeesOID: NSManagedObjectID, index: IndexPath)
}

class ICS214ResourceEditVC: UIViewController {
    
    weak var delegate: ICS214ResourceEditVCDelegate? = nil
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    var userAttendeeOID: NSManagedObjectID!
    var theUserAttendee: UserAttendees!
    lazy var theUserAttendeeProvider: UserAttendeesProvider = {
        let provider = UserAttendeesProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserAttendeeContext: NSManagedObjectContext!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var headerTitle: String = """
Edit Resource
"""
    var ics214ModalHeaderV: ModalHeaderSaveDismiss!
    var ics214TableView: UITableView!
    
    let nc = NotificationCenter.default
    var index: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
     // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
//    MARK: -ALERT-
    func presentAlert() {
        
        let message = InfoBodyText.ics214ResourceAssignedEditNotes.rawValue
        let title = InfoBodyText.ics214ResourceAssignedEditSubject.rawValue
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}

extension ICS214ResourceEditVC {
    
    func configure(_ userAttendeesOID: NSManagedObjectID, index: IndexPath) {
        
        self.userAttendeeOID = userAttendeesOID
        self.index = index
        theUserAttendeeContext = theUserAttendeeProvider.persistentContainer.newBackgroundContext()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: theUserAttendeeContext)
        
        self.theUserAttendee = theUserAttendeeContext.object(with: self.userAttendeeOID) as? UserAttendees
        
        
        configureModalHeaderSaveDismiss()
        configureICS214TableView()

    }
    
    func configureModalHeaderSaveDismiss() {
        ics214ModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        ics214ModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ics214ModalHeaderV)
        ics214ModalHeaderV.modalHTitleL.textColor = UIColor.white
        ics214ModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        ics214ModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        ics214ModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        ics214ModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        ics214ModalHeaderV.modalHTitleL.text = headerTitle
        ics214ModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJIconRed") {
            ics214ModalHeaderV.contentView.backgroundColor = color
        }
        ics214ModalHeaderV.myShift = MenuItems.incidents
        ics214ModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            ics214ModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ics214ModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ics214ModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            ics214ModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureICS214TableView() {
        ics214TableView = UITableView(frame: .zero)
        registerCellsForTable()
        ics214TableView.translatesAutoresizingMaskIntoConstraints = false
        ics214TableView.backgroundColor = .systemBackground
        view.addSubview(ics214TableView)
        ics214TableView.delegate = self
        ics214TableView.dataSource = self
        ics214TableView.separatorStyle = .none
        
        ics214TableView.rowHeight = UITableView.automaticDimension
        ics214TableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            ics214TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            ics214TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            ics214TableView.topAnchor.constraint(equalTo: ics214ModalHeaderV.bottomAnchor, constant: 5),
            ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension ICS214ResourceEditVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        ics214TableView.register(UINib(nibName: "NewICS214LabelTextFieldCell",bundle: nil), forCellReuseIdentifier: "NewICS214LabelTextFieldCell")
    }
    
}

extension ICS214ResourceEditVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag = indexPath.row
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
        cell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
        return cell
    }
    
    func configureNewICS214LabelTextFieldCell(_ cell: NewICS214LabelTextFieldCell, at indexPath: IndexPath, tag: Int)->NewICS214LabelTextFieldCell {
        cell.delegate = self
        cell.tag = tag
        switch tag {
        case 0:
            cell.label = "Name:"
            if let name = theUserAttendee.attendee {
                cell.described = name
            }
            cell.descriptionTF.autocapitalizationType = .words
            cell.path = indexPath
        case 1:
            cell.label = "ICS Position:"
            if let name = theUserAttendee.attendeeICSPosition {
                cell.described = name
            }
            cell.descriptionTF.autocapitalizationType = .words
            cell.path = indexPath
        case 2:
            cell.label = "Home Agency:"
            if let name = theUserAttendee.attendeeHomeAgency {
                cell.described = name
            }
            cell.descriptionTF.autocapitalizationType = .allCharacters
            cell.path = indexPath
        case 3:
            cell.label = "Phone:"
            if let name = theUserAttendee.attendeePhone {
                cell.described = name
            }
            cell.descriptionTF.keyboardType = .numbersAndPunctuation
            cell.path = indexPath
        case 4:
            cell.label = "Email:"
            if let name = theUserAttendee.attendeeEmail {
                cell.described = name
            }
            cell.descriptionTF.keyboardType = .emailAddress
            cell.path = indexPath
        default:
            break
        }
        return cell
    }
    
}

extension ICS214ResourceEditVC: NewICS214LabelTextFieldCellDelegate {
    
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int) {
        let row = indexPath.row
        switch row {
        case 0:
            theUserAttendee.attendee = text
        case 1:
            theUserAttendee.attendeeICSPosition = text
        case 2:
            theUserAttendee.attendeeHomeAgency = text
        case 3:
            theUserAttendee.attendeePhone = text
        case 4:
            theUserAttendee.attendeeEmail = text
        default: break
        }
    }
    
}

extension ICS214ResourceEditVC: ModalHeaderSaveDismissDelegate {
   
    func modalDismiss() {
        delegate?.cancelResourceEditVC()
    }
    
    func modalSave(myShift: MenuItems) {
        theUserAttendee.attendeeModDate = Date()
        theUserAttendee.attendeeBackUp = false
        saveToCoreData {
            let objectID = theUserAttendee.objectID
            delegate?.saveResourceEdit(objectID, index: self.index)
        }
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
    func saveToCoreData(completion: () -> Void) {
        do {
            try theUserAttendeeContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theUserAttendeeContext,userInfo:["info":"UserAttendee saved merge that"])
            }
            let objectID = theUserAttendee.objectID
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name(rawValue: FJkMODIFIEDUSERATTENDEE_TOCLOUDKIT),object:nil ,userInfo:["objectID": objectID])
            }
            
            completion()
        } catch let error as NSError {
            print("NewICS214ResourcesAssignedTVC line 140 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
}
