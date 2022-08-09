//
//  NewICS214DetailTVC+Extension.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit

extension NewICS214DetailTVC {
    
    //    MARK: -CONFIGURE CELLS-
    func configureNewICS214ActivityLogCompleteCell(_ cell: NewICS214ActivityLogCompleteCell, at indexPath: IndexPath, tag: Int, position: Int) -> NewICS214ActivityLogCompleteCell {
        cell.aLog = activityLogs[position]
        cell.position = position
        cell.path = indexPath
        cell.tag = tag
        cell.delegate = self
        return cell
    }
    
    func configureNewICS214ResourceCompleteCell(_ cell: NewICS214ResourceCompleteCell, at indexPath: IndexPath, tag: Int, position: Int) -> NewICS214ResourceCompleteCell {
        cell.crew = resources[position]
        cell.position = position
        cell.tag = tag
        return cell
    }
    
    func configureSignatureCell(_ cell: NewICS214SignatureCell, at indexPath: IndexPath, tag: Int) -> NewICS214SignatureCell {
        cell.delegate = self
        if signatureBool {
            if signatureImage != nil {
                cell.sImage = signatureImage
            }
        }
        return cell
    }
    
    func configureNewICS214ActivityLogCell(_ cell: NewICS214ActivityLogCell, at indexPath: IndexPath, tag: Int ) -> NewICS214ActivityLogCell {
        cell.delegate = self
        cell.path = indexPath
        if activityLogClear {
            newActivityLogDateTime = nil
            cell.dateTime = ""
            cell.notableTV.text = ""
        }
        if newActivityLogDateTime != nil {
            var theDate = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            theDate = dateFormatter.string(from: newActivityLogDateTime )
            cell.dateTime = theDate
            cell.addB.isHidden = false
            cell.addB.isEnabled = true
            cell.addB.alpha = 1.0
        } else {
            cell.addB.isHidden = true
            cell.addB.isEnabled = false
            cell.addB.alpha = 0.0
        }
        //        if cell.notableTV.text == "" {
        //        } else {
        //            cell.addB.isHidden = false
        //            cell.addB.isEnabled = true
        //            cell.addB.alpha = 1.0
        //        }
        return cell
    }
    
    func configureDateTimeCell(_ cell: NewICS214DateTimeCell, at indexPath: IndexPath, tag: Int)->NewICS214DateTimeCell {
        cell.delegate = self
        if tag == 3 {
            cell.tag = 3
            cell.dName = "Date From:"
            cell.tName = "Time From:"
            if ics214.ics214FromTime != nil {
                var theDate = ""
                var theTime = ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                theDate = dateFormatter.string(from: ics214.ics214FromTime ?? Date())
                dateFormatter.dateFormat = "HH:mm"
                theTime = dateFormatter.string(from: ics214.ics214FromTime ?? Date())
                cell.dateT = theDate
                cell.timeT = theTime
            }
        } else if tag == 5 {
            cell.tag = 5
            cell.dName = "Date To:"
            cell.tName = "Time To:"
            if ics214.ics214ToTime != nil {
                var theDate = ""
                var theTime = ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                theDate = dateFormatter.string(from: ics214.ics214ToTime ?? Date())
                dateFormatter.dateFormat = "HH:mm"
                theTime = dateFormatter.string(from: ics214.ics214ToTime ?? Date())
                cell.dateT = theDate
                cell.timeT = theTime
            } else {
                cell.dateT = ""
                cell.timeT = ""
            }
        } else if tag == 18 {
            cell.tag = 18
            cell.dName = "Date:"
            cell.tName = "Time:"
            if ics214.ics214SignatureDate != nil {
                var theDate = ""
                var theTime = ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                theDate = dateFormatter.string(from: ics214.ics214SignatureDate ?? Date())
                dateFormatter.dateFormat = "HH:mm"
                theTime = dateFormatter.string(from: ics214.ics214SignatureDate ?? Date())
                cell.dateT = theDate
                cell.timeT = theTime
            }
        }
        return cell
    }
    
