//
//  NewUserFDResourcesOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/26/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class NewUserFDResourcesOperation: FJOperation {
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
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
//    newMyFDResourcesForCloud()
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "NewUserFDResourcesOperation"
         
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
                try fjUserFDResources = context.existingObject(with: objectID!) as? UserFDResources
            } catch {
                let nserror = error as NSError
                print("The NewUserFDResourcesOperation context was unable to find an UserFDResource tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        }  else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        if objectID == fjUserFDResources.objectID {
            let ckRecord = fjUserFDResources.newMyFDResourcesForCloud()
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjUserFDResources.fdResourceCKR = data as NSObject
            self.fjUserFDResources.fdResourceBackup = true
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                guard error == nil else {
                    if let ckerror = error as? CKError {
                        print("here is your error for this block fetchDatabaseChangesCompletionBlock \(ckerror.localizedDescription)")
                    }
                    return
                }
                print("here is the record \(String(describing: record))")
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
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"New User FD Resource Operation"])
            }
            DispatchQueue.main.async {
                print("NewUserFDResourcesOperation has run and now is finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The NewUserFDResourcesOperation context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("NewUserFDResourcesOperation has run and now is finished")
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
