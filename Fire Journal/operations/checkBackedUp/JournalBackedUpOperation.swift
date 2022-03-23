//
//  JournalBackedUpOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class JournalBackedUpOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    
    var journalA = [Journal]()
    
    var ckRecordA = [CKRecord]()
    var ckRecord:CKRecord!
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    var thread:Thread!
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, database: CKDatabase ) {
        self.context = context
        self.privateDatabase = database
        super.init()
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
    
    override func main() {
        
        guard isCancelled == false else {
            DispatchQueue.main.async {
                print("calling the check INCIDENT backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKINCIDENTBACKEDUP ) ,object:nil )
            }
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
        
        checkJournalBackup()
        if journalA.isEmpty {
            DispatchQueue.main.async {
                print("calling the check INCIDENTbackup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKINCIDENTBACKEDUP ) ,object:nil )
            }
            DispatchQueue.main.async {
                self.executing(false)
                self.finish(true)
                print("CheckJournalBackupOperation is done save")
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } else {
            for journal in journalA {
                if let ckr = journal.fjJournalCKR {
                    guard let  archivedData = ckr as? Data else { return }
                    do {
                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                        ckRecord = CKRecord(coder: unarchiver)
                        let modifiedCKRecord = journal.modifiedJournalToCloudKit(ckRecord: ckRecord)
                        
                        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
                        modifyCKOperation.savePolicy = .changedKeys
                        modifyCKOperation.perRecordCompletionBlock = { record, error in
                            if let error = error {
                                print("Error CheckJournalBackupOperation \(error.localizedDescription)")
                            }
                            journal.journalBackedUp = true
                            let coder = NSKeyedArchiver(requiringSecureCoding: true)
                            record.encodeSystemFields(with: coder)
                            let data = coder.encodedData
                            journal.fjJournalCKR = data as NSObject
                        }
                        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                            if let error = error {
                                print("Error modify JOURNAL record to private database \(error.localizedDescription)")
                            }
                            self.saveToCD()
                        }
                        privateDatabase.add(modifyCKOperation)
                    } catch {
                        print("here is the error")
                    }
                } else {
                    let ckRecord = journal.newJournalForCloud(dateFormatter: dateFormatter)
                    
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    ckRecord.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    journal.fjJournalCKR = data as NSObject
                    journal.journalBackedUp = true
                    
                    privateDatabase.save(ckRecord, completionHandler: { record, error in
                        self.saveToCD()
                    })
                }
            }
            
            
            DispatchQueue.main.async {
                print("calling the INCIDENT check backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKINCIDENTBACKEDUP ) ,object:nil )
            }
            DispatchQueue.main.async {
                print("CheckJournalBackupOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        
        guard isCancelled == false else {
            DispatchQueue.main.async {
                print("calling the check INCIDENT backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKINCIDENTBACKEDUP ) ,object:nil )
            }
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    func checkJournalBackup() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "journalBackedUp == %@", NSNumber(value: false ))
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [Journal]
            if !fetched.isEmpty {
                journalA = fetched
            }
        } catch let error as NSError {
            print("Journal Search Fetch failed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"CheckJournalBackupOperation"])
            }

        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }

}
