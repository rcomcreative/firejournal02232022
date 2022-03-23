//
//  IncidentEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/15/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol IncidentEditVCDelegate: AnyObject {
    func editSaveTapped(objectID: NSManagedObjectID)
    func editCancelTapped()
}

class IncidentEditVC: UIViewController {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var objectID: NSManagedObjectID!
    var theIncident: Incident!
    var theIncidentTime: IncidentTimer!
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    weak var delegate: IncidentEditVCDelegate? = nil
    
    var headerTitle: String = """
Edit Incident
"""
    var incidentModalHeaderV: ModalHeaderSaveDismiss!
    var incidentTableView: UITableView!
    var segmentType: MenuItems!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if objectID != nil {
            theIncident = context.object(with: objectID) as? Incident
            if theIncident.incidentTimerDetails != nil {
                theIncidentTime = theIncident.incidentTimerDetails
            }
        }
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        configureModalHeaderSaveDismiss()
        configureIncidentTableView()
    }
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func configureModalHeaderSaveDismiss() {
        incidentModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        incidentModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(incidentModalHeaderV)
        incidentModalHeaderV.modalHTitleL.textColor = UIColor.white
        incidentModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        incidentModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        incidentModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        incidentModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        incidentModalHeaderV.modalHTitleL.text = headerTitle
        incidentModalHeaderV.infoB.setTitle("", for: .normal)
        let color = UIColor(named: "FJIconRed")
        incidentModalHeaderV.contentView.backgroundColor = color
        incidentModalHeaderV.myShift = MenuItems.incidents
        incidentModalHeaderV.delegate = self
        NSLayoutConstraint.activate([
            incidentModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            incidentModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            incidentModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            incidentModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureIncidentTableView() {
        incidentTableView = UITableView(frame: .zero)
        registerCellsForTable()
        incidentTableView.translatesAutoresizingMaskIntoConstraints = false
        incidentTableView.backgroundColor = .systemBackground
        view.addSubview(incidentTableView)
        incidentTableView.delegate = self
        incidentTableView.dataSource = self
        incidentTableView.separatorStyle = .none
        
        incidentTableView.rowHeight = UITableView.automaticDimension
        incidentTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            incidentTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            incidentTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentTableView.topAnchor.constraint(equalTo: incidentModalHeaderV.bottomAnchor, constant: 5),
            incidentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }

}

extension IncidentEditVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func modalSave(myShift: MenuItems) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
            }
            let objectID = theIncident.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue :FJkCKModifyIncidentToCloud),
                             object: nil,
                             userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            DispatchQueue.main.async {
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            delegate?.editSaveTapped(objectID: theIncident.objectID)
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "IncidentEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
        //    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func presentAlert() {
        let message: InfoBodyText = .editIncidentSubject
        let title: InfoBodyText = .editIncidentDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension IncidentEditVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        incidentTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        incidentTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        incidentTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
    }
    
}

extension IncidentEditVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 85
        case 1:
            return 60
        case 2:
            return 84
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
            cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
            cell.configureTheLabel(width: 125)
            cell.configureDatePickersHoldingV()
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
            cell = configureSegmentCell(cell, index: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        switch row {
        case 0:
            cell.delegate = self
            cell.theShift = MenuItems.incidents
            cell.subjectL.text = "Incident Number"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
            if let number = theIncident.incidentNumber {
                cell.descriptionTF.text = number
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        default: break
        }
        return cell
    }
    
    func configureSegmentCell(_ cell: SegmentCell, index: IndexPath) -> SegmentCell {
        let tag = index.row
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Incident Type"
        cell.myShift = .incidents
        cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
        cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
        cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
        
        if theIncident.situationIncidentImage == "" {
            theIncident.situationIncidentImage = "Fire"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_fireboard"
            segmentType = MenuItems.fire
        }
        
        switch segmentType {
        case .fire:
            cell.typeSegment.selectedSegmentIndex = 0
        case .ems:
            cell.typeSegment.selectedSegmentIndex = 1
        case .rescue:
            cell.typeSegment.selectedSegmentIndex = 2
        default:
            cell.typeSegment.selectedSegmentIndex = 0
        }
        return cell
    }
    
    func configureLabelSingleDateFieldCell(_ cell: LabelSingleDateFieldCell, index: IndexPath ) -> LabelSingleDateFieldCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 1:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theIncident != nil {
                    if let alarmTime = theIncidentTime.incidentAlarmDateTime {
                        cell.theFirstDose = alarmTime
                    } else {
                        if let alarmTime = theIncident.incidentModDate {
                            cell.theFirstDose = alarmTime
                            theIncidentTime.incidentAlarmDateTime = alarmTime
                        }
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
}


extension IncidentEditVC: SegmentCellDelegate {
    
    func sectionChosen(type: MenuItems) {
        switch type {
        case .fire:
            theIncident.situationIncidentImage = "Fire"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_fireboard"
            segmentType = MenuItems.fire
        case .ems:
            theIncident.situationIncidentImage = "EMS"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_emsboard"
            segmentType = MenuItems.ems
        case .rescue:
            theIncident.situationIncidentImage = "Rescue"
            theIncident.incidentEntryTypeImageName = "100515IconSet_092016_rescueboard"
            segmentType = MenuItems.rescue
        default: break
        }
    }
    
    
}

extension IncidentEditVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theIncidentTime.incidentAlarmDateTime = date
    }
    
}

extension IncidentEditVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        theIncident.incidentNumber = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems) {
        theIncident.incidentNumber = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    
}

