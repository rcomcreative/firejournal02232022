//
//  ICS214NewFSOVC+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/6/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

extension ICS214NewFSOVC {
    
    func addObservers() {
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        nc.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func grabTheManagedObjects() {
        
        if theUserOID != nil {
            theUser = context.object(with: theUserOID) as? FireJournalUser
        } else {
            delegate?.cancelTheICS214NewFSO()
        }
        
        if theUserTimeOID != nil {
            theUserTime = context.object(with: theUserTimeOID) as? UserTime
        } else {
            delegate?.cancelTheICS214NewFSO()
        }
        
        if theJournalOID != nil {
            theJournal = context.object(with: theJournalOID) as? Journal
            if theJournal.theLocation != nil {
                theJournalLocation = theJournal.theLocation
                theJournal.locationAvailable = true
            } else {
                theJournal.locationAvailable = false
                theJournalLocation = FCLocation(context: context)
                theJournal.theLocation = theJournalLocation
            }
        }
        
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
    
    func configureics214TableView() {
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
            ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60),
        ])
    }
    
}

extension ICS214NewFSOVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        if theICS214Form != nil {
            if !masterOrNot {
                theMasterICS214Form.removeFromMaster(theICS214Form)
            }
            context.delete(theICS214Form)
            context.delete(theJournal)
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"New ICS214Form merge that"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "New ICS214Form saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
            theICS214Form = nil
        }
        delegate?.cancelTheICS214NewFSO()
    }
    
    func modalSave(myShift: MenuItems) {
        
        if theUser != nil {
            theUser.addToFireJournalUserICS214Info(theICS214Form)
            if let agency = theICS214Form.ics241HomeAgency {
                theUser.ics214HomeAgency = agency
            }
            if let position = theICS214Form.ics214ICSPosition {
                theUser.ics214Position = position
            }
        }
        
        if theUserTime != nil {
            theUserTime.addToIcs214(theICS214Form)
        }
        
        buildTheJournalSummary()
        
        theICS214Form.ics214BackedUp = false
        theICS214Form.ics214Completed = false
        theICS214Form.ics214ModDate = theICS214Form.ics214FromTime
        
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            let objectID = theICS214Form.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkNEWICS214FormCreated), object: nil, userInfo: ["objectID":objectID])
                print("rawValue: FJkNEWICS214FormCreated")
            }
            let jOID = theJournal.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkCKModifyJournalToCloud), object: nil, userInfo: ["objectID":jOID])
                print("rawValue:FJkCKModifyJournalToCloud")
            }
            
            DispatchQueue.main.async {
                let objectID = self.theJournalLocation.objectID
                    self.nc.post(name: .fireJournalModifyFCLocationToCloud, object: nil, userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            if let utOID = theUserTimeOID {
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue: FJkCKMODIFIEDSTARTENDTOCLOUD), object: nil, userInfo: ["objectID": utOID])
                    print("rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD")
                }
            }
            if let uOID = theUserOID {
                DispatchQueue.main.async {
                    self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": uOID])
                    print("rawValue: fireJournalUserModifiedSendToCloud")
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkICS214_NEW_TO_LIST),
                             object: nil,
                             userInfo: ["objectID": ""])
                print("rawValue: FJkICS214_NEW_TO_LIST")
            }
            delegate?.saveTheICS214NewFSO(objectID: objectID)
        } catch let error as NSError {
            let message = "ICS214NewVC Save Error: \(error.localizedDescription)"
            errorAlert(errorMessage: message)
        }
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
    func buildTheJournalEntry() {
        
        theJournal = Journal(context: context)
        var uuidJ = NSUUID().uuidString
        if let journalDate = theICS214Form.ics214FromTime {
            let stringDate = dateFormatter.string(from: journalDate)
            uuidJ = uuidJ+stringDate
            uuidJ = "01."+uuidJ
            theJournal.fjpJGuidForReference = uuidJ
            theICS214Form.journalGuid = uuidJ
            theJournal.fjpJournalModifiedDate = journalDate
            theJournal.journalEntryTypeImageName = "administrativeNewColor58"
            theJournal.journalEntryType = "Station"
            if let platoon = theUser.tempPlatoon {
                theJournal.journalTempPlatoon = platoon
            }
            if let assignment = theUser.tempAssignment {
                theJournal.journalTempAssignment = assignment
            }
            if let apparatus = theUser.tempApparatus {
                theJournal.journalTempApparatus = apparatus
            }
            if let fireStation = theUser.tempFireStation {
                theJournal.journalTempFireStation = fireStation
            }
            theJournal.journalEntryType = "Station"
            theJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
            let aDate = dateFormatter.string(from: journalDate)
            theJournal.journalDateSearch = aDate
            theJournal.journalCreationDate = journalDate
            theJournal.journalModDate = journalDate
            theJournal.journalPrivate = true
            theJournal.journalBackedUp = false
            theJournal.ics214Effort = "Local Incident"
            theJournal.journalHeader = "ICS 214 Activity Log: Local Incident"
            if let masterGuid = theICS214Form.ics214MasterGuid {
                theJournal.ics214MasterGuid = masterGuid
            }
            if let fjuGuid = theUser.userGuid {
                theJournal.fjpUserReference = fjuGuid
            }
            let overview = "New ICS214 Activity Log entered"
            theJournal.journalOverviewSC = overview as NSObject
            
            
        }
        theICS214Form.ics214JournalInfo = theJournal
        theUser.addToFireJournalUserDetails(theJournal)
        theUserTime.addToJournal(theJournal)
        
        
    }
    
    func buildTheJournalSummary() {
        if let journalDate = theICS214Form.ics214FromTime {
            let theJournalDate = dateFormatter.string(from: journalDate)
            var theIncidentName: String = ""
            var theName: String = ""
            var formType: String = ""
            if let theType =  theICS214Form.ics214Effort {
                formType = theType
            }
            if let name = theICS214Form.ics214UserName {
                theName = name
            }
            if let effortName = theICS214Form.ics214IncidentName {
                theIncidentName = effortName
            }
            let summary = "Time Stamp: \(theJournalDate)\nICS 214 Activity Log: \(formType) Effort: \(theIncidentName) entered by \(theName)"
            theJournal.journalSummarySC = summary as NSObject
        }
    }
    
    
}