    func configureLabelCell(_ cell: LabelCell, at indexPath: IndexPath, tag: Int)->LabelCell {
        cell.tag = tag
        cell.modalTitleL.font = cell.modalTitleL.font.withSize(24)
        switch tag{
        case 2:
            cell.modalTitleL.text = "2. Operational Period:"
        case 10:
            cell.modalTitleL.text = "6. Resources Assigned:"
        case 12:
            cell.modalTitleL.text = "7. Activity Log:"
        case 15:
            cell.modalTitleL.text = "8. Prepared By:"
        default: break
        }
        return cell
    }
    
    func configureNewICS214LabelTextFieldCell(_ cell: NewICS214LabelTextFieldCell, at indexPath: IndexPath, tag: Int)->NewICS214LabelTextFieldCell {
        cell.delegate = self
        cell.tag = tag
        switch tag {
        case 1:
            cell.label = "1. Incident Name:"
            if let name = ics214.ics214IncidentName {
                cell.described = name
            }
            cell.path = indexPath
        case 7:
            cell.label = "3. Name:"
            if let name = ics214.ics214UserName {
                cell.described = name
            }
            cell.path = indexPath
        case 8:
            cell.label = "4. ICS Position:"
            if let position = ics214.ics214ICSPosition {
                cell.described = position
            }
            cell.path = indexPath
        case 9:
            cell.label = "5. Home Agency:"
            if let agency = ics214.ics241HomeAgency {
                cell.described = agency
            }
            cell.path = indexPath
        case 16:
            cell.label = "Name:"
            if let preparedBy = ics214.icsPreparfedName {
                cell.described = preparedBy
            }
            cell.path = indexPath
        case 17:
            cell.label = "Position/Type:"
            if let position = ics214.icsPreparedPosition {
                cell.described = position
            }
            cell.path = indexPath
        default:
            break
        }
        return cell
    }
    
    func configureHeadCell(_ cell: NewICS214HeadCell, at indexPath: IndexPath)->NewICS214HeadCell {
        if ics214.ics214EffortMaster {
            if let name = ics214.ics214IncidentName {
                cell.formNameL.text = name
            }
        } else {
            let counted:Int = Int(exactly:ics214.ics214Count)!
            let name = ics214.ics214IncidentName ?? ""
            if counted > 0 {
                cell.formNameL.text = "\(name) - \(counted)"
            } else {
                cell.formNameL.text = "\(name)"
            }
        }
        if let effort = ics214.ics214Effort {
            if effort == "incidentForm" {
                var effortTitle = "Local Incident"
                if let number = ics214.ics214LocalIncidentNumber {
                    effortTitle = effortTitle + " - #\(number)"
                }
                cell.campaignTypeL.text = effortTitle
                let image = UIImage(named: "ICS_214_Form_LOCAL_INCIDENT")
                cell.icsIconIV.image = image
            } else if effort == "femaTaskForceForm" {
                let effortTitle = "FEMA Task Force"
                cell.campaignTypeL.text = effortTitle
                let image = UIImage(named: "ICS214FormFEMA")
                cell.icsIconIV.image = image
            } else if effort == "strikeForceForm" {
                let effortTitle = "Strike Team"
                cell.campaignTypeL.text = effortTitle
                let image = UIImage(named: "ICS214FormSTRIKETEAM")
                cell.icsIconIV.image = image
            } else if effort == "otherForm" {
                let effortTitle = "Other"
                cell.campaignTypeL.text = effortTitle
                let image = UIImage(named: "ICS214FormOTHER")
                cell.icsIconIV.image = image
            } else {
                let image = UIImage(named: "ICS_214_Form_LOCAL_INCIDENT")
                cell.icsIconIV.image = image
            }
        }
        dateFormatter.dateFormat = "MM/dd/YYYY"
        cell.campaign = ics214.ics214Completed
        
        if let toDate = ics214.ics214FromTime {
            let campaignDate:String = dateFormatter.string(from: toDate)
            cell.dateL.text = campaignDate
            cell.campaignTF.text = "Campaign open"
            cell.campaignSwitch.isOn = true
        }
        
        if !ics214.ics214Completed {
            if let completionDate = ics214.ics214CompletionDate {
                let cDate:String = dateFormatter.string(from: completionDate)
                cell.dateL.text = "This campaign was completed: \(cDate)"
                cell.campaignTF.text = "Campaign closed: \(cDate)"
                cell.campaignSwitch.isOn = false
            }
        }
        cell.delegate = self
        return cell
    }
    
