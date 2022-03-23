//
//  NewFireJournalUserSendToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/10/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class NewFireJournalUserSendToCloudOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjUserA = [FireJournalUser]()
    var fjUser:FireJournalUser!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "NewFireJournalUserSendToCloudOperation"
         
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
                try fjUser = context.existingObject(with: objectID!) as? FireJournalUser
            } catch {
                let nserror = error as NSError
                print("The FireJournalUser New context was unable to find an Incident tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        if objectID == fjUser.objectID {
            let ckRecord = fjUser.newFireJournalUserForCloud(dateFormatter: dateFormatter)
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjUser.fjuCKR = data as NSObject
            self.fjUser.fjpUserBackedUp = true
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                if let error = error {
                    print("Error modify FireJournalUser record to private database \(error.localizedDescription)")
                }
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
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"New Fire Journal User Send to Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("New Fire Journal User Send to Cloud Operation")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            print("New Fire Journal User Send to Cloud Operation context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("New Fire Journal User Send to Cloud Operation has run and now is finished")
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
}
