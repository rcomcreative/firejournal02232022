//
//  ModifyICS214ActivityLogOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/22/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ModifyICS214ActivityLogOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214ActivityLogA = [ICS214ActivityLog]()
    var fjICS214ActivityLog:ICS214ActivityLog!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "ModifyICS214ActivityLogOperation"
        
        //    MARK: -CHECK FOR OPERATION CANCEL
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        //    MARK: -BUILD BACKGROUND CONTEXT-
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        //    MARK: -CHECK OBJECTID-
        if(objectID) != nil {
            do {
                try fjICS214ActivityLog = bkgrdContext.existingObject(with: objectID!) as? ICS214ActivityLog
            } catch {
                let nserror = error as NSError
                print("The context was unable to find an IModifyUserAttendee tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        //        MARK: -ARCHIVED CKR-
        if let ckr = fjICS214ActivityLog.ics214ActivityCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                ckRecord = CKRecord(coder: unarchiver)
                let modifiedCKRecord = fjICS214ActivityLog.modifyICS214ALogForCloud(ckRecord: ckRecord)
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    print(record)
                    self.fjICS214ActivityLog.ics214ActivityBackedUp = true
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    record.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.fjICS214ActivityLog.ics214ActivityCKR = data as NSObject
                }
                modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    self.saveToCD()
                }
                privateDatabase.add(modifyCKOperation)
            } catch {
                print("here is n error from try \(error)")
            }
        }
        
        //    MARK: -CANCEL-
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    //    MARK: -CHECK THREAD-
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -core data
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"ModifyICS214ActivityLogOperation To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("ModifyICS214ActivityLogOperation has run and now is finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("ModifyICS214ActivityLogOperation has run and now is finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
}
