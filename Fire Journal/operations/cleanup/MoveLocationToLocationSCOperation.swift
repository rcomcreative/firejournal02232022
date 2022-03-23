//
//  MoveLocationToLocationSCOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/14/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class MoveLocationToLocationSCOperation: FJOperation {

    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var arcrossForm: ARCrossForm!
    var fireJournalUserA = [FireJournalUser]()
    var arcFormA = [ARCrossForm]()
    var ics214A = [ICS214Form]()
    var incidentA = [Incident]()
    var journalA = [Journal]()
    var fireSafetyInspectionA = [FireSafetyInspection]()
    var userFDResourcesA = [UserFDResources]()
    var ckRecordA = [CKRecord]()
    var fjuCKRecord: CKRecord!
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var ckRecord:CKRecord!
    let dateFormatter = DateFormatter()
    let type: MenuItems!
    
    init(_ context: NSManagedObjectContext,database: CKDatabase, theType: MenuItems ) {
        self.context = context
        self.privateDatabase = database
        self.type = theType
        super.init()
        self.bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.bkgrdContext.persistentStoreCoordinator = self.context.persistentStoreCoordinator
        self.thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
    }
    
//    MARK: -THREAD-
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("MoveLocationToLocationSCOperation here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func main() {
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        executing(true)
        
        switch type {
        case .arcForm:
            arcFormA = getAllARCFormLocations()
            if arcFormA.isEmpty {
                cancelTheOperation(theType: "ARCrossForm", type: MenuItems.fjuser)
            } else {
                arCRossFormChangeLocationToLocationSC() {
                    saveToCD()
                    cancelTheOperation(theType: "ARCrossForm", type: MenuItems.fjuser)
                }
            }
        case .fjuser:
            fireJournalUserA = getAllUsersLocations()
            if fireJournalUserA.isEmpty {
                cancelTheOperation(theType: "FireJournalUser", type: MenuItems.fireSafetyInspection)
            } else {
                fireJournalUserChangeLocationToLocationSC() {
                        saveToCD()
                    cancelTheOperation(theType: "FireJournalUser", type: MenuItems.fireSafetyInspection)
                }
            }
        case .fireSafetyInspection:
            fireSafetyInspectionA = getAllFireSafetyInspectionLocations()
            if fireSafetyInspectionA.isEmpty {
                cancelTheOperation(theType: "FireSafetyInspection", type: MenuItems.ics214)
            } else {
                fireSafetyInspectionChangeLocationToLocationSC() {
                    saveToCD()
                    cancelTheOperation(theType: "FireSafetyInspection", type: MenuItems.ics214)
                }
            }
        case .ics214:
            ics214A = getAllICS214Locations()
            if ics214A.isEmpty {
                cancelTheOperation(theType: "ICS214Form", type: MenuItems.incidents)
            } else {
                ics214ChangeLocationToLocationSC() {
                    saveToCD()
                    cancelTheOperation(theType: "ICS214Form", type: MenuItems.ics214)
                }
            }
        case .incidents:
            incidentA = getAllIncidentLocations()
            if incidentA.isEmpty {
                cancelTheOperation(theType: "Incident", type: MenuItems.userFDResource)
            } else {
                incidentLocationToLocationSC() {
                    saveToCD()
                    cancelTheOperation(theType: "Incident", type: MenuItems.userFDResource)
                }
            }
        case .userFDResource:
            userFDResourcesA = getAllUserFDResources()
            if userFDResourcesA.isEmpty {
                cancelTheOperation(theType: "UserFDResources", type: MenuItems.journal)
            } else {
                userReferenceToUserReferrenceSC() {
                    saveToCD()
                    cancelTheOperation(theType: "UserFDResources", type: MenuItems.journal)
                }
            }
        case .journal:
            journalA = getallJournalLocations()
            if journalA.isEmpty {
                cancelTheOperation(theType: "Journal", type: MenuItems.finished)
            } else {
                journalLocationToLocationSC() {
                    saveToCD()
                    cancelTheOperation(theType: "Journal", type: MenuItems.finished)
                }
            }
        default: break
        }
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    private func cancelTheOperation(theType: String, type: MenuItems) {
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkNEXTLOCATIONUPDATE),
                          object: nil,
                          userInfo: ["MenuItems": type])
            print("MoveLocationToLocationSCOperation \(theType) has run and now if finished")
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        }
    }
    
    private func getAllARCFormLocations() -> [ARCrossForm] {
        var array = [ARCrossForm]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "arcLocation")
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [ARCrossForm]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line118 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    private func arCRossFormChangeLocationToLocationSC(withCompletion completion: () -> Void ) {
        for arcForm in arcFormA {
            if arcForm.arcLocation != nil {
                if let location = arcForm.arcLocation as? CLLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        arcForm.arcLocationSC = data as NSObject
                        arcForm.arcLocation = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation arcLocatinSC got an error here")
                    }
                }
            }
        }
        completion()
    }
    
    private func getAllUsersLocations() -> [FireJournalUser] {
        var array = [FireJournalUser]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "fjuLocation")
        let sectionSortDescriptor = NSSortDescriptor(key: "fjpUserModDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [FireJournalUser]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line140 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    private func fireJournalUserChangeLocationToLocationSC(withCompletion completion: () -> Void ) {
        for user in fireJournalUserA {
            if user.fjuLocation != nil {
                if let location = user.fjuLocation as? CLLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        user.fjuLocationSC = data as NSObject
                        user.fjuLocation = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation fjuLocationSC got an error here")
                    }
                }
            }
            if user.aFJUReference != nil {
                if let reference = user.aFJUReference as? CKRecord.Reference {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: reference, requiringSecureCoding: true)
                        user.aFJUReferenceSC = data as NSObject
                        user.aFJUReference = nil
                    } catch {
                        print("firejournaluser reference to data failed line 242")
                    }
                }
            }
            }
        completion()
    }
    
    private func getAllFireSafetyInspectionLocations() -> [FireSafetyInspection] {
        var array = [FireSafetyInspection]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireSafetyInspection" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "fireSafetyLocation")
        let sectionSortDescriptor = NSSortDescriptor(key: "fireSafetyCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [FireSafetyInspection]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line162 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    private func fireSafetyInspectionChangeLocationToLocationSC(withCompletion completion: () -> Void ) {
        for fireSafety in fireSafetyInspectionA {
            if fireSafety.fireSafetyLocation != nil {
                if let location = fireSafety.fireSafetyLocation as? CLLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        fireSafety.fireSafetyLocationSC = data as NSObject
                        fireSafety.fireSafetyLocation = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation fireSafetyLocationSC got an error here")
                    }
                }
            }
            }
        completion()
    }
    
    private func getAllICS214Locations() -> [ICS214Form] {
        var array = [ICS214Form]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "ics214Location")
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214ModDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line184 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    
    private func ics214ChangeLocationToLocationSC(withCompletion completion: () -> Void ) {
        for ics214 in ics214A {
            if ics214.ics214Location != nil {
                if let location = ics214.ics214Location as? CLLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        ics214.ics214LocationSC = data as NSObject
                        ics214.ics214Location = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics214LocationSC got an error here")
                    }
                }
            }
            if ics214.ics214CKReference != nil {
                if let reference = ics214.ics214CKReference as? CKRecord.Reference {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: reference, requiringSecureCoding: true)
                        ics214.ics214CKReferenceSC = data as NSObject
                        ics214.ics214CKReference = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics214CKReference got an error here")
                    }
                }
            }
            }
        completion()
    }
    
    private func getAllIncidentLocations() -> [Incident] {
        var array = [Incident]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "incidentLocation")
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [Incident]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line206 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    
    private func incidentLocationToLocationSC(withCompletion completion: () -> Void ) {
        for incident in incidentA {
            let nfirsRemarks = incident.sectionLDetails
            let incidentNotes = incident.incidentNotesDetails
            let incidentTimer = incident.incidentTimerDetails
            if incident.incidentLocation != nil {
                if let location = incident.incidentLocation as? CLLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        incident.incidentLocationSC = data as NSObject
                        incident.incidentLocation = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation incidentLocationSC got an error here")
                    }
                }
            }
            if incident.anIncidentReference != nil {
                if let reference = incident.anIncidentReference as? CKRecord.Reference {

                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: reference, requiringSecureCoding: true)
                        incident.anIncidentReferenceSC = data as NSObject
                        incident.anIncidentReference = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation anIncidentReferenceSC got an error here")
                    }

                }
            }
            if nfirsRemarks?.lRemarks != nil {
                if let remark = nfirsRemarks?.lRemarks as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: remark, requiringSecureCoding: true)
                        nfirsRemarks?.incidentRemarksSC = data as NSObject
                        nfirsRemarks?.lRemarks = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics352 remark got an error here")
                    }
                }
            }
            if incidentNotes?.incidentSummaryNotes != nil {
                if let note = incidentNotes?.incidentSummaryNotes as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: note, requiringSecureCoding: true)
                        incidentNotes?.incidentSummaryNotesSC = data as NSObject
                        incidentNotes?.incidentSummaryNotes = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics362 remark got an error here")
                    }
                }
            }
            if incidentTimer?.incidentAlarmNotes != nil {
                if let alarm = incidentTimer?.incidentAlarmNotes as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: alarm, requiringSecureCoding: true)
                        incidentTimer?.incidentAlarmNotesSC = data as NSObject
                        incidentTimer?.incidentAlarmNotes = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics372 remark got an error here")
                    }
                }
            }
            if incidentTimer?.incidentArrivalNotes != nil {
                if let arrival = incidentTimer?.incidentArrivalNotes as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: arrival, requiringSecureCoding: true)
                        incidentTimer?.incidentArrivalNotesSC = data as NSObject
                        incidentTimer?.incidentArrivalNotes = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics382 remark got an error here")
                    }
                }
            }
            if incidentTimer?.incidentControlledNotes != nil {
                if let controlled = incidentTimer?.incidentControlledNotes as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: controlled, requiringSecureCoding: true)
                        incidentTimer?.incidentControlledNotesSC = data as NSObject
                        incidentTimer?.incidentControlledNotes = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics392 remark got an error here")
                    }
                }
            }
            if incidentTimer?.incidentLastUnitClearedNotes != nil {
                if let cleared = incidentTimer?.incidentLastUnitClearedNotes as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: cleared, requiringSecureCoding: true)
                        incidentTimer?.incidentLastUnitClearedNotesSC = data as NSObject
                        incidentTimer?.incidentLastUnitClearedNotes = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics402 remark got an error here")
                    }
                }
            }
            }
        completion()
    }
    
    private func getAllUserFDResources() -> [UserFDResources] {
        var array = [UserFDResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "userReference")
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResourceCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [UserFDResources]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line487 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    private func userReferenceToUserReferrenceSC(withCompletion completion: () -> Void ) {
        for resource in userFDResourcesA {
            if resource.userReference != nil {
                if let reference = resource.userReference as? CKRecord.Reference {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: reference, requiringSecureCoding: true)
                        resource.auserReferenceSC = data as NSObject
                        resource.userReference = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation userFDReference got an error here")
                    }
                }
            }
        }
        completion()
    }
    
    private func getallJournalLocations() -> [Journal] {
        var array = [Journal]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != nil", "journalLocation")
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [Journal]
            if !fetched.isEmpty {
                array = fetched
            }
        } catch let error as NSError {
            print("MoveLocationToLocationSCOperation Line430 Fetch Error: \(error.localizedDescription)")
        }
        return array
    }
    
    private func journalLocationToLocationSC(withCompletion completion: () -> Void ) {
        for journal in journalA {
            if journal.journalLocation != nil {
                if let location = journal.journalLocation as? CLLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        journal.journalLocationSC = data as NSObject
                        journal.journalLocation = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation journal journalLocationSC got an error here")
                    }
                }
            }
            if journal.journalDiscussion != nil {
                if let discussion = journal.journalDiscussion as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: discussion, requiringSecureCoding: true)
                        journal.journalDiscussionSC = data as NSObject
                        journal.journalDiscussion = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation ics453 discussion got an error here")
                    }
                }
            }
            if journal.journalNextSteps != nil {
                if let nextSteps = journal.journalNextSteps as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: nextSteps, requiringSecureCoding: true)
                        journal.journalNextStepsSC = data as NSObject
                        journal.journalNextSteps = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation 463 nextSteps got an error here")
                    }
                }
            }
            if journal.journalOverview != nil {
                if let overview = journal.journalOverview as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: overview, requiringSecureCoding: true)
                        journal.journalOverviewSC = data as NSObject
                        journal.journalOverview = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation 473 overview got an error here")
                    }
                }
            }
            if journal.journalSummary != nil {
                if let summary = journal.journalSummary as? String {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: summary, requiringSecureCoding: true)
                        journal.journalSummarySC = data as NSObject
                        journal.journalSummary = nil
                    } catch {
                        print("MoveLocationToLocationSCOperation 483 overview got an error here")
                    }
                }
            }
            if journal.aJournalReference != nil {
                if let reference = journal.aJournalReference as? CKRecord.Reference {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: reference, requiringSecureCoding: true)
                        journal.aJournalReferenceSC = data as NSObject
                        journal.aJournalReference = nil
                    } catch {
                        print("Journal reference line 535 MoveLocation error")
                    }
                }
            }
            if journal.aIncidentReference != nil {
                if let reference = journal.aIncidentReference as? CKRecord.Reference {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: reference, requiringSecureCoding: true)
                        journal.aIncidentReferenceSC = data as NSObject
                        journal.aIncidentReference = nil
                    } catch {
                        print("Journal reference line 535 MoveLocation error")
                    }
                }
            }
        }
        completion()
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"MoveLocationToLocationSCOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("MoveLocationToLocationSCOperation error line 299 The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("MoveLocationToLocationSCOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
    
    
}