extension ICS214NewFSOVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        ics214TableView.register(UINib(nibName: "NewICS214HeaderCell", bundle: nil), forCellReuseIdentifier: "NewICS214HeaderCell")
        ics214TableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        ics214TableView.register(UINib(nibName: "NewICS214LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "NewICS214LabelTextFieldCell")
        ics214TableView.register(UINib(nibName: "NewICS214DateTimeCell", bundle: nil), forCellReuseIdentifier: "NewICS214DateTimeCell")
        
        ics214TableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        ics214TableView.register(UINib(nibName: "NewICS214DatePickerCell", bundle: nil), forCellReuseIdentifier: "NewICS214DatePickerCell")
        ics214TableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        ics214TableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        ics214TableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        ics214TableView.register(ICS214IncidentAddressTVCell.self, forCellReuseIdentifier: "ICS214IncidentAddressTVCell")
        ics214TableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
    }
    
    func configureICS214IncidentAddressTVCell(_ cell: ICS214IncidentAddressTVCell, index: IndexPath) -> ICS214IncidentAddressTVCell {
        var typeOfAddress: String = ""
        switch type {
        case .incidentForm: break
        case .femaTaskForceForm:
            typeOfAddress = "FEMA Task Force "
        case .strikeForceForm:
            typeOfAddress = "Strike Team "
        case .otherForm:
            typeOfAddress = "Other "
        default: break
        }
        cell.header = typeOfAddress + "Address"
        cell.address = theIncidentAddress
        cell.latitude = "Latitude: "  + theLatitude
        cell.longitude = "Longitude: " + theLongitude
        switch type {
        case .incidentForm: break
        case .femaTaskForceForm:
            cell.imageName = "ICS214FormFEMA"
        case .strikeForceForm:
            cell.imageName = "ICS214FormSTRIKETEAM"
        case .otherForm:
            cell.imageName = "ICS214FormOTHER"
        default: break
        }
        
        return cell
    }
    
        //    MARK:- Address fields and buttons cell
    
        /// configuring the NewAddressFieldsButtonsCell
        /// - Parameters:
        ///   - cell: NewAddressFieldsButtonsCell
        ///   - indexPath: indexPath of cell
        ///   - tag: cell.tag int
        /// - Returns: street, city, state, zip, latitude, and longitude with map buttons
    func configureNewAddressFieldsButtonsCell(_ cell: NewAddressFieldsButtonsCell, at indexPath: IndexPath, tag: Int) -> NewAddressFieldsButtonsCell {
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Address:"
        var streetAddress: String = ""
        var city: String = ""
        var state: String = ""
        var zip: String = ""
        var latitude: String = ""
        var longitude: String = ""
        if theJournal.locationAvailable {
            if theJournal.theLocation != nil {
                if let theJournalLocation = theJournal.theLocation {
                    
                    if let number = theJournalLocation.streetNumber {
                        streetAddress = number + " "
                    }
                    if let street = theJournalLocation.streetName {
                        streetAddress = streetAddress + street
                    }
                    if let c = theJournalLocation.city {
                        city = c
                    }
                    if let s = theJournalLocation.state {
                        state = s
                    }
                    if let z = theJournalLocation.zip {
                        zip = z
                    }
                    if theJournalLocation.latitude != 0.0 {
                        latitude = String(theJournalLocation.latitude)
                    }
                    if theJournalLocation.longitude != 0.0 {
                        longitude = String(theJournalLocation.longitude)
                    }
                }
            }
        }
        cell.addressTF.text = streetAddress
        cell.addressTF.placeholder = "100 Grant"
        cell.addressTF.textColor = UIColor(named: "FJIconRed")
        cell.cityTF.text = city
        cell.cityTF.placeholder = "City"
        cell.cityTF.textColor = UIColor(named: "FJIconRed")
        cell.stateTF.text = state
        cell.stateTF.placeholder = "State"
        cell.stateTF.textColor = UIColor(named: "FJIconRed")
        cell.zipTF.text = zip
        cell.zipTF.placeholder = "Zip Code"
        cell.zipTF.textColor = UIColor(named: "FJIconRed")
        cell.addressLatitudeTF.text = latitude
        cell.addressLatitudeTF.textColor = UIColor(named: "FJIconRed")
        cell.addressLongitudeTF.text = longitude
        cell.addressLongitudeTF.textColor = UIColor(named: "FJIconRed")
        cell.addressLatitudeTF.placeholder = "Latitude"
        cell.addressLongitudeTF.placeholder = "Longitude"
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        cell.tag = row
        switch row {
        case 1:
            cell.delegate = self
            cell.theShift = MenuItems.ics214
            cell.subjectL.text = "Event Type"
            cell.descriptionTF.tag = row
            cell.descriptionTF.textColor = .label
            
            if let ics214Effort = theICS214Form.ics214Effort {
                var effort: String = ""
                if ics214Effort == "incidentForm" {
                    effort = "Incident Form"
                } else if ics214Effort == "femaTaskForceForm" {
                    effort = "FEMA Task Force"
                } else if ics214Effort == "strikeForceForm" {
                    effort = "Strike Team"
                } else if ics214Effort == "otherForm" {
                    effort = "Other"
                } else {
                    effort = "Incident Form"
                }
                cell.descriptionTF.text = effort
            } else {
                var effort: String = ""
                switch type {
                case .incidentForm: break
                case .femaTaskForceForm:
                    effort = "FEMA Task Force"
                case .strikeForceForm:
                    effort = "Strike Team"
                case .otherForm:
                    effort = "Other"
                default: break
                }
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: effort,attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 2:
            cell.delegate = self
            cell.theShift = MenuItems.ics214
            cell.subjectL.text = "Event Team "
            cell.descriptionTF.tag = row
            cell.descriptionTF.textColor = .label
            if let  ics214TeamName = theICS214Form.ics214TeamName {
                cell.descriptionTF.text = ics214TeamName
            } else {
                var effort: String = ""
                switch type {
                case .incidentForm: break
                case .femaTaskForceForm:
                    effort = "FEMA Task Force"
                case .strikeForceForm:
                    effort = "Strike Team"
                case .otherForm:
                    effort = "Other"
                default: break
                }
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: effort + " team",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 4:
            cell.delegate = self
            cell.theShift = MenuItems.ics214
            cell.subjectL.text = "Event Name"
            cell.descriptionTF.tag = row
            cell.descriptionTF.textColor = .label
            if let ics214IncidentName = theICS214Form.ics214IncidentName {
                cell.descriptionTF.text = ics214IncidentName
            } else {
                var effort: String = ""
                switch type {
                case .incidentForm: break
                case .femaTaskForceForm:
                    effort = "FEMA Task Force"
                case .strikeForceForm:
                    effort = "Strike Team"
                case .otherForm:
                    effort = "Other"
                default: break
                }
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: effort + " Evemt",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 7:
            cell.delegate = self
            cell.theShift = MenuItems.ics214
            cell.subjectL.text = "Name"
            cell.descriptionTF.tag = row
            cell.descriptionTF.textColor = .label
            if let ics214UserName = theICS214Form.ics214UserName {
                cell.descriptionTF.text = ics214UserName
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Bob Smith",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 8:
            cell.delegate = self
            cell.theShift = MenuItems.ics214
            cell.subjectL.text = "ICS Position"
            cell.descriptionTF.tag = row
            cell.descriptionTF.textColor = .label
            if let ics214ICSPosition = theICS214Form.ics214ICSPosition {
                cell.descriptionTF.text = ics214ICSPosition
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "ICS Position",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 9:
            cell.delegate = self
            cell.theShift = MenuItems.ics214
            cell.subjectL.text = "Home Agency"
            cell.descriptionTF.tag = row
            cell.descriptionTF.textColor = .label
            if let ics241HomeAgency = theICS214Form.ics241HomeAgency {
                cell.descriptionTF.text = ics241HomeAgency
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Home Agency",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        default: break
        }
        return cell
    }
    
    func configureLabelDateiPhoneTVCell(_ cell: LabelDateiPhoneTVCell, index: IndexPath) -> LabelDateiPhoneTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 6:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time From"
                if theICS214Form != nil {
                    if let alarmTime = theICS214Form.ics214FromTime {
                        cell.theFirstDose = alarmTime
                    } else {
                        if let alarmTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = alarmTime
                            theICS214Form.ics214FromTime = alarmTime
                        }
                    }
                }
            default: break
            }
        default: break
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
            case 6:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time From"
                if theICS214Form != nil {
                    if let fromTime = theICS214Form.ics214FromTime {
                        cell.theFirstDose = fromTime
                    } else {
                        if let fromTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = fromTime
                            theICS214Form.ics214FromTime = fromTime
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

extension ICS214NewFSOVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 125
        case 1, 2, 4, 7, 8, 9:
            return 85
        case 3:
            if theJournal.locationAvailable {
                return 100
            } else {
                if Device.IS_IPHONE {
                    return 390
                } else {
                    return  310
                }
            }
        case 5:
            return 60
        case 6:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 100
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214HeaderCell", for: indexPath) as! NewICS214HeaderCell
            cell.subjectL.text = "ICS 214 Activity Log"
            return cell
        case 1, 2, 4, 7, 8, 9:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 3:
            if theJournal.locationAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214IncidentAddressTVCell", for: indexPath) as! ICS214IncidentAddressTVCell
                cell = configureICS214IncidentAddressTVCell(cell, index: indexPath)
                cell.configure()
                return cell
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewAddressFieldsButtonsCell", for: indexPath) as! NewAddressFieldsButtonsCell
                let tag = indexPath.row
                cell = configureNewAddressFieldsButtonsCell( cell , at: indexPath , tag: tag)
                cell.configureNewMapButton(type: IncidentTypes.allIncidents)
                cell.configureNewLocationButton(type: IncidentTypes.allIncidents)
                return cell
            }
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.modalTitleL.text = "2. Operational Period:"
            cell.infoB.isHidden = true
            cell.infoB.isEnabled = false
            cell.infoB.alpha = 0.0
            return cell
        case 6:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
            cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            return cell
        }
    }
    
}

extension ICS214NewFSOVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        theICS214Form.ics214FromTime = theDate
    }
    
}

extension ICS214NewFSOVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theICS214Form.ics214FromTime = date
    }
    
}

