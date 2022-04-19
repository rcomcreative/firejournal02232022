//
//  ModifiedFireJournalUserSendToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/10/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ModifiedFireJournalUserSendToCloudOperation: FJOperation {
    
    let context: NSManagedObjectContext
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
    var ckRecord:CKRecord!
    var dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "ModifiedFireJournalUserSendToCloudOperation"
         
         guard isCancelled == false else {
             executing(false)
             finish(true)
             self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
             return
         }
        
        print("starting ModifiedFireJournalUserSendToCloudOperation")
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
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
        
        if let ckr = fjUser.fjuCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                 ckRecord = CKRecord(coder: unarchiver)
                let modifiedCKRecord = fjUser.modifyCloudFromFireJournalUser(ckRecord: ckRecord)
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        print("Error modify FireJournalUser record to private database \(error.localizedDescription)")
                    }
                    print(record)
                    self.fjUser.fjpUserBackedUp = true
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    record.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.fjUser.fjuCKR = data as NSObject
                }
                modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    self.saveToCD()
                }
                privateDatabase.add(modifyCKOperation)
            } catch {
                print("nothing here ")
            }
            
            
           
        } else {
            ckRecord = fjUser.newFireJournalUserForCloud(dateFormatter: dateFormatter)
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjUser.fjuCKR = data as NSObject
            self.fjUser.fjpUserBackedUp = true
            
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
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Modified FJUser Send to cloud Operation"])
            }
            DispatchQueue.main.async {
                print("Modified FIREJOURNALUSERToCloudOperation has run and now is finished")
                self.nc.post(name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),
                             object: nil,
                             userInfo: nil)
                
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.nc.removeObserver(self,name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The ModifiedFireJournalUserSendToCloudOperation context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("Modified FIREJOURNALUSERToCloudOperation has run and now is finished")
                self.nc.post(name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),
                             object: nil,
                             userInfo: nil)
                
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.nc.removeObserver(self,name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),object: nil)
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