    //    MARK: -GET THE DATA-
    func buildTheCells() {
        ics214ToCloud = ICS214ToCloud.init(context)
        newTheCells = cellsForForm.cells
        if let form = context.object(with: objectID!) as? ICS214Form {
            self.ics214 = form
            objectID = ics214.objectID
            if let guid = ics214.ics214Guid {
                ics214Guid = guid
            }
            if let mGuid = ics214.ics214MasterGuid {
                masterGuid = mGuid
                theCampaign = getTheICS214Campaign(masterGuid: masterGuid)
            }
            if ics214.ics214SignatureAdded {
                signatureBool = true
                if(ics214.ics214Signature != nil) {
                    let imageUIImage: UIImage = UIImage(data: ics214.ics214Signature!)!
                    signatureImage = imageUIImage
                    signatureDate = ics214.ics214SignatureDate
                }
            } else {
                signatureBool = false
            }
            resources = getTheAttendeesAsCrew()
            if !resources.isEmpty {
                var count = 0
                for r in resources {
                    print(r)
                    let cell = NewICS214CellResourceAssigned()
                    cell.arrayPosition = count
                    count += 1
                    let e:Int = newTheCells.firstIndex(where: { $0.tag == 11 })!
                    let t:Int = e+1
                    newTheCells.insert(cell, at: t)
                }
            }
            activityLogs = getTheSet()
            if !activityLogs.isEmpty {
                var count = 0
                for a in activityLogs {
                    print(a)
                    let cell = NewICS214CellCompletedLog()
                    cell.arrayPosition = count
                    count += 1
                    let e:Int = newTheCells.firstIndex(where: { $0.tag == 14})!
                    let t:Int = e+1
                    newTheCells.insert(cell, at: t)
                }
            }
        }
    }
    
    func getTheSet() -> [ICS214ActivityLog] {
        let logs = ics214.ics214ActivityDetail as! Set<ICS214ActivityLog>
        var logArray = [ICS214ActivityLog]()
        for log in logs {
            logArray.append(log)
        }
        return logArray
    }
    
    func getThePersonnel() -> [String] {
        let personnel = ics214.ics214PersonneDetail as! Set<ICS214Personnel>
        var attendeeGuidArray = [String]()
        for crew in personnel {
            if let guid = crew.userAttendeeGuid {
                attendeeGuidArray.append(guid)
            }
        }
        return attendeeGuidArray
    }
    
    func getThePersonnelArray() -> [ICS214Personnel] {
        let personnel = ics214.ics214PersonneDetail as! Set<ICS214Personnel>
        let icsCrew = Array(personnel)
        return icsCrew
    }
    