extension ICS214NewFSOVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        if theICS214Form != nil {
        switch tag {
        case 1:
            theICS214Form.ics214Effort = text
        case 2:
            theICS214Form.ics214TeamName = text
        case 4:
            theICS214Form.ics214IncidentName = text
        case 7:
            theICS214Form.ics214UserName = text
        case 8:
            theICS214Form.ics214ICSPosition = text
            if theUser != nil {
                theUser.ics214Position = text
            }
        case 9:
            theICS214Form.ics241HomeAgency = text
            if theUser != nil {
                theUser.ics214HomeAgency = text
            }
        default: break
        }
        }
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    
}

extension ICS214NewFSOVC: NewAddressFieldsButtonsCellDelegate {
    
        //    MARK: -AddressFieldsButtonsCellDelegate-
    
    func worldBTapped(tag: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "OnBoard", bundle:nil)
        let onBoardAddressSearchlVC = storyBoard.instantiateViewController(withIdentifier: "OnBoardAddressSearch") as! OnBoardAddressSearch
        guard let region = getUserLocation.cameraBoundary else {
            mapAlert()
            return }
        theUserRegion = region
        onBoardAddressSearchlVC.type = IncidentTypes.allIncidents
        onBoardAddressSearchlVC.boundarys = theUserRegion
        onBoardAddressSearchlVC.searches = getUserLocation.searchBoundary
        onBoardAddressSearchlVC.stationBoundary = getUserLocation.mapBoundary
        onBoardAddressSearchlVC.theMapTag = tag
        onBoardAddressSearchlVC.delegate = self
        self.present(onBoardAddressSearchlVC, animated: true, completion: nil)
    }
    
    func worldB2Tapped(tag: Int) {
    }
    
    func locationBTapped(tag: Int) {
        guard let location = getUserLocation.currentLocation else {
            mapAlert()
            return
        }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            switch tag {
            case 3:
                self.theJournalLocation.latitude = location.coordinate.latitude
                self.theJournalLocation.longitude = location.coordinate.longitude
                guard let count = placemarks?.count else {
                    self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                    return
                }
                if count != 0 {
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theJournalLocation.city = "\(pmCity)"
                        } else {
                            self.theJournalLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theJournalLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theJournalLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theJournalLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theJournalLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theJournalLocation.state = "\(pmState)"
                        } else {
                            self.theJournalLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theJournalLocation.zip = "\(pmZip)"
                        } else {
                            self.theJournalLocation.zip = ""
                        }
                        
                        if let number = self.theJournalLocation.streetNumber {
                            self.theIncidentAddress = number + " "
                        }
                        if let street = self.theJournalLocation.streetName {
                            self.theIncidentAddress = self.theIncidentAddress + street
                        }
                        if let c = self.theJournalLocation.city {
                            self.theIncidentAddress = self.theIncidentAddress + " " + c + ", "
                        }
                        if let s = self.theJournalLocation.state {
                            self.theIncidentAddress = self.theIncidentAddress + s + ""
                        }
                        if let z = self.theJournalLocation.zip {
                            self.theIncidentAddress = self.theIncidentAddress + z
                        }
                        if self.theJournalLocation.latitude != 0.0 {
                            self.theLatitude = String(self.theJournalLocation.latitude)
                        }
                        if self.theJournalLocation.longitude != 0.0 {
                            self.theLongitude = String(self.theJournalLocation.longitude)
                        }
                        
                        self.theJournal.locationAvailable = true
                        let index = IndexPath(row: 3, section: 0)
                        self.ics214TableView.reloadRows(at: [index], with: .automatic)
                        
                    }
                }
            default: break
            }
            
        })
    }
    
    
}

