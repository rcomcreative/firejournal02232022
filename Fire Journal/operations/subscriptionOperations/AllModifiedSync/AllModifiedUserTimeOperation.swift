//
//  AllModifiedUserTimeOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/12/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class AllModifiedUserTimeOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjUserTimeA = [UserTime]()
    var fjUserTimeRecords = [CKRecord]()
    var fjUserTime:UserTime!
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
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        if objectIDs.isEmpty {
            print("the modified object ids is empty MODIFIED USERTIME")
        } else {
            for objectID in objectIDs {
                do {
                    try fjUserTime = context.existingObject(with: objectID) as? UserTime
                    if let ckr = fjUserTime.fjUserTimeCKR {
                        guard let  archivedData = ckr as? Data else { return }
                        do {
                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                        let record = CKRecord(coder: unarchiver)
                        ckRecord = fjUserTime.modifyUserTimeForCloud(ckRecord: record!)
                        fjUserTimeRecords.append(ckRecord)
                        } catch {
                            print("")
                        }
                    }
                } catch let error as NSError {
                    print("AllModifiedUserTimeToCloudOperation line 149 Fetch Error: \(error.localizedDescription)")
                    return
                }
            }
            
            let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: fjUserTimeRecords, recordIDsToDelete: nil)
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
                        let guid = record["userTimeGuid"] as! String
                        let userTime:UserTime = self.theUserTime(guid: guid)
                        userTime.userTimeBackup = true
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        record.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        userTime.fjUserTimeCKR = data as NSObject
                    }
                }
                self.saveToCD()
            }
            privateDatabase.add(modifyCKOperation)
        }
        
        guard isCancelled == false else {
            finish(true)
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"All Modified User Time Operation"])
            }
            DispatchQueue.main.async {
                print("AllModifiedUserTimeOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("AllModifiedUserTimeToCloudOperation line 149 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func theUserTime(guid: String)->UserTime {
        var userTime:UserTime!
        let attribute = "userTimeGuid"
        let entity = "UserTime"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            fjUserTimeA = try context.fetch(fetchRequest) as! [UserTime]
            userTime = fjUserTimeA.last
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return userTime
    }
}
