//
//  UserTime+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/12/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension UserTime {
    
    func newUserTimeToTheCloud()->CKRecord {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
        let dateFormatted = dateFormatter.string(from: self.userStartShiftTime ?? Date())
        let name = "UserTime \(dateFormatted)"
        let fjuserTimeRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjuserTimeRID = CKRecord.ID(recordName: name, zoneID: fjuserTimeRZ.zoneID)
        let fjUserTimeRecord = CKRecord.init(recordType: "UserTime", recordID: fjuserTimeRID)
        _ = CKRecord.Reference(recordID: fjuserTimeRID, action: .deleteSelf)
        
        fjUserTimeRecord["entryState"] = self.entryState
        fjUserTimeRecord["endShiftStatus"] = self.endShiftStatus
        fjUserTimeRecord["shiftCompleted"] = self.shiftCompleted
        fjUserTimeRecord["startShiftStatus"] = self.startShiftStatus
        fjUserTimeRecord["updateShiftStatus"] = self.updateShiftStatus
        fjUserTimeRecord["userTimeBackup"] = self.userTimeBackup

        if let endDate: Date = self.userEndShiftTime {
            fjUserTimeRecord["userEndShiftTime"] = endDate
        }
        if let startDate: Date = self.userStartShiftTime {
            fjUserTimeRecord["userStartShiftTime"] = startDate
        }
        if let updateDate: Date = self.userUpdateShiftTime {
            fjUserTimeRecord["userUpdateShiftTime"] = updateDate
        }
        if let endShiftDiscussion = self.endShiftDiscussion {
        fjUserTimeRecord["endShiftDiscussion"] = endShiftDiscussion
        }
        if let endShiftSupervisor = self.endShiftSupervisor {
        fjUserTimeRecord["endShiftSupervisor"] = endShiftSupervisor
        }
        
        if let enShiftRelievedBy = self.enShiftRelievedBy {
        fjUserTimeRecord["enShiftRelievedBy"] = enShiftRelievedBy
        }
        if let startShiftApparatus = self.startShiftApparatus {
        fjUserTimeRecord["startShiftApparatus"] = startShiftApparatus
        }
        if let startShiftAssignment = self.startShiftAssignment {
        fjUserTimeRecord["startShiftAssignment"] = startShiftAssignment
        }
        if let startShiftCrew = startShiftCrew {
        fjUserTimeRecord["startShiftCrew"] = startShiftCrew
        }
        if let startShiftDiscussion = self.startShiftDiscussion {
        fjUserTimeRecord["startShiftDiscussion"] = startShiftDiscussion
        }
        if let startShiftFireStation = self.startShiftFireStation {
        fjUserTimeRecord["startShiftFireStation"] = startShiftFireStation
        }
        if let startShiftPlatoon = self.startShiftPlatoon {
        fjUserTimeRecord["startShiftPlatoon"] = startShiftPlatoon
        }
        if let startShiftRelieving = self.startShiftRelieving {
        fjUserTimeRecord["startShiftRelieving"] = startShiftRelieving
        }
        if let startShiftResources = self.startShiftResources {
        fjUserTimeRecord["startShiftResources"] = startShiftResources
        }
        if let startShiftSupervisor = self.startShiftSupervisor {
        fjUserTimeRecord["startShiftSupervisor"] = startShiftSupervisor
        }
        if let updateShiftDiscussion = self.updateShiftDiscussion {
        fjUserTimeRecord["updateShiftDiscussion"] = updateShiftDiscussion
        }
        if let updateShiftFireStation = self.updateShiftFireStation {
        fjUserTimeRecord["updateShiftFireStation"] = updateShiftFireStation
        }
        if let updateShiftPlatoon = self.updateShiftPlatoon {
        fjUserTimeRecord["updateShiftPlatoon"] = updateShiftPlatoon
        }
        if let updateShiftRelievedBy = self.updateShiftRelievedBy {
        fjUserTimeRecord["updateShiftRelievedBy"] = updateShiftRelievedBy
        }
        if let updateShiftSupervisor = self.updateShiftSupervisor {
        fjUserTimeRecord["updateShiftSupervisor"] = updateShiftSupervisor
        }
        if let userTimeDayOfYear = self.userTimeDayOfYear {
        fjUserTimeRecord["userTimeDayOfYear"] = userTimeDayOfYear
        }
        if let userTimeGuid = self.userTimeGuid {
        fjUserTimeRecord["userTimeGuid"] = userTimeGuid
        }
        if let userTimeYear = self.userTimeYear {
        fjUserTimeRecord["userTimeYear"] = userTimeYear
        }
        var journalEntries = [String]()
        var incidentEntries = [String]()
        var arcFormEntries = [String]()
        var ics214Entries = [String]()
        var projectEntries = [String]()
        if let journals = self.journal?.allObjects as? [Journal] {
            for journal in journals {
                if let guid = journal.fjpJGuidForReference {
                    journalEntries.append(guid)
                }
            }
        }
        if let incidents = self.incident?.allObjects as? [Incident] {
            for incident in incidents {
                if let guid = incident.fjpIncGuidForReference {
                    incidentEntries.append(guid)
                }
            }
        }
        if let arcForms = self.arcForm?.allObjects as? [ARCrossForm] {
            for arcForm in arcForms {
                if let guid = arcForm.arcFormGuid {
                    arcFormEntries.append(guid)
                }
            }
        }
        if let ics214s = self.ics214?.allObjects as? [ICS214Form] {
            for ics214 in ics214s {
                if let guid = ics214.ics214Guid {
                    ics214Entries.append(guid)
                }
            }
        }
        if let projects = self.promotion?.allObjects as? [PromotionJournal] {
            for project in projects {
                if let guid = project.projectGuid {
                    projectEntries.append(guid)
                }
            }
        }
        if !journalEntries.isEmpty {
            fjUserTimeRecord["journalGuids"] = journalEntries
        }
        if !incidentEntries.isEmpty {
            fjUserTimeRecord["incidentGuids"] = incidentEntries
        }
        if !arcFormEntries.isEmpty {
            fjUserTimeRecord["arcFormGuids"] = arcFormEntries
        }
        if !ics214Entries.isEmpty {
            fjUserTimeRecord["ics214Guids"] = ics214Entries
        }
        if !projectEntries.isEmpty {
            fjUserTimeRecord["projectGuids"] = projectEntries
        }
        fjUserTimeRecord["theEntity"] = "UserTime"
        
        return fjUserTimeRecord
    }
    
    func modifyUserTimeForCloud(ckRecord:CKRecord)->CKRecord {
        let fjUserTimeRecord = ckRecord
        
        fjUserTimeRecord["entryState"] = self.entryState
        fjUserTimeRecord["endShiftStatus"] = self.endShiftStatus
        fjUserTimeRecord["shiftCompleted"] = self.shiftCompleted
        fjUserTimeRecord["startShiftStatus"] = self.startShiftStatus
        fjUserTimeRecord["updateShiftStatus"] = self.updateShiftStatus
        fjUserTimeRecord["userTimeBackup"] = self.userTimeBackup

        if let endDate: Date = self.userEndShiftTime {
            fjUserTimeRecord["userEndShiftTime"] = endDate
        }
        if let startDate: Date = self.userStartShiftTime {
            fjUserTimeRecord["userStartShiftTime"] = startDate
        }
        if let updateDate: Date = self.userUpdateShiftTime {
            fjUserTimeRecord["userUpdateShiftTime"] = updateDate
        }
        if let endShiftDiscussion = self.endShiftDiscussion {
        fjUserTimeRecord["endShiftDiscussion"] = endShiftDiscussion
        }
        if let endShiftSupervisor = self.endShiftSupervisor {
        fjUserTimeRecord["endShiftSupervisor"] = endShiftSupervisor
        }
        
        if let enShiftRelievedBy = self.enShiftRelievedBy {
        fjUserTimeRecord["enShiftRelievedBy"] = enShiftRelievedBy
        }
        if let startShiftApparatus = self.startShiftApparatus {
        fjUserTimeRecord["startShiftApparatus"] = startShiftApparatus
        }
        if let startShiftAssignment = self.startShiftAssignment {
        fjUserTimeRecord["startShiftAssignment"] = startShiftAssignment
        }
        if let startShiftCrew = startShiftCrew {
        fjUserTimeRecord["startShiftCrew"] = startShiftCrew
        }
        if let startShiftDiscussion = self.startShiftDiscussion {
        fjUserTimeRecord["startShiftDiscussion"] = startShiftDiscussion
        }
        if let startShiftFireStation = self.startShiftFireStation {
        fjUserTimeRecord["startShiftFireStation"] = startShiftFireStation
        }
        if let startShiftPlatoon = self.startShiftPlatoon {
        fjUserTimeRecord["startShiftPlatoon"] = startShiftPlatoon
        }
        if let startShiftRelieving = self.startShiftRelieving {
        fjUserTimeRecord["startShiftRelieving"] = startShiftRelieving
        }
        if let startShiftResources = self.startShiftResources {
        fjUserTimeRecord["startShiftResources"] = startShiftResources
        }
        if let startShiftSupervisor = self.startShiftSupervisor {
        fjUserTimeRecord["startShiftSupervisor"] = startShiftSupervisor
        }
        if let updateShiftDiscussion = self.updateShiftDiscussion {
        fjUserTimeRecord["updateShiftDiscussion"] = updateShiftDiscussion
        }
        if let updateShiftFireStation = self.updateShiftFireStation {
        fjUserTimeRecord["updateShiftFireStation"] = updateShiftFireStation
        }
        if let updateShiftPlatoon = self.updateShiftPlatoon {
        fjUserTimeRecord["updateShiftPlatoon"] = updateShiftPlatoon
        }
        if let updateShiftRelievedBy = self.updateShiftRelievedBy {
        fjUserTimeRecord["updateShiftRelievedBy"] = updateShiftRelievedBy
        }
        if let updateShiftSupervisor = self.updateShiftSupervisor {
        fjUserTimeRecord["updateShiftSupervisor"] = updateShiftSupervisor
        }
        if let userTimeDayOfYear = self.userTimeDayOfYear {
        fjUserTimeRecord["userTimeDayOfYear"] = userTimeDayOfYear
        }
        if let userTimeGuid = self.userTimeGuid {
        fjUserTimeRecord["userTimeGuid"] = userTimeGuid
        }
        if let userTimeYear = self.userTimeYear {
        fjUserTimeRecord["userTimeYear"] = userTimeYear
        }
        
        var journalEntries = [String]()
        var incidentEntries = [String]()
        var arcFormEntries = [String]()
        var ics214Entries = [String]()
        var projectEntries = [String]()
        if let journals = self.journal?.allObjects as? [Journal] {
            for journal in journals {
                if let guid = journal.fjpJGuidForReference {
                    journalEntries.append(guid)
                }
            }
        }
        if let incidents = self.incident?.allObjects as? [Incident] {
            for incident in incidents {
                if let guid = incident.fjpIncGuidForReference {
                    incidentEntries.append(guid)
                }
            }
        }
        if let arcForms = self.arcForm?.allObjects as? [ARCrossForm] {
            for arcForm in arcForms {
                if let guid = arcForm.arcFormGuid {
                    arcFormEntries.append(guid)
                }
            }
        }
        if let ics214s = self.ics214?.allObjects as? [ICS214Form] {
            for ics214 in ics214s {
                if let guid = ics214.ics214Guid {
                    ics214Entries.append(guid)
                }
            }
        }
        if let projects = self.promotion?.allObjects as? [PromotionJournal] {
            for project in projects {
                if let guid = project.projectGuid {
                    projectEntries.append(guid)
                }
            }
        }
        if !journalEntries.isEmpty {
            fjUserTimeRecord["journalGuids"] = journalEntries
        }
        if !incidentEntries.isEmpty {
            fjUserTimeRecord["incidentGuids"] = incidentEntries
        }
        if !arcFormEntries.isEmpty {
            fjUserTimeRecord["arcFormGuids"] = arcFormEntries
        }
        if !ics214Entries.isEmpty {
            fjUserTimeRecord["ics214Guids"] = ics214Entries
        }
        if !projectEntries.isEmpty {
            fjUserTimeRecord["projectGuids"] = projectEntries
        }
        
        fjUserTimeRecord["theEntity"] = "UserTime"
        
        return fjUserTimeRecord
    }
    
    func updateUserTimeFromTheCloud(ckRecord: CKRecord) {
        
        let fjUserTimeRecord = ckRecord
        
        
        if let entryState = fjUserTimeRecord["entryState"] as? Int64 {
            self.entryState = entryState
        }
        
        if let endShiftStatus = fjUserTimeRecord["endShiftStatus"] as? Double {
            self.endShiftStatus = Bool(truncating: endShiftStatus as NSNumber)
        }
        if let shiftCompleted = fjUserTimeRecord["shiftCompleted"] as? Double {
            self.shiftCompleted = Bool(truncating: shiftCompleted as NSNumber)
        }
        if let startShiftStatus = fjUserTimeRecord["startShiftStatus"] as? Double {
            self.startShiftStatus = Bool(truncating: startShiftStatus as NSNumber)
        }
        if let updateShiftStatus = fjUserTimeRecord["updateShiftStatus"] as? Double {
            self.updateShiftStatus = Bool(truncating: updateShiftStatus as NSNumber)
        }
        if let userTimeBackup = fjUserTimeRecord["userTimeBackup"] as? Double {
            self.userTimeBackup = Bool(truncating: userTimeBackup as NSNumber)
        }
        

        if let endDate = fjUserTimeRecord["userEndShiftTime"] as? Date {
            self.userEndShiftTime = endDate
        }
        if let startDate = fjUserTimeRecord["userStartShiftTime"] as? Date {
            self.userStartShiftTime = startDate
        }
        if let updateDate = fjUserTimeRecord["userUpdateShiftTime"] as? Date {
            self.userUpdateShiftTime = updateDate
        }
        
        if let endShiftDiscussion = fjUserTimeRecord["endShiftDiscussion"] as? String{
            self.endShiftDiscussion = endShiftDiscussion
        }
        if let endShiftSupervisor = fjUserTimeRecord["endShiftSupervisor"] as? String{
            self.endShiftSupervisor = endShiftSupervisor
        }
        
        if let enShiftRelievedBy = fjUserTimeRecord["enShiftRelievedBy"] as? String {
            self.enShiftRelievedBy = enShiftRelievedBy
        }
        if let startShiftApparatus = fjUserTimeRecord["startShiftApparatus"] as? String {
            self.startShiftApparatus = startShiftApparatus
        }
        if let startShiftAssignment = fjUserTimeRecord["startShiftAssignment"] as? String {
            self.startShiftAssignment = startShiftAssignment
        }
        if let startShiftCrew = fjUserTimeRecord["startShiftCrew"] as? String {
            self.startShiftCrew = startShiftCrew
        }
        if let startShiftDiscussion = fjUserTimeRecord["startShiftDiscussion"] as? String {
            self.startShiftDiscussion = startShiftDiscussion
        }
        if let startShiftFireStation = fjUserTimeRecord["startShiftFireStation"] as? String {
            self.startShiftFireStation = startShiftFireStation
        }
        if let startShiftPlatoon =  fjUserTimeRecord["startShiftPlatoon"] as? String {
            self.startShiftPlatoon = startShiftPlatoon
        }
        if let startShiftRelieving = fjUserTimeRecord["startShiftRelieving"] as? String {
            self.startShiftRelieving = startShiftRelieving
        }
        if let startShiftResources = fjUserTimeRecord["startShiftResources"] as? String  {
            self.startShiftResources = startShiftResources
        }
        if let startShiftSupervisor = fjUserTimeRecord["startShiftSupervisor"]  as? String {
            self.startShiftSupervisor = startShiftSupervisor
        }
        if let updateShiftDiscussion =  fjUserTimeRecord["updateShiftDiscussion"]  as? String {
            self.updateShiftDiscussion = updateShiftDiscussion
        }
        if let updateShiftFireStation = fjUserTimeRecord["updateShiftFireStation"]  as? String {
            self.updateShiftFireStation = updateShiftFireStation
        }
        if let updateShiftPlatoon = fjUserTimeRecord["updateShiftPlatoon"]  as? String {
            self.updateShiftPlatoon = updateShiftPlatoon
        }
        if let updateShiftRelievedBy = fjUserTimeRecord["updateShiftRelievedBy"]  as? String {
            self.updateShiftRelievedBy = updateShiftRelievedBy
        }
        if let updateShiftSupervisor =  fjUserTimeRecord["updateShiftSupervisor"]  as? String {
            self.updateShiftSupervisor = updateShiftSupervisor
        }
        if let userTimeDayOfYear =  fjUserTimeRecord["userTimeDayOfYear"]  as? String {
            self.userTimeDayOfYear = userTimeDayOfYear
        }
        if let userTimeGuid = fjUserTimeRecord["userTimeGuid"]  as? String {
            self.userTimeGuid = userTimeGuid
        }
        if let userTimeYear =  fjUserTimeRecord["userTimeYear"]  as? String {
            self.userTimeYear = userTimeYear
        }
                
        
        var journalEntries = [String]()
        var incidentEntries = [String]()
        var arcFormEntries = [String]()
        var ics214Entries = [String]()
        var projectEntries = [String]()
        
        if let journals = fjUserTimeRecord["journalGuids"] as? [String] {
            for journal in journals {
                journalEntries.append(journal)
            }
        }
        if let incidents = fjUserTimeRecord["incidentGuids"] as? [String] {
            for incident in incidents {
                incidentEntries.append(incident)
            }
        }
        if let arcForms = fjUserTimeRecord["acrFormGuids"] as? [String] {
            for arcForm in arcForms {
                arcFormEntries.append(arcForm)
            }
        }
        if let ics214s = fjUserTimeRecord["ics214Guids"] as? [String] {
            for ics214 in ics214s {
                ics214Entries.append(ics214)
            }
        }
        if let projects = fjUserTimeRecord["projectGuids"] as? [String] {
            for project in projects {
                projectEntries.append(project)
            }
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserTimeRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjUserTimeCKR = data as NSObject
        saveTheSingleCD() {_ in
            self.saveToCDWithAdditionalStrings(journalEntries, incidentEntries, projectEntries, ics214Entries, arcFormEntries) {
                print("userTime from cloud all finished")
            }
        }
    }
    
    private func saveToCDWithAdditionalStrings(_ journals: [String],_ incidents: [String],_ projects: [String],_ ics214s: [String],_ arcForms: [String],completionBlock: () -> ()) {
        let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
        let privateDatabase: CKDatabase = myContainer.privateCloudDatabase
        let id = self.objectID
        lazy var userTimeProvider: UserTimeProvider = {
            let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
            return provider
        }()
        let userTimeContext: NSManagedObjectContext = userTimeProvider.persistentContainer.newBackgroundContext()
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
            if !journals.isEmpty {
                for journal in journals {
                    if let journal = journalCheckCD(journal) {
                        self.addToJournal(journal)
                    } else {
                        DispatchQueue.global(qos: .background).async {
                        let journalSyncOperation = SingleJournalCDFromCloudOperation()
                            self.buildJournalCKRecord(journal, journalSyncOperation, id, userTimeContext, privateDatabase)
                        }
                    }
                }
            }
            if !incidents.isEmpty {
                for incident in incidents {
                    if let theIncident = incidentCheckCD(incident) {
                        self.addToIncident(theIncident)
                    } else {
                        DispatchQueue.global(qos: .background).async {
                        let incidentSyncOperation = SingleIncidentCDFromCloudOperation()
                            self.buildIncidentCKRecord(incident, incidentSyncOperation, id, userTimeContext, privateDatabase)
                        }
                    }
                }
                
            }
            if !projects.isEmpty {
                for project in projects {
                    if let theProject = promotionJournalCheckCD(project) {
                        self.addToPromotion(theProject)
                    } else {
                        DispatchQueue.global(qos: .background).async {
                        let projectSyncOperation = SingleProjectCDFromCloudOperation()
                            self.buildPromotionJournalCKRecord(project, projectSyncOperation, id, userTimeContext, privateDatabase)
                        }
                    }
                }
            }
            if !ics214s.isEmpty {
                for ics214 in ics214s {
                    if let theICS214 = ics214CheckCD(ics214) {
                        self.addToIcs214(theICS214)
                    } else {
                        DispatchQueue.global(qos: .background).async {
                            let ics214Sync = SingleICS214CDFromCloudOperation()
                            self.buildICS214CKRecord(ics214, ics214Sync, id, userTimeContext, privateDatabase)
                        }
                    }
                }
            }
            if !arcForms.isEmpty {
                for arcForm in arcForms {
                    if let theARCrossForm = arCrossFormCheckCD(arcForm) {
                        self.addToArcForm(theARCrossForm)
                    } else {
                        DispatchQueue.global(qos: .background).async {
                                let arcFormSync = SingleARCFormCDFromCloudOperation()
                            self.buildARCrossFormCKRecord(arcForm, arcFormSync, id, userTimeContext, privateDatabase)
                        }
                    }
                }
            }
            completionBlock()
        } catch let error as NSError {
            let nserror = error
            let error = "The ICS214ActivityLog+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
    
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
        } catch let error as NSError {
            let nserror = error
            let error = "The ICS214ActivityLog+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
    
//    MARK: -JOURNAL FROM CORE DATA-
    
        /// Search the container for journal guid tied userTimeshift
        /// - Parameter guid: journal guid string
        /// - Returns: journal object
    func journalCheckCD(_ guid: String) -> Journal? {
        var journal: Journal!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@", "fjpJGuidForReference", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [Journal]
            if !fetched.isEmpty {
                journal = fetched.last
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return journal
    }
    
//    MARK: -GET JOURNAL ENTRY FROM CLOUD-
    
        /// retrieve journal entry from cloud tied UserTime
        /// - Parameters:
        ///   - journal: guid tied to journal entry
        ///   - journalSyncOperation: theQueue
        ///   - id: UserTime objectID
        ///   - userTimeContext: context
        ///   - privateDatabase: cloudKit privatte database
    fileprivate func buildJournalCKRecord(_ journal: String, _ journalSyncOperation: SingleJournalCDFromCloudOperation, _ id: NSManagedObjectID, _ userTimeContext: NSManagedObjectContext, _ privateDatabase: CKDatabase) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "fjpJGuidForReference == %@", journal)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        let sort = NSSortDescriptor(key: "journalCreationDate", ascending: false)
        let query = CKQuery.init(recordType: "Journal", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        var journalRecordsA = [CKRecord]()
        operation.recordMatchedBlock = { recordid, result in
            switch result {
            case .success(let record):
                journalRecordsA.append(record)
            case .failure(let error):
                print("error on retrieving status \(error)")
            }
        }
        operation.queryResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                if !journalRecordsA.isEmpty {
                    for ckRecord in journalRecordsA {
                        journalSyncOperation.singleJournalPendingQueue.isSuspended = true
                        let operation = SingleJournalBuildFromCloudOperation(ckRecord, id, userTimeContext)
                        journalSyncOperation.singleJournalPendingQueue.addOperation(operation)
                        journalSyncOperation.singleJournalPendingQueue.isSuspended = false
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the status operation error \(error)")
                }
            }
        }
        
        privateDatabase.add(operation)
    }
    
        //    MARK: -INCIDENT FROM CORE DATA-
            
                /// Search the container for incident guid tied userTimeshift
                /// - Parameter guid: INCIDENT guid string
                /// - Returns: incident object
            func incidentCheckCD(_ guid: String) -> Incident? {
                var incident: Incident!
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K == %@", "fjpIncGuidForReference", guid)
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                
                do {
                    let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [Incident]
                    if !fetched.isEmpty {
                        incident = fetched.last
                    }
                } catch let error as NSError {
                    print("Fetch failed: \(error.localizedDescription)")
                }
                return incident
            }
    
    
//    MARK: -GET INCIDENT ENTRY FROM CLOUD-
    
        /// retrieve incidentl entry from cloud tied UserTime
        /// - Parameters:
        ///   - incident: guid tied to incident entry
        ///   - incidentSyncOperation: theQueue
        ///   - id: UserTime objectID
        ///   - userTimeContext: context
        ///   - privateDatabase: cloudKit private database
    fileprivate func buildIncidentCKRecord(_ incident: String, _ incidentSyncOperation: SingleIncidentCDFromCloudOperation, _ id: NSManagedObjectID, _ userTimeContext: NSManagedObjectContext, _ privateDatabase: CKDatabase) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "fjpIncGuidForReference == %@", incident)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        let sort = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
        let query = CKQuery.init(recordType: "Incident", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        var incidentRecordsA = [CKRecord]()
        operation.recordMatchedBlock = { recordid, result in
            switch result {
            case .success(let record):
                incidentRecordsA.append(record)
            case .failure(let error):
                print("error on retrieving status \(error)")
            }
        }
        operation.queryResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                if !incidentRecordsA.isEmpty {
                    for ckRecord in incidentRecordsA {
                        incidentSyncOperation.singleIncidentPendingQueue.isSuspended = true
                        let operation = SingleIncidentBuildFromCloudOperation(ckRecord, id, userTimeContext)
                        incidentSyncOperation.singleIncidentPendingQueue.addOperation(operation)
                        incidentSyncOperation.singleIncidentPendingQueue.isSuspended = false
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the status operation error \(error)")
                }
            }
        }
        
        privateDatabase.add(operation)
    }
    
        //    MARK: -PromotionJournal FROM CORE DATA-
            
                /// Search the container for PromotionJournal guid tied userTimeshift
                /// - Parameter guid: PromotionJournal guid string
                /// - Returns: PromotionJournal object
            func promotionJournalCheckCD(_ guid: String) -> PromotionJournal? {
                var promotionJournal: PromotionJournal!
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionJournal" )
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K == %@", "projectGuid", guid)
                let sectionSortDescriptor = NSSortDescriptor(key: "promotionDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                
                do {
                    let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [PromotionJournal]
                    if !fetched.isEmpty {
                        promotionJournal = fetched.last
                    }
                } catch let error as NSError {
                    print("Fetch failed: \(error.localizedDescription)")
                }
                return promotionJournal
            }
    
    
        //    MARK: -GET PROMOTIONJOURNAL ENTRY FROM CLOUD-
            
                /// retrieve project entry from cloud tied UserTime
                /// - Parameters:
                ///   - project: guid tied to promotionJournal entry
                ///   - projectSyncOperation: theQueue
                ///   - id: UserTime objectID
                ///   - userTimeContext: context
                ///   - privateDatabase: cloudKit private database
            fileprivate func buildPromotionJournalCKRecord(_ project: String, _ projectSyncOperation: SingleProjectCDFromCloudOperation, _ id: NSManagedObjectID, _ userTimeContext: NSManagedObjectContext, _ privateDatabase: CKDatabase) {
                let predicate = NSPredicate(format: "TRUEPREDICATE")
                let predicate2 = NSPredicate(format: "projectGuid == %@", project)
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
                let sort = NSSortDescriptor(key: "promotionDate", ascending: false)
                let query = CKQuery.init(recordType: "ProjectJournal", predicate: predicateCan)
                query.sortDescriptors = [sort]
                let operation = CKQueryOperation(query: query)
                var projectRecordsA = [CKRecord]()
                operation.recordMatchedBlock = { recordid, result in
                    switch result {
                    case .success(let record):
                        projectRecordsA.append(record)
                    case .failure(let error):
                        print("error on retrieving status \(error)")
                    }
                }
                operation.queryResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        if !projectRecordsA.isEmpty {
                            for ckRecord in projectRecordsA {
                                projectSyncOperation.singleProjectPendingQueue.isSuspended = true
                                let operation = SingleProjectBuildFromCloudOperation(ckRecord, id, userTimeContext)
                                projectSyncOperation.singleProjectPendingQueue.addOperation(operation)
                                projectSyncOperation.singleProjectPendingQueue.isSuspended = false
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the status operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(operation)
            }
    
        //    MARK: -ICS214 FROM CORE DATA-
            
                /// Search the container for ICS214 guid tied userTimeshift
                /// - Parameter guid: ICS214 guid string
                /// - Returns: ICS214 object
            func ics214CheckCD(_ guid: String) -> ICS214Form? {
                var theICS214: ICS214Form!
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K == %@", "ics214Guid", guid)
                let sectionSortDescriptor = NSSortDescriptor(key: "ics214ToTime", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                
                do {
                    let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [ICS214Form]
                    if !fetched.isEmpty {
                        theICS214 = fetched.last
                    }
                } catch let error as NSError {
                    print("Fetch failed: \(error.localizedDescription)")
                }
                return theICS214
            }
    
        //    MARK: -GET ICS214FORM ENTRY FROM CLOUD-
            
                /// retrieve ics214 entry from cloud tied UserTime
                /// - Parameters:
                ///   - ics214: guid tied to ics214 entry
                ///   - ics214SyncOperation: theQueue
                ///   - id: UserTime objectID
                ///   - userTimeContext: context
                ///   - privateDatabase: cloudKit private database
            fileprivate func buildICS214CKRecord(_ ics214: String, _ ics214SyncOperation: SingleICS214CDFromCloudOperation, _ id: NSManagedObjectID, _ userTimeContext: NSManagedObjectContext, _ privateDatabase: CKDatabase) {
                let predicate = NSPredicate(format: "TRUEPREDICATE")
                let predicate2 = NSPredicate(format: "ics214Guid == %@", ics214)
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
                let sort = NSSortDescriptor(key: "ics214ToTime", ascending: false)
                let query = CKQuery.init(recordType: "ICS214Form", predicate: predicateCan)
                query.sortDescriptors = [sort]
                let operation = CKQueryOperation(query: query)
                var ics214RecordsA = [CKRecord]()
                operation.recordMatchedBlock = { recordid, result in
                    switch result {
                    case .success(let record):
                        ics214RecordsA.append(record)
                    case .failure(let error):
                        print("error on retrieving status \(error)")
                    }
                }
                operation.queryResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        if !ics214RecordsA.isEmpty {
                            for ckRecord in ics214RecordsA {
                                ics214SyncOperation.singleICS214PendingQueue.isSuspended = true
                                let operation = SingleICS214BuildFromCloudOperation(ckRecord, id, userTimeContext)
                                ics214SyncOperation.singleICS214PendingQueue.addOperation(operation)
                                ics214SyncOperation.singleICS214PendingQueue.isSuspended = false
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the status operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(operation)
            }
    
        //    MARK: -ARCrossForm FROM CORE DATA-
            
                /// Search the container for ARCrossForm guid tied userTimeshift
                /// - Parameter guid: ARCrossForm guid string
                /// - Returns: ARCrossForm object
            func arCrossFormCheckCD(_ guid: String) -> ARCrossForm? {
                var theARCrossForm: ARCrossForm!
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K == %@", "arcFormGuid", guid)
                let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                
                do {
                    let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [ARCrossForm]
                    if !fetched.isEmpty {
                        theARCrossForm = fetched.last
                    }
                } catch let error as NSError {
                    print("Fetch failed: \(error.localizedDescription)")
                }
                return theARCrossForm
            }
    
        //    MARK: -GET ARCrossForm ENTRY FROM CLOUD-
            
                /// retrieve ARCrossForm entry from cloud tied UserTime
                /// - Parameters:
                ///   - ics214: guid tied to ARCrossForm entry
                ///   - ics214SyncOperation: theQueue
                ///   - id: UserTime objectID
                ///   - userTimeContext: context
                ///   - privateDatabase: cloudKit private database
            fileprivate func buildARCrossFormCKRecord(_ arCrossFormGuid: String, _ arCrossFormSyncOperation: SingleARCFormCDFromCloudOperation, _ id: NSManagedObjectID, _ userTimeContext: NSManagedObjectContext, _ privateDatabase: CKDatabase) {
                let predicate = NSPredicate(format: "TRUEPREDICATE")
                let predicate2 = NSPredicate(format: "arcFormGuid == %@", arCrossFormGuid)
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
                let sort = NSSortDescriptor(key: "arcCreationDate", ascending: false)
                let query = CKQuery.init(recordType: "ARCrossForm", predicate: predicateCan)
                query.sortDescriptors = [sort]
                let operation = CKQueryOperation(query: query)
                var arCrossFormRecordsA = [CKRecord]()
                operation.recordMatchedBlock = { recordid, result in
                    switch result {
                    case .success(let record):
                        arCrossFormRecordsA.append(record)
                    case .failure(let error):
                        print("error on retrieving status \(error)")
                    }
                }
                operation.queryResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        if !arCrossFormRecordsA.isEmpty {
                            for ckRecord in arCrossFormRecordsA {
                                arCrossFormSyncOperation.singleIARCFormPendingQueue.isSuspended = true
                                let operation = SingleARCFormBuildFromCloudOperation(ckRecord, id, userTimeContext)
                                arCrossFormSyncOperation.singleIARCFormPendingQueue.addOperation(operation)
                                arCrossFormSyncOperation.singleIARCFormPendingQueue.isSuspended = false
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the status operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(operation)
            }
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        if self.managedObjectContext != nil {
            do {
                try self.managedObjectContext?.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"UserTimre Saved"])
                    print("project we have saved to the cloud")
                }
                completion("Success")
            } catch {
                let nserror = error as NSError
                
                let error = "The UserTime context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
                print(error)
                completion("Error")
            }
        }
    }
    
}