    func getTheAttendeesAsCrew() -> [UserAttendees] {
        var theCrew = [UserAttendees]()
        let crewGuids = getThePersonnel()
        if !crewGuids.isEmpty {
            for theGuid in crewGuids {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K = %@","attendeeGuid", theGuid)
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                fetchRequest.fetchBatchSize = 1
                let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                do {
                    let attendees = try context.fetch(fetchRequest) as! [UserAttendees]
                    if attendees.isEmpty {} else {
                        let crew = attendees.last!
                        theCrew.append(crew)
                    }
                }  catch {
                    let nserror = error as NSError
                    let errorMessage = "NewICS214Resources getTheAttendees line 81 Unresolved error \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
            }
        }
        return theCrew
    }
    
    //    MARK: -CREATE NEW CREW OR LOGS-
    func createICS214Personnel(guid2: String, completion: () -> () ) {
        let theCrew = getThePersonnelArray()
        
        let result = theCrew.filter { $0.userAttendeeGuid == guid2 }
        if result.isEmpty {
            let fjuICS214Personnel = ICS214Personnel.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Personnel", in: context)!, insertInto: context)
            fjuICS214Personnel.ics214Guid = self.ics214Guid
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let resourceDate = Date()
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "80."+uuidA
            fjuICS214Personnel.ics214PersonelGuid = uuidA1
            fjuICS214Personnel.userAttendeeGuid = guid2
            ics214.addToIcs214PersonneDetail(fjuICS214Personnel)
            saveThePersonnelCrew(guid: uuidA1)
        }
        completion()
    }
    
    
    
    
    func createTheNewActivityLog(logString: String, date:Date, completion: () -> ()) {
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: date)
        uuidA = uuidA+dateFrom
        let logGuid = "81."+uuidA
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let dateString = dateFormatter.string(from:date)
        let icsS214ActivityLog = ICS214ActivityLog.init(entity: NSEntityDescription.entity(forEntityName: "ICS214ActivityLog", in: context)!, insertInto: context)
        icsS214ActivityLog.ics214ActivityGuid = logGuid
        icsS214ActivityLog.ics214Guid = self.ics214Guid
        icsS214ActivityLog.ics214AcivityModDate = date
        icsS214ActivityLog.ics214ActivityCreationDate = date
        icsS214ActivityLog.ics214ActivityBackedUp = false
        icsS214ActivityLog.ics214ActivityDate = date
        icsS214ActivityLog.ics214ActivityLog = logString
        icsS214ActivityLog.ics214ActivityStringDate = dateString
        ics214.addToIcs214ActivityDetail(icsS214ActivityLog)
        ics214.ics214ModDate = Date()
        ics214.ics214BackedUp = false
        saveTheActivityLog(guid: logGuid )
        completion()
    }
    
    //    MARK: -SAVE METHODS-
    @objc func saveICS214(_ sender:Any) {
        ics214.ics214ModDate = Date()
        ics214.ics214BackedUp = false
        saveToCD()
    }
    
