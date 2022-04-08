    //
    //  ListTVC+TVCExtensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/24/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit

extension ListTVC {
    
        //    MARK: -TABLEVIEW-
    
    func registerTheCells() {
        tableView.register(UINib(nibName: "LinkeJournalCell", bundle: nil), forCellReuseIdentifier: "LinkeJournalCell")
        tableView.register(UINib(nibName: "ARC_ListCell", bundle: nil), forCellReuseIdentifier: "ARC_ListCell")
    }
    
        // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = _fetchedResultsController?.sections
        {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 77
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 77
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = configureCell(at: indexPath)
        return cell
    }
    
    func configureCell( at indexPath: IndexPath)->UITableViewCell {
        switch myShift {
        case .journal:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            cell = configureJournalCell(cell, indexPath: indexPath)
            return cell
        case .incidents:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            cell = configureIncidentCell(cell, indexPath: indexPath)
            return cell
        case .maps:
            switch myShiftTwo {
            case .incidents, .fire, .ems, .rescue:
                var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
                cell = configureIncidentCell(cell, indexPath: indexPath)
                return cell
            case .ics214:
                var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
                cell = configureICS214(cell, indexPath: indexPath)
                return cell
            case .arcForm:
                var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
                cell = configureARCrossForm(cell, indexPath: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case .personal:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            cell = configurePrivateJournalCell(cell, indexPath: indexPath)
            return cell
        case .ics214:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            cell = configureICS214(cell, indexPath: indexPath)
            return cell
        case .arcForm:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            cell = configureARCrossForm(cell, indexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.contentView.backgroundColor = UIColor.gray
            cell.textLabel?.text = "Click ME here"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LinkeJournalCell {
            cell.selectedV.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id = NSManagedObjectID()
        let cell = tableView.cellForRow(at: indexPath) as! LinkeJournalCell
        cell.selectedV.isHidden = false
        switch myShift {
        case .journal:
            if let journal = _fetchedResultsController?.object(at: indexPath) as? Journal {
                id = journal.objectID
                if (Device.IS_IPHONE){
                    delegate?.journalObjectChosen(type:myShift,id:id,compact: compact)
                } else {
                    let storyboard = UIStoryboard(name: "TheJournal", bundle: nil)
                    let controller:JournalVC = storyboard.instantiateViewController(withIdentifier: "JournalVC") as! JournalVC
                    let navigator = UINavigationController.init(rootViewController: controller)
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                    controller.id = id
                    self.splitVC?.showDetailViewController(navigator, sender:self)
                }
            }
        case .incidents:
            if let incident = _fetchedResultsController?.object(at: indexPath) as? Incident {
                id = incident.objectID
                if (Device.IS_IPHONE){
                    delegate?.journalObjectChosen(type: myShift, id: id,compact: compact)
                } else {
                    let storyboard = UIStoryboard(name: "IncidentVC", bundle: nil)
                    let controller:IncidentVC = storyboard.instantiateViewController(withIdentifier: "IncidentVC") as! IncidentVC
                    let navigator = UINavigationController.init(rootViewController: controller)
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                    controller.id = id
                    self.splitVC?.showDetailViewController(navigator, sender:self)
                }
            }
        case .personal:
            if let journal = _fetchedResultsController?.object(at: indexPath) as? Journal {
                id = journal.objectID
                if (Device.IS_IPHONE){
                    delegate?.journalObjectChosen(type:myShift,id:id,compact: compact)
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller:PersonalJournalTVC = storyboard.instantiateViewController(withIdentifier: "PersonalJournalTVC") as! PersonalJournalTVC
                    let navigator = UINavigationController.init(rootViewController: controller)
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                        //        controller.context = context
                    controller.id = id
                    controller.sizeTrait = compact
                    controller.myShift = .personal
                    controller.delegate = self
                    controller.titleName = "Personal Journal"
                    self.splitVC?.showDetailViewController(navigator, sender:self)
                }
            }
        case .maps:
            switch myShiftTwo {
            case .incidents, .ems, .fire, .rescue:
                if let incident = _fetchedResultsController?.object(at: indexPath) as? Incident {
                    id = incident.objectID
                    self.nc.post(name: NSNotification.Name(rawValue: FJkINCIDENTCHOSENFORMAP), object: nil, userInfo:["objectID":id])
                }
            case .ics214:
                if let ics214 = _fetchedResultsController?.object(at: indexPath) as? ICS214Form {
                    id = ics214.objectID
                    self.nc.post(name: NSNotification.Name(rawValue: FJkICS214CHOSENFORMAP), object: nil, userInfo:["objectID":id])
                }
            case .arcForm:
                if let arcForm = _fetchedResultsController?.object(at: indexPath) as? ARCrossForm {
                    id = arcForm.objectID
                    self.nc.post(name: NSNotification.Name(rawValue: FJkARCFORMCHOSENFORMAP), object: nil, userInfo:["objectID":id])
                }
            default: break
            }
        case .ics214:
            if let ics214 = _fetchedResultsController?.object(at: indexPath) as? ICS214Form {
                id = ics214.objectID
                if (Device.IS_IPHONE){
                    delegate?.journalObjectChosen(type: myShift, id: id,compact: compact)
                } else {
                    let storyboard = UIStoryboard(name: "NewICS214", bundle: nil)
                    let controller  = storyboard.instantiateViewController(identifier: "NewICS214DetailTVC") as! NewICS214DetailTVC
                    let navigator = UINavigationController.init(rootViewController: controller)
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                        //        controller.managedObjectContext = context
                    controller.delegate = self
                    controller.objectID = id
                    self.splitVC?.showDetailViewController(navigator, sender:self)
                }
            }
        case .arcForm:
            if let arcForm = _fetchedResultsController?.object(at: indexPath) as? ARCrossForm {
                id = arcForm.objectID
                if (Device.IS_IPHONE){
                    delegate?.journalObjectChosen(type: myShift, id: id,compact: compact)
                } else {
                    let storyboard = UIStoryboard(name: "Form", bundle: nil)
                    let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
                    let navigator = UINavigationController.init(rootViewController: controller)
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                    controller.delegate = self
                    controller.objectID = id
                        //                controller.titleName = "CRR Smoke Alarm Inspection Form"
                    self.splitVC?.showDetailViewController(navigator, sender:self)
                }
            }
        default: break
        }
    }
    
        /// deleting of entries have to check if the ckRecord.recordID.recordName includes a '.' period
        /// if not an alert is shown and the deletion process is halted
        /// - Parameters:
        ///   - tableView: self.tableview
        ///   - editingStyle: .delte
        ///   - indexPath: indexPath.row to delete
        ///  calls unarchiveTheRecord after pulling the ckr data from the entities object
        ///  calls sorryCantDelete func above
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                switch myShift {
                case .journal:
                    let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
                    if let data = journal.fjJournalCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Journal")
                        } else {
                            context.delete(journal)
                            saveToCD()
                        }
                    }
                case .incidents:
                    let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
                    if let data = incident.fjIncidentCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Incident")
                        } else {
                            context.delete(incident)
                            saveToCD()
                        }
                    }
                case .personal:
                    let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
                    if let data = journal.fjJournalCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Personal Journal")
                        } else {
                            context.delete(journal)
                            saveToCD()
                        }
                    }
                case .maps:
                    let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
                    if let data = incident.fjIncidentCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Incident")
                        } else {
                            context.delete(incident)
                            saveToCD()
                        }
                    }
                case .ics214:
                    let ics214 = _fetchedResultsController?.object(at: indexPath) as! ICS214Form
                    if let data = ics214.ics214CKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "ICS 214 Form")
                        } else {
                            context.delete(ics214)
                            saveToCD()
                        }
                    }
                case .arcForm:
                    let arcForm = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
                    if let data = arcForm.arcFormCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "CRR Smoke Alarm Inspection Form")
                        } else {
                            context.delete(arcForm)
                            saveToCD()
                        }
                    }
                default: break
                }
            }
        } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func configureJournalCell(_ cell: LinkeJournalCell, indexPath: IndexPath) -> LinkeJournalCell {
        if let journal = _fetchedResultsController?.object(at: indexPath) as? Journal {
            if let imageType = journal.journalEntryTypeImageName {
                if let image = UIImage(named:imageType) {
                    cell.journalTypeIV.image = image
                }
            }
            
            cell.journalHeader.textColor = .label
            
            if let header = journal.journalHeader {
                cell.journalHeader.text = header
            }
            if let theModDate = journal.journalModDate {
                let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                let journalDate:String = fullyFormattedDate.formatFullyTheDate()
                cell.journalDateL.text = journalDate
            }
            var theAddress: String = ""
            if journal.journalLocationSC != nil {
                if let num = journal.journalStreetNumber {
                    theAddress = num
                }
                if let name = journal.journalStreetName {
                    theAddress = theAddress + " " + name
                }
                if let city = journal.journalCity {
                    theAddress = theAddress + " " + city
                }
                if let state = journal.journalState {
                    theAddress = theAddress + ", " + state
                }
                if let zip = journal.journalZip {
                    theAddress = theAddress + " " + zip
                }
            }
            if theAddress == "" {
                cell.journalLocationL.text = "No location available."
            } else {
                cell.journalLocationL.text = theAddress
            }
        }
        return cell
    }
    
    func configurePrivateJournalCell(_ cell: LinkeJournalCell, indexPath: IndexPath) -> LinkeJournalCell {
        if let journal = _fetchedResultsController?.object(at: indexPath) as? Journal {
            let imageType = "ICONS_BBLUELOCK"
            if let image = UIImage(named:imageType) {
                cell.journalTypeIV.image = image
            }
            if let color = UIColor(named: "FJDarkBlue") {
                cell.journalHeader.textColor = color
            }
            if let header = journal.journalHeader {
                cell.journalHeader.text = header
            }
            if let theModDate = journal.journalModDate {
                let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                let journalDate:String = fullyFormattedDate.formatFullyTheDate()
                cell.journalDateL.text = journalDate
            }
            cell.journalLocationL.text = ""
        }
        return cell
    }
    
    func configureIncidentCell(_ cell: LinkeJournalCell, indexPath: IndexPath) -> LinkeJournalCell {
        if let incident = _fetchedResultsController?.object(at: indexPath) as? Incident {
            if let imageType = incident.incidentEntryTypeImageName {
                if let image = UIImage(named:  imageType) {
                    cell.journalTypeIV.image = image
                }
            } else {
                let imageType = "100515IconSet_092016_fireboard"
                if let image = UIImage(named:  imageType) {
                    cell.journalTypeIV.image = image
                }
            }
            if let color = UIColor(named: "FJIconRed") {
                cell.journalHeader.textColor = color
            }
            if let number = incident.incidentNumber {
                cell.journalHeader.text = "Incident #" + number
            } else {
                cell.journalHeader.text = "No incident number was indicated."
            }
            if let theModDate = incident.incidentModDate {
                let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                let modDate = fullyFormattedDate.formatFullyTheDate()
                cell.journalDateL.text = modDate
            }
            var theAddress: String = ""
            
                if incident.theLocation != nil {
                    if  let location = incident.theLocation {
                        if let number = location.streetNumber {
                            theAddress = number
                        }
                        if let name = location.streetName {
                            theAddress = theAddress + " " + name
                        }
                        if let zip = location.zip {
                            theAddress = theAddress + " " + zip
                        }
                    }
                    if theAddress == "" {
                        cell.journalLocationL.text = "No location available"
                    } else {
                        cell.journalLocationL.text = theAddress
                    }
                } else if incident.incidentAddressDetails != nil {
                    if let location = incident.incidentAddressDetails {
                        if let number = location.streetNumber {
                            theAddress = number
                        }
                        if let name = location.streetHighway {
                            theAddress = theAddress + " " + name
                        }
                        if let zip = location.zip {
                            theAddress = theAddress + " " + zip
                        }
                    }
                    if theAddress == "" {
                        cell.journalLocationL.text = "No location available"
                    } else {
                        cell.journalLocationL.text = theAddress
                    }
                }
            
            if cell.journalLocationL.text == "" {
                cell.journalLocationL.text = "No location available"
            }
        }
        return cell
    }
    
    func configureICS214(_ cell: LinkeJournalCell, indexPath: IndexPath) -> LinkeJournalCell {
        if let ics214 = _fetchedResultsController?.object(at: indexPath) as? ICS214Form {
            let imageType:String = "100515IconSet_092016_ICS 214 Form"
            if let image = UIImage(named: imageType) {
                cell.journalTypeIV.image = image
            }
            cell.journalHeader.textColor = UIColor.systemBlue
            if let name = ics214.ics214IncidentName {
                if ics214.ics214Count > 0 {
                    cell.journalHeader.text = "\(name)"
                } else {
                    cell.journalHeader.text = "\(name)"
                }
            }
            if let campaign = ics214.ics214Effort {
                cell.journalDateL.text = "Effort: \(campaign)"
            }
            var toDate:String = ""
            var fromDate:String = ""
            if let modDate = ics214.ics214FromTime {
                let fullyFormattedDate = FullDateFormat.init(date: modDate)
                fromDate = fullyFormattedDate.formatFullyTheDate()
            }
            if let endDate = ics214.ics214CompletionDate {
                let fullyFormattedDate = FullDateFormat.init(date: endDate)
                toDate = fullyFormattedDate.formatFullyTheDate()
            } else {
                toDate = "Incomplete"
            }
            if toDate == "Incomplete" {
                cell.journalLocationL.text = "From: " + fromDate + "\n" + toDate
            } else {
                cell.journalLocationL.text = "From: " + fromDate + "\nTo: " + toDate
            }
        }
        return cell
    }
    
    
    func configureARCrossForm(_ cell: LinkeJournalCell, indexPath: IndexPath) -> LinkeJournalCell {
        
        if  let arcForm = _fetchedResultsController?.object(at: indexPath) as? ARCrossForm {
            let imageType:String = "100515IconSet_092016_redCross"
            if let image = UIImage(named: imageType) {
                cell.journalTypeIV.image = image
            }
            cell.journalHeader.textColor = UIColor.systemBlue
            let count = arcForm.campaignCount
            var theCount = 0
            if count > 1 {
                theCount = Int(count)
            }
            if theCount > 1 {
                if let theName = arcForm.campaignName {
                    cell.journalHeader.text = theName + " " + String(theCount)
                }
            } else {
                if let theName = arcForm.campaignName {
                    cell.journalHeader.text = theName
                }
            }
            var address:String = ""
            if let street = arcForm.arcLocationAddress {
                address = street
            }
            if let m = arcForm.arcLocationAptMobile {
                address = address + " " + m
            }
            if let c = arcForm.arcLocationCity {
                address = address + " " + c
            }
            if let z = arcForm.arcLocationZip {
                address = address + " " + z
            }
            if address == "" {
                cell.journalDateL.text = "Address not available."
            } else {
                cell.journalDateL.text = address
            }
            if arcForm.cComplete {
                cell.journalLocationL.text = "Campaign Incomplete"
            } else {
                cell.journalLocationL.text = "Campaign Complete"
            }
        }
        return cell
    }
    
        /// unarchive the data that is the ckRecord archive saved with the object when sent to cloud
        ///
        /// - Parameter data: ckr data
        /// - Returns: returns from the ckrData the CKRecord.recordID.recordName
    func unarchiveTheRecord(data:Data) -> String {
        var ckRecord: CKRecord!
        var ckRecordName: String = ""
        do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data)
            ckRecord = CKRecord(coder: unarchiver)
            if ckRecord.recordID.recordName != "" {
                ckRecordName = ckRecord.recordID.recordName
            } else {
                ckRecordName = ""
            }
        } catch {
            print("Couldn't read file.")
        }
        return ckRecordName
    }
    
    
        /// alert used to inform user that the object they want to delete can't be deleted
        ///
        /// - Parameter type: entity name
    func sorryCantDelete(type: String) {
        if !alertUp {
            let title: InfoBodyText = .deletionIncompleteSubject
            let message1: InfoBodyText = .deletionIncomplete
            let message2: InfoBodyText = .deletionIncomplete2
            let message = "\(message1.rawValue) \(type) \(message2.rawValue)"
            let alert = UIAlertController.init(title: title.rawValue, message: message , preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
        //            MARK: - Load the first row into the detail page
        //            let indexPath = IndexPath(row: 0, section: 0)
        //            tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
    
        //            MARK: -Use the CloudKitReference saved as Data to send to
        //            : cloudkit the correct record to delete
        //            : sent to cloudKitmanager that loads deleteFromListOperation
        //            MARK: Make sure that coredata merges the changes
    func saveToCD() {
        do {
            try context.save()
            if let data = ckrData {
                DispatchQueue.main.async {
                    
                    self.nc.post(name:NSNotification.Name(rawValue:FJkDELETEFROMLIST),
                                 object: nil,
                                 userInfo: ["ckrObject":data])
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"List merge that"])
            }
            
            
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "List SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
            print(errorMessage)
            
        }
    }
}
