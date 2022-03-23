//
//  DeleteFromCloudWithGeneratedIDSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/5/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class DeleteFromCloudWithGeneratedIDSyncOperation: FJOperation {
    
    //    MARK: -OPERATION PROPERTIES
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    var ckRData: Data!
    var theEntity: String = ""
    var theAttribute: String = ""
    var theCKRecordIDName: String = ""
    var fetched:Array<Any>!
    var journalA = [Journal]()
    var incidentA = [Incident]()
    var ics214A = [ICS214Form]()
    var arcFormA = [ARCrossForm]()
    var entryDeleted:Bool = false
    
    
    //    MARK: -init of the deleteFromCloudWithGeneratedIDSyncOperation
    init(_ context: NSManagedObjectContext, theCKRecordIDName: String) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.theCKRecordIDName = theCKRecordIDName
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "DeleteFromCloudWithGeneratedIDSyncOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        processTheJournalEntries()
        
        guard isCancelled == false else {
            finish(true)
            return
        }
    }
    
    func processTheJournalEntries() {
        _ = allJournal()
        for journal in journalA {
            let recordName = unarchiveTheRecord(data: journal.fjJournalCKR as! Data)
            if recordName == theCKRecordIDName {
                bkgrdContext.delete(journal as NSManagedObject)
                entryDeleted = true
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                    print("DeleteFromCloudWithGeneratedIDSyncOperation Journal has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        if !entryDeleted {
            journalA.removeAll()
            processTheIncidentEntries()
        }
    }
    
    func processTheIncidentEntries() {
        _ = allIncidents()
        for incident in incidentA {
            let recordName = unarchiveTheRecord(data: incident.fjIncidentCKR as! Data)
            if recordName == theCKRecordIDName {
                bkgrdContext.delete(incident as NSManagedObject)
                entryDeleted = true
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                    print("DeleteFromCloudWithGeneratedIDSyncOperation Incident has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        if !entryDeleted {
            incidentA.removeAll()
            processTheICS214Entries()
        }
    }
    
    func processTheICS214Entries() {
        _ = allICS214()
        for ics214 in ics214A {
            let recordName = unarchiveTheRecord(data: ics214.ics214CKR as! Data)
            if recordName == theCKRecordIDName {
                bkgrdContext.delete(ics214 as NSManagedObject)
                entryDeleted = true
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                    print("DeleteFromCloudWithGeneratedIDSyncOperation ICS214 has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        if !entryDeleted {
            ics214A.removeAll()
            processTheARCFormEntries()
        }
    }
    
    func processTheARCFormEntries() {
        _ = allARCForm()
        for arcForm in arcFormA {
            let recordName = unarchiveTheRecord(data: arcForm.arcFormCKR as! Data)
            if recordName == theCKRecordIDName {
                bkgrdContext.delete(arcForm as NSManagedObject)
                entryDeleted = true
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                    print("DeleteFromCloudWithGeneratedIDSyncOperation ARCForm has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        if !entryDeleted {
            arcFormA.removeAll()
            print("DeleteFromCloudWithGeneratedIDSyncOperation ARCForm has run and now if finished nothing was found to delete")
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        }
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func allJournal() ->Array<Journal> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        let predicate = NSPredicate(format: "%K != nil", "fjJournalCKR")
        let sectionSortDescriptor = NSSortDescriptor(key: theAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            journalA = try bkgrdContext.fetch(fetchRequest) as! [Journal]
        }   catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        return journalA
    }
    
    func allIncidents() ->Array<Incident> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        let predicate = NSPredicate(format: "%K != nil", "fjIncidentCKR")
        let sectionSortDescriptor = NSSortDescriptor(key: theAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            incidentA = try bkgrdContext.fetch(fetchRequest) as! [Incident]
        }   catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        return incidentA
    }
    
    func allICS214() ->Array<ICS214Form> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate = NSPredicate(format: "%K != nil", "ics214CKR")
        let sectionSortDescriptor = NSSortDescriptor(key: theAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            ics214A = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
        }   catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        return ics214A
    }
    
    func allARCForm() ->Array<ARCrossForm> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        let predicate = NSPredicate(format: "%K != nil", "arcFormCKR")
        let sectionSortDescriptor = NSSortDescriptor(key: theAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            arcFormA = try bkgrdContext.fetch(fetchRequest) as! [ARCrossForm]
        }   catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        return arcFormA
    }
    
    func unarchiveTheRecord(data:Data) -> String {
        var recordName: String = ""
        do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data)
            let ckRecord = CKRecord(coder: unarchiver)
            recordName = ckRecord?.recordID.recordName ?? ""
        } catch {
            print("")
        }
        return recordName
    }
    
    
}