    func saveRemoval() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
        } catch let error as NSError {
            print("NewICS214DetailTVC line 356 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveTheAttendee(objectID: NSManagedObjectID) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        } catch let error as NSError {
            print("NewICS214DetailTVC line 356 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveThePersonnelCrew(guid: String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID":self.ics214.objectID])
                
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214Personnel(guid: guid)
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214PERSONNEL_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
            print("NewICS214DetailTVC personnel saved yeah!")
        } catch let error as NSError {
            print("NewICS214DetailTVC line 356 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveTheActivityLog(guid: String ){
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID":self.ics214.objectID])
                
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214ActivtyLog(guid: guid)
                print("Going to Activity Log Cloud")
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
            print("NewICS214DetailTVC Activity saved yeah!")
        } catch let error as NSError {
            print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveTheModifiedActivityLog(guid: String ){
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID":self.ics214.objectID])
                
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214ActivtyLog(guid: guid)
                print("Going to Activity Log Cloud")
                self.nc.post(name: Notification.Name(rawValue: FJkMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
            print("NewICS214DetailTVC Activity saved yeah!")
        } catch let error as NSError {
            print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveTheCampaignChange() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID":self.ics214.objectID])
            }
        } catch let error as NSError {
            print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID":self.ics214.objectID])
                
            }
            if fromMap {
                if (Device.IS_IPHONE) {
                    if theFireJournalUser != nil {
                        let id = theFireJournalUser.objectID
                        if theUserTime != nil {
                            let userTimeID = theUserTime.objectID
                        vcLaunch.mapCalledPhone(type: IncidentTypes.ics214Form, theUserOID: id, theUserTimeOID: userTimeID)
                        }
                    }
                } else {
                    if theFireJournalUser != nil {
                            let id = theFireJournalUser.objectID
                        if theUserTime != nil {
                            let userTimeID = theUserTime.objectID
                            vcLaunch.mapCalled(type: IncidentTypes.ics214Form, theUserOID: id, theUserTimeOID: userTimeID)
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -GET THE CAMPAIGN-
    func getTheICS214Campaign(masterGuid: String) ->[ICS214Form] {
        var campaign = [ICS214Form]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate2 = NSPredicate(format: "%K == %@", "ics214MasterGuid", masterGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate2])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        do {
            campaign = try context.fetch(fetchRequest) as! [ICS214Form]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return campaign
    }
    
    //    MARK: -GET THE LAST CREATED-
    private func getTheLastSavedICS214Personnel(guid: String)->NSManagedObjectID {
        var objectID: NSManagedObjectID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
        let predicate = NSPredicate(format: "%K = nil", "ics214PersonnelCKR")
        let predicate2 = NSPredicate(format: "%K == %@", "ics214PersonelGuid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Personnel]
            let ics214Personnel = fetched.last
            objectID = ics214Personnel?.objectID
            return objectID
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return objectID
    }
    
    private func getTheLastSavedICS214ActivtyLog(guid: String)->NSManagedObjectID {
        var objectID: NSManagedObjectID!
        let fetchRequest: NSFetchRequest<ICS214ActivityLog> = ICS214ActivityLog.fetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214ActivityCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetched = try context.fetch(fetchRequest)
            let ics214ActivityLog = fetched.last
            objectID = ics214ActivityLog?.objectID
            return objectID
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return objectID
    }
    
}

extension NewICS214DetailTVC: MapFormHeaderVDelegate {
    
    func mapFormHeaderBackBTapped(type: IncidentTypes) {
            if (Device.IS_IPHONE) {
                if theFireJournalUser != nil {
                    let id = theFireJournalUser.objectID
                    if theUserTime != nil {
                        let userTimeID = theUserTime.objectID
                    vcLaunch.mapCalledPhone(type: type, theUserOID: id, theUserTimeOID: userTimeID)
                    }
                }
            } else {
                if theFireJournalUser != nil {
                        let id = theFireJournalUser.objectID
                    if theUserTime != nil {
                        let userTimeID = theUserTime.objectID
                        vcLaunch.mapCalled(type: type, theUserOID: id, theUserTimeOID: userTimeID)
                    }
                }
            }
    }
    
    func mapFormHeaderSaveBTapped() {
        saveICS214(self)
    }
    
    
}

extension NewICS214DetailTVC: NewICS214DatePickerCellDelegate {
    
    //    MARK: -DATE PICKER DELEGATE-
    func theDatePickerChangedDate(_ date: Date, at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewICS214DatePickerCell
        let tag = cell.tag
        var path = IndexPath(row: 0, section: 0)
        switch tag {
        case 4:
            showPicker.toggle()
            ics214.ics214FromTime = date
            path = IndexPath(row: 3, section: 0)
        case 6:
            showPickerTwo.toggle()
            ics214.ics214ToTime = date
            path = IndexPath(row: 5, section: 0)
        case 14:
            showPickerThree.toggle()
            if !showPickerThree {
                activityLogClear = false
            } else {
                activityLogClear = true
            }
            newActivityLogDateTime = date
            var i = indexPath.row
            i -= 1
            path = IndexPath(row: i, section: 0)
        case 19:
            showPickerFour.toggle()
            ics214.ics214SignatureDate = date
            var i = indexPath.row
            i -= 1
            path = IndexPath(row: i, section: 0)
        default:break
        }
        tableView.reloadRows(at: [path,indexPath], with: .automatic)
    }
    
    
}

extension NewICS214DetailTVC: NewICS214LabelTextFieldCellDelegate {
    
    //    MARK: -LABEL TEXT FIELD CELL DELEGATE-
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int) {
//        _ = tableView.cellForRow(at: indexPath) as! NewICS214LabelTextFieldCell
        switch tag {
        case 1:
            ics214.ics214IncidentName = text
        case 7:
            ics214.ics214UserName = text
        case 8:
            ics214.ics214ICSPosition = text
        case 9:
            ics214.ics241HomeAgency = text
        case 16:
            ics214.icsPreparfedName = text
        case 17:
            ics214.icsPreparedPosition = text
        default: break
        }
    }
    
}

extension NewICS214DetailTVC: NewICS214ResourcesAssignedCellDelegate {
    
    //    MARK: -NEW RESOURCES ASSIGNED-
    func addBTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "NewICS214ResourcesAssigned", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "NewICS214ResourcesAssignedTVC") as! NewICS214ResourcesAssignedTVC
        modalTVC.selected = resources
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.modalPresentationStyle = .custom
        self.present(modalTVC, animated: true, completion: nil)
    }
    
}

extension NewICS214DetailTVC: NewICS214ResourcesAssignedTVCDelegate {
    
    //    MARK: -RESOURCES ASSIGNED RETURN DELEGATE-
    func newICS214ResourcesAssignedCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func newICS214ResourcesAssignedGroupToSave(crew: [UserAttendees]) {
        //        let personnel = resource.getTheResources()
        var personnel = getThePersonnelArray()
        var newCrew = [UserAttendees]()
        let crewCount: Int = crew.count
        let personnelCount: Int = personnel.count
        if personnelCount > crewCount {
            for person in personnel {
                context.delete(person)
            }
            saveRemoval()
            personnel.removeAll()
        }
        for member in crew {
            if member.attendeeGuid == "" || member.attendeeGuid == nil {
                let groupDate = GuidFormatter.init(date:Date())
                let grGuid:String = groupDate.formatGuid()
                member.attendeeGuid = "79."+grGuid
            }
            if !personnel.isEmpty {
                let result = personnel.filter { $0.userAttendeeGuid == member.attendeeGuid }
                print(result)
                if result.isEmpty {
                    newCrew.append(member)
                }
            } else {
                newCrew.append(member)
            }
        }
        for member in newCrew {
            if let guid = member.attendeeGuid {
                createICS214Personnel(guid2: guid) {
                    print("new personnel created")
                }
            }
        }
        clearOutResources()
        resources.removeAll()
        resources = getTheAttendeesAsCrew()
        if !resources.isEmpty {
            var count = 0
            for _ in resources {
                let cell = NewICS214CellResourceAssigned()
                cell.arrayPosition = count
                count += 1
                let e:Int = newTheCells.firstIndex(where: { $0.tag == 11 } )!
                let t:Int = e+1
                newTheCells.insert(cell, at: t)
            }
        }
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func clearOutResources() {
        for cell in newTheCells {
            if cell.tag == 21 {
                if let row = self.newTheCells.firstIndex(where: { $0.tag == 21 } ) {
                    newTheCells.remove(at: row)
                }
            }
        }
    }
    
}

extension NewICS214DetailTVC: NewICS214SignatureCellDelegate, T1AutographDelegate {
    
    //    MARK: -SIGNATURE DELEGATE-
    func theSignatureBTapped() {
        autograph = T1Autograph.autograph(withDelegate: self, modalDisplay: "ICS 214 Activity Log Signature") as! T1Autograph
        
        // Enter license code here to remove the watermark
        autograph.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"
        
        // any optional configuration done here
        autograph.showDate = false
        autograph.strokeColor = UIColor.darkGray
    }
    
    func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
        ics214.ics214SignatureDate = Date()
        signatureImage = UIImage(data:signature.imageData,scale:1.0)
        signatureBool = true
        if let imageD = signatureImage!.pngData() as NSData? {
            ics214.ics214Signature = imageD as Data
        }
        ics214.ics214SignatureAdded = true
        saveICS214(self)
        let path1 = IndexPath(row: signatureDateTag, section: 0)
        let path = IndexPath(row: signatureImageTag, section: 0)
        tableView.reloadRows(at: [path1,path], with: .automatic)
    }
    
    func autographDidCancelModalView(_ autograph: T1Autograph!) {
        signatureBool = false
        signatureImage = nil
        let path = IndexPath(row: 20, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
    func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
        signatureBool = false
        signatureImage = nil
        let path = IndexPath(row: 20, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
    func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
        // Note: You can use the 'count' parameter to determine if the line is substantial enough to enable the done or clear button.
    }
    
    func autograph(_ autograph: T1Autograph!, willCompleteWith signature: T1Signature!) {
        NSLog("Autograph will complete with signature")
    }
    
}

extension NewICS214DetailTVC: NewICS214HeadCellDelegate {
    
    //    MARK: -HEADER DELEGATE-
    func ics214ShareThisFormTapped() {
        let theForm = ics214ToCloud.buildToShare(objectID!)
        print(theForm)
        if !self.alertUp {
            self.presentAlert(info: "Share")
        }
        ics214ToCloud.sendAndRecieve(dataCompletionHander:  { link, error in
            
            if link == link {
                self.pdfLink = link
            }
        }
        )
    }
    
    @objc func deliverTheShare(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            self.pdfLink = userInfo["pdfLink"] as? String ?? ""
//            let items = [URL(string: self.pdfLink)!]
            let items = [ self.pdfLink ]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let pc = ac.popoverPresentationController {
                pc.barButtonItem = saveButton
            }
             self.present(ac, animated: true, completion: nil)
        }
    }
    
    func ics214InfoTapped() {
        if !alertUp {
            presentAlert(info: "Info")
        }
    }
    
    func presentAlert(info: String ) {
        var message: InfoBodyText!
        var title: InfoBodyText!
        var type: Bool = false
        if info == "Info" {
            message = .ics214SupportNotes
            title = .ics214SupportSubject
        } else {
            message = .ics214ShareSupportNotes
            title = .ics214ShareSupportSubject
            type = true
        }
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        if !type {
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
        }
        alertUp = true
        self.present(alert, animated: true, completion: nil)
        if type {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: nil)
                self.alertUp = false
            })
        }
    }
    
    func ics214CampaignSwitchTapped(campaign: Bool) {
        ics214.ics214Completed = campaign
        ics214.ics214Completed.toggle()
        ics214.ics214BackedUp = false
        ics214.ics214CompletionDate = Date()
        ics214.ics214ModDate =  ics214.ics214CompletionDate
        saveToCD()
        for form in theCampaign {
            form.ics214BackedUp = false
            form.ics214Completed = ics214.ics214Completed
            form.ics214CompletionDate = Date()
            form.ics214ModDate = form.ics214CompletionDate
            saveTheCampaignChange()
        }
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                         object: nil, userInfo: ["shift":MenuItems.ics214])
        }
        let path = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
}

extension NewICS214DetailTVC: NewICS214DateTimeCellDelegate {
    
    //    MARK: -DATE TIME CELL DELEGATE-
    func theTimeBTapped(tag: Int) {
        if tag == 3 {
            showPicker.toggle()
            let path = IndexPath(row: 4, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        } else if tag == 5 {
            showPickerTwo.toggle()
            let path = IndexPath(row: 6, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        } else if tag == 18 {
            showPickerFour.toggle()
            let path = IndexPath(row: 19, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        }
    }
}

extension NewICS214DetailTVC: NewICS214ActivityLogCellDelegate {
    
    //    MARK: -NEW ACTIVITY LOG DELEGATE-
    func timeButtonTapped(path: IndexPath) {
        let cell = tableView.cellForRow(at: path) as! NewICS214ActivityLogCell
        showPickerThree.toggle()
        UIView.animate(withDuration: 0.5, animations: {
            cell.addB.isHidden = false
            cell.addB.isEnabled = true
            cell.addB.alpha = 1.0
        })
        let path = IndexPath(row: 14, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
    func addButtonTapped(path: IndexPath) {
        let cell = tableView.cellForRow(at: path) as! NewICS214ActivityLogCell
        _ = cell.textViewShouldEndEditing(cell.notableTV)
        if newActivityLogDateTime == nil {
            newActivityLogDateTime = Date()
        }
        createTheNewActivityLog(logString: newActivityLogText, date: newActivityLogDateTime) {
            () -> () in
            clearOutActivityLogs()
            activityLogs.removeAll()
            activityLogs = getTheSet()
            if !activityLogs.isEmpty {
                var count = 0
                for _ in activityLogs {
                    let cell = NewICS214CellCompletedLog()
                    cell.arrayPosition = count
                    count += 1
                    let e:Int = newTheCells.firstIndex(where: { $0.tag == 14 })!
                    let t:Int = e+1
                    newTheCells.insert( cell, at: t )
                }
            }
            activityLogClear = true
            activityLogViewHeight = 145
            tableView.reloadData()
        }
    }
    
    func textForActivityLogIsDone(text: String, path: IndexPath) {
        newActivityLogText = text
    }
    
    func textHasBeenAddedToActivityLog(text: String, path: IndexPath ){
        let cell = tableView.cellForRow(at: path) as! NewICS214ActivityLogCell
        newActivityLogText = text
        if cell.addB.isHidden == true {
            UIView.animate(withDuration: 0.5, animations: {
                cell.addB.isHidden = false
                cell.addB.isEnabled = true
                cell.addB.alpha = 1.0
            })
        }
        tableView.scrollToRow(at: path, at: .middle, animated: false)
    }
    
    func clearOutActivityLogs() {
        for cell in newTheCells {
            if cell.tag == 22 {
                if let row = self.newTheCells.firstIndex(where: { $0.tag == 22 } ) {
                    newTheCells.remove(at: row)
                }
            }
        }
    }
    
    func getOverViewSize()->CGFloat {
        if newActivityLogText != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: activityLogViewHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = newActivityLogText
            let estimatedSize = textView.sizeThatFits(size)
            
            activityLogViewHeight = estimatedSize.height + 145
        }
        return activityLogViewHeight
    }
    
}

extension NewICS214DetailTVC: AdjustDateForLogDelegate {
    func theAdjustDateCancelBTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theAdjustDateSaveBTapped(activityLog: ICS214ActivityLog, position: Int, path: IndexPath, activityDate: Date, activityDateString: String) {
        if let row = self.activityLogs.firstIndex(where: { $0.objectID == activityLog.objectID } ) {
            
            activityLog.ics214AcivityModDate = Date()
            activityLog.ics214ActivityBackedUp = false
            
            if let guid = activityLog.ics214ActivityGuid {
                saveTheModifiedActivityLog(guid: guid)
            }
            
            activityLogs[row] = activityLog
            
            tableView.reloadData()
            tableView.scrollToRow(at: path, at: .middle, animated: false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension NewICS214DetailTVC: NewICS214ActivityLogCompleteCellDelegate {
    
    //    MARK: -ACTIVITY LOG DELEGATE-
    func activityLogDateBTapped(activityLog: ICS214ActivityLog, position: Int, path: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AdjustDateForLog", bundle:nil)
        let adjustVC = storyBoard.instantiateViewController(withIdentifier: "AdjustDateForLog") as! AdjustDateForLog
        adjustVC.aLog = activityLog
        adjustVC.position = position
        adjustVC.path = path
        adjustVC.delegate = self
        self.present(adjustVC, animated: true, completion: nil)
        
    }
    
    func activityLogHasChanged(activityLog: ICS214ActivityLog, position: Int, path: IndexPath) {
        if let row = self.activityLogs.firstIndex(where: { $0.objectID == activityLog.objectID } ) {
            activityLogs[row] = activityLog
            let cell = tableView.cellForRow(at: path) as! NewICS214ActivityLogCompleteCell
            let size = CGSize(width: cell.logTV.frame.width, height: .infinity)
            let estimatedSize = cell.logTV.sizeThatFits(size)
            
            saveActivityLogViewHeight = estimatedSize.height + 145
            tableView.beginUpdates()
            cell.logTV.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    if Device.IS_IPAD {
                        constraint.constant = estimatedSize.height
                    } else {
                        if estimatedSize.height < 400 {
                            constraint.constant = estimatedSize.height
                        } else {
                            constraint.constant = 400
                        }
                    }
                }
                
            }
            tableView.endUpdates()
            tableView.scrollToRow(at: path, at: .middle, animated: false)
        }
    }
    
    func activityLogCompleteAddBTapped(activityLog:  ICS214ActivityLog, position: Int) {
        if let row = self.activityLogs.firstIndex(where: { $0.objectID == activityLog.objectID } ) {
            activityLogs[row] = activityLog
            activityLog.ics214AcivityModDate = Date()
            activityLog.ics214ActivityBackedUp = false
            if let guid = activityLog.ics214ActivityGuid {
                saveTheModifiedActivityLog(guid: guid)
            }
        }
    }
    
    func getSaveActivityLogSize(position: Int)->CGFloat {
        let activity = activityLogs[position]
        let theActivityLogsText = activity.ics214ActivityLog
        if theActivityLogsText != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: activityLogViewHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = theActivityLogsText
            let estimatedSize = textView.sizeThatFits(size)
            
            saveActivityLogViewHeight = estimatedSize.height + 145
            if saveActivityLogViewHeight < 145 {
                saveActivityLogViewHeight = 145
            }
        }
        return saveActivityLogViewHeight
    }
    
    
}