extension ICS214NewFSOVC: OnBoardAddressSearchDelegate {
    
    func addressHasBeenChosen(location: CLLocationCoordinate2D, address: String, tag: Int) {
        self.dismiss(animated: true, completion: nil )
        let theLocation = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(theLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                self.errorAlert(errorMessage: "Reverse geocoder failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            
            guard let count = placemarks?.count else {
                self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            if count != 0 {
                switch tag {
                case 3:
                    self.theJournalLocation.location = theLocation
                    self.theJournalLocation.latitude = location.latitude
                    self.theJournalLocation.longitude = location.longitude
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theJournalLocation.city = "\(pmCity)"
                        } else {
                            self.theJournalLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theJournalLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theJournalLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theJournalLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theJournalLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theJournalLocation.state = "\(pmState)"
                        } else {
                            self.theJournalLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theJournalLocation.zip = "\(pmZip)"
                        } else {
                            self.theJournalLocation.zip = ""
                        }
                        
                        if let number = self.theJournalLocation.streetNumber {
                            self.theIncidentAddress = number + " "
                        }
                        if let street = self.theJournalLocation.streetName {
                            self.theIncidentAddress = self.theIncidentAddress + street
                        }
                        if let c = self.theJournalLocation.city {
                            self.theIncidentAddress = self.theIncidentAddress + " " + c + ", "
                        }
                        if let s = self.theJournalLocation.state {
                            self.theIncidentAddress = self.theIncidentAddress + s + ""
                        }
                        if let z = self.theJournalLocation.zip {
                            self.theIncidentAddress = self.theIncidentAddress + z
                        }
                        if self.theJournalLocation.latitude != 0.0 {
                            self.theLatitude = String(self.theJournalLocation.latitude)
                        }
                        if self.theJournalLocation.longitude != 0.0 {
                            self.theLongitude = String(self.theJournalLocation.longitude)
                        }
                        
                        self.theJournal.locationAvailable = true
                        let index = IndexPath(row: 3, section: 0)
                        self.ics214TableView.reloadRows(at: [index], with: .automatic)
                    }
                default: break
                }
            }
            
        })
    }
    
}

