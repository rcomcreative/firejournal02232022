//
//  ModifyUserFDResourcesOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/26/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ModifyUserFDResourcesOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjUserFDResourcesA = [UserFDResources]()
    var fjUserFDResources:UserFDResources!
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
         operation = "ModifyUserFDResourcesOperation"
         
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
        
        if(objectID) != nil {
            do {
                try fjUserFDResources = bkgrdContext.existingObject(with: objectID!) as? UserFDResources
            } catch {
                let nserror = error as NSError
                print("The context was unable to find an UserFDResources tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        if let ckr = fjUserFDResources.fdResourceCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                ckRecord = CKRecord(coder: unarchiver)
                let modifiedCKRecord = fjUserFDResources.modifyMyFDResourcesForCloud(ckRecord:ckRecord)
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    print(record)
                    self.fjUserFDResources.fdResourceBackup = true
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    record.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.fjUserFDResources.fdResourceCKR = data as NSObject
                }
                modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    self.saveToCD()
                }
                privateDatabase.add(modifyCKOperation)
           } catch {
             print("")
            }
        }
        
        if fjUserFDResources.fdResourceCKR == nil {
            
            let ckRecord = fjUserFDResources.newMyFDResourcesForCloud()
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjUserFDResources.fdResourceCKR = data as NSObject
            self.fjUserFDResources.fdResourceBackup = true
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                
                self.saveToCD()
            })
        }
        
         guard isCancelled == false else {
                    executing(false)
                    finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    return
        }
        
    }
    
    func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"ModifyUserFDResourcesOperation"])
            }
            DispatchQueue.main.async {
                print("ModifyUserFDResourcesOperation has run and now is finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("ModifyUserFDResourcesOperation has run and now is finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
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
}
