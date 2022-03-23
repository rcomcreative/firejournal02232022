//
//  NewICS214ModalTVC+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

extension NewICS214ModalTVC: EffortSetUpCellDelegate {
    
    func effortHasBeenCreated(type: TypeOfForm, name1: String, name2: String, location: CLLocation, streetNum: String, streetName: String, city: String, locationState: String, zip: String, latitude: String, longitude: String ) {

        currentLocation = location
        let ics214Form = ICS214Form.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Form", in: context)!, insertInto: context)
        var formType:String = ""
        if type == TypeOfForm.femaTaskForceForm {
            formType = "FEMA Task Force"
        } else if type == TypeOfForm.strikeForceForm {
            formType = "Strike Team"
        } else if type == TypeOfForm.otherForm {
            formType = "Other"
        }
        ics214Form.ics214Effort = formType
        ics214Form.ics214EffortMaster = true
        ics214Form.ics214BackedUp = false
        let resourceDate = Date()
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        var dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "30."+uuidA
        ics214Form.ics214Guid = uuidA1
        let uuidA2 = "31."+uuidA
        ics214Form.ics214MasterGuid = uuidA2
        masterGuid = uuidA2
        ics214Form.ics214EffortMaster = true
        ics214Form.ics214Count = 1
        ics214Form.ics214Completed = false
        ics214Form.ics214IncidentName = name2
        ics214Form.ics214TeamName = name1
        let fromTime = Date()
        ics214Form.ics214FromTime = fromTime
        ics214Form.ics214ModDate = fromTime
        
        //        MARK: -LOCATION-
        /// ics214Location archived with secureCoding
        if currentLocation != nil {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: currentLocation!, requiringSecureCoding: true)
                ics214Form.ics214LocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
            ics214Form.ics214Latitude = latitude
            ics214Form.ics214Longitude = longitude
        }
        var fju:FireJournalUser!
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser")
        do {
            let userFetched = try context.fetch(userRequest) as! [FireJournalUser]
            if userFetched.count != 0 {
                fju = userFetched.last
            }
        } catch {
            
        }
        var userName = ""
        if let firstName = fju.firstName {
            userName = firstName
        }
        if let lastName = fju.lastName {
            userName = "\(userName) \(lastName)"
        }
        ics214Form.ics214UserName = userName
        ics214Form.icsPreparfedName = userName
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
        let ics214:ICS214Form!
        do {
            let ics214Fetched = try context.fetch(fetchRequest) as! [ICS214Form]
            if ics214Fetched.count != 0 {
                ics214 = ics214Fetched.last
                if let icsPosition = ics214.ics214ICSPosition {
                    ics214Form.ics214ICSPosition = icsPosition
                    ics214Form.icsPreparedPosition = icsPosition
                }
                if let agency = ics214.ics241HomeAgency {
                    ics214Form.ics241HomeAgency = agency
                }
            }
        } catch {
            
        }
        let journalEntry:Journal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let uuidAJ:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidAJ+dateFrom
        let uuidJ = "01."+uuidAJ
        journalEntry.fjpJGuidForReference = uuidJ
        journalEntry.fjpJournalModifiedDate = resourceDate
        journalEntry.journalEntryTypeImageName = "administrativeNewColor58"
        journalEntry.journalEntryType = "Station"
        let platoon = fju.tempPlatoon ?? ""
        journalEntry.journalTempPlatoon = platoon
        let assignment = fju.tempAssignment ?? ""
        journalEntry.journalTempAssignment = assignment
        let apparatus = fju.tempApparatus ?? ""
        journalEntry.journalTempApparatus = apparatus
        let fireStation = fju.tempFireStation ?? ""
        journalEntry.journalTempFireStation = fireStation
        
