//
//  AllModifiedJournalsToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/9/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class AllModifiedJournalsToCloudOperation: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjJournalA = [Journal]()
    var fjJournalRecords = [CKRecord]()
    var fjJournal:Journal!
    var objectID:NSManagedObjectID? = nil
    var objectIDs = [NSManagedObjectID]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    
    init(_ context: NSManagedObjectContext, objectIDs: [NSManagedObjectID]) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectIDs = objectIDs
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "AllModifiedJournalsToCloudOperation"
         
         guard isCancelled == false else {
             executing(false)
             finish(true)
             self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
             return
         }
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        if objectIDs.isEmpty {
            print("the modified object ids is empty MODIFIED JOURNALS")
        } else {
            for objectID in objectIDs {
                do {
                    try fjJournal = context.existingObject(with: objectID) as? Journal
                    if let ckr = fjJournal.fjJournalCKR {
                        guard let  archivedData = ckr as? Data else { return }
                        do {
                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                        let record = CKRecord(coder: unarchiver)
//                        ckRecord = fjJournal.modifyJournalForCloud(ckRecord: record!)
                            ckRecord = fjJournal.modifiedJournalToCloudKit(ckRecord: record)
                        fjJournalRecords.append(ckRecord)
                        } catch {
                            print("")
                        }
                    }
                } catch let error as NSError {
                    print("AllModifiedJournalsToCloudOperation line 64 Fetch Error: \(error.localizedDescription)")
                    return
                }
            }
            
            let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: fjJournalRecords, recordIDsToDelete: nil)
            modifyCKOperation.savePolicy = .changedKeys
            modifyCKOperation.perRecordCompletionBlock = { record, error in
                if let error = error {
                    print("Error modify Incident record to private database \(error.localizedDescription)")
                }
                print(record)
            }
            modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                if let error = error {
                    print("Error modify Incident record to private database \(error.localizedDescription)")
                }
                if (savedRecords?.isEmpty)! {
                    print("savedRecords Modified Incidents is empty")
                } else {
                    for record in (savedRecords)! {
                        let guid = record["fjpJGuidForReference"] as! String
                        let journal:Journal = self.theJournal(guid: guid)
                        journal.journalBackedUp = true
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        record.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        journal.fjJournalCKR = data as NSObject
                        journal.journalModDate = Date()
                        journal.journalBackedUp = true
                    }
                }
                self.saveToCD()
            }
            privateDatabase.add(modifyCKOperation)
        }
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"All Modified Journals To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("AllModifiedJournalsToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("AllModifiedJournalsToCloudOperation line 1425 Fetch Error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                print("AllModifiedJournalsToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func theCount(guid: String)->Int {
        let attribute = "fjpJGuidForReference"
        let entity = "Journal"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjJournalA = try context.fetch(fetchRequest) as! [Journal]
            fjJournal = fjJournalA.last
            return count
        } catch let error as NSError {
            print("AllModifiedJournalsToCloudOperation line 149 Fetch Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func theJournal(guid: String)->Journal {
        var journal:Journal!
        let attribute = "fjpJGuidForReference"
        let entity = "Journal"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            fjJournalA = try context.fetch(fetchRequest) as! [Journal]
            journal = fjJournalA.last
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return journal
    }
}