        if let name = ics214Form.ics214IncidentName {
            journalEntry.journalHeader = "\(formType): \(name)"
        } else {
            journalEntry.journalHeader = "\(formType)"
        }
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MM/dd/YYYY HH:mm"
        let timeStamp = dateFormatter2.string(from: resourceDate)
        let user = ics214Form.ics214UserName
        let teamName = ics214Form.ics214TeamName
        let name = ics214Form.ics214IncidentName
        let overview = "New ICS214 Activity Log entered"
        journalEntry.journalOverview = overview as NSObject
        journalEntry.journalEntryType = "Station"
        journalEntry.journalCity = city
        journalEntry.journalStreetNumber = streetNum
        journalEntry.journalStreetName = streetName
        journalEntry.journalState = locationState
        journalEntry.journalZip = zip
        journalEntry.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        let summary = "Time Stamp: \(timeStamp)\nICS 214 Activity Log: \(formType): \(teamName ?? "") Effort: \(name ?? "")-Master entered by \(user ?? "")\nLocation: \(streetNum) \(streetName) \(city), \(locationState) \(zip)\nLatitude: \(self.latitude)\nLongitude: \(self.longitude)"
        
        
//        MARK: -LOCATION-
        /// journalLocation archived with secureCoding
        if currentLocation != nil {
                if let location = currentLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        journalEntry.journalLocationSC = data as NSObject
                    } catch {
                        print("got an error here")
                    }
                }
            }
    
        journalEntry.journalSummary = summary as NSObject
        journalEntry.journalDateSearch = dateFrom
        journalEntry.journalCreationDate = resourceDate
        journalEntry.journalModDate = resourceDate
        journalEntry.journalPrivate = true
        journalEntry.journalBackedUp = false
        journalEntry.ics214Effort = formType
        journalEntry.ics214MasterGuid = masterGuid
        journalEntry.fjpUserReference = fju.userGuid ?? ""
        journalEntry.journalICS214Details = ics214Form
        journalEntry.fireJournalUserInfo = fju
        
        ics214Form.journalGuid = uuidJ
        ics214Form.fjpUserReference = fju.userGuid
        ics214Form.ics214FJUDetail = fju
        
        saveToCDNewICS214(ics214Guid: uuidA1,journalGuid: uuidJ)
        
    }
    
    func effortUnfinished(warning: String) {
        if !alertUp {
            let alert = UIAlertController.init(title: "Form Incomplete", message: warning, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    private func getTheLastICS214(guid: String)->NSManagedObjectID {
        var objectID:NSManagedObjectID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
        let predicate = NSPredicate(format: "%K == %@", "ics214Guid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 1
        let ics214:ICS214Form!
        do {
            let userFetched = try context.fetch(fetchRequest) as! [ICS214Form]
            if userFetched.count != 0 {
                ics214 = userFetched.last
                objectID = ics214.objectID
            }
        } catch {
            
        }
        return objectID
    }
    
    private func getTheLastJournal(guid: String)->NSManagedObjectID {
        var objectID:NSManagedObjectID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal")
        let predicate = NSPredicate(format: "%K == %@", "fjpJGuidForReference", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        let journal:Journal!
        do {
            let userFetched = try context.fetch(fetchRequest) as! [Journal]
            if userFetched.count != 0 {
                journal = userFetched.last
                objectID = journal.objectID
            }
        } catch {
            
        }
        return objectID
    }
    
    fileprivate func saveToCDNewICS214(ics214Guid: String,journalGuid: String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214 NEW merge that"])
            }
            let objectID = getTheLastICS214(guid: ics214Guid)
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkICS214_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID])
            }
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue: FJkNEWICS214FormCreated),
                        object: nil,
                        userInfo: ["objectID": objectID])
            }
            let jObjectID = getTheLastJournal(guid: journalGuid)
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue: FJkCKNewJournalCreated),
                        object: nil,
                        userInfo: ["objectID": jObjectID])
            }
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkICS214_NEW_TO_LIST),
                        object: nil,
                        userInfo: ["objectID": objectID])
            }
            dismiss(animated: true, completion: nil)
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "NewICS214ModalTVC saveToCD() save Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    
}

extension NewICS214ModalTVC: NewICS214NewIncidentTVCDelegate {
    
    func newICS214NewIncidentCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theNewICS214IncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: {
            let incident = self.context.object(with: ojectID) as? Incident
            self.incidentObjectID = ojectID
            var number = ""
            var master = ""
            var guid = ""
            var streetNum = ""
            var streetName = ""
            var zip = ""
            var imageName = ""
            var imageType = ""
            var incidentDate:Date?
            var isDateHere:String = ""
            var i10:CellParts!
            
            if let incidentNumber = incident?.incidentNumber {
                number = incidentNumber
            }
            if let ics214MasterGuid = incident?.ics214MasterGuid {
                master = ics214MasterGuid
            }
            if let incidentGuid = incident?.fjpIncGuidForReference {
                guid = incidentGuid
            }
            if let streetNumber = incident?.incidentStreetNumber {
                streetNum = streetNumber
            }
            if let streetNamed = incident?.incidentStreetHyway {
                streetName = streetNamed
            }
            if let theZip = incident?.incidentZipCode {
                zip = theZip
            }
            if let imageName = incident?.incidentEntryTypeImageName {
                imageType = imageName
            }
            if let image = incident?.situationIncidentImage {
                imageName = image
            }
                let formType = TypeOfForm.incidentForm.rawValue
                
                if incident?.incidentModDate != nil {
                    incidentDate = incident?.incidentModDate ?? Date()
                    isDateHere = "yes"
                    i10 = CellParts.init(cellAttributes: ["Header":number , "Field1":master , "Field2":guid, "Field3":streetNum,"Field4":streetName,"Value1":zip,"Value2":imageName,"Value3":imageType,"Value4":isDateHere,"Value5":formType,"Value7":number], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":incidentDate!], objID: [ "objectID":self.incidentObjectID ])
                } else {
                    isDateHere = "no"
                    i10 = CellParts.init(cellAttributes: ["Header":number , "Field1":master , "Field2":guid, "Field3":streetNum,"Field4":streetName,"Value1":zip,"Value2":imageName,"Value3":imageType,"Value4":isDateHere,"Value5":formType,"Value7":number], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":self.incidentObjectID ])
                }
            self.modalCells.append(i10)
            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            self.masterOrNot = true
            self.buildTheNewICS214Form(objectID: self.incidentObjectID,master: self.masterOrNot)
        })
//           performSegue(withIdentifier: NewICS214TVCSegue, sender: self)
            
        }
        
    
}

