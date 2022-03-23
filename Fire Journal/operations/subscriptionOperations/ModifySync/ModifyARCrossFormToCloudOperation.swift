//
//  ModifyARCrossFormToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/19/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ModifyARCrossFormToCloudOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjARCrossFormA = [ARCrossForm]()
    var fjARCrossForm:ARCrossForm!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "ModifyARCrossFormToCloudOperation"
        
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
        
        if(objectID) != nil {
            do {
                try fjARCrossForm = context.existingObject(with: objectID!) as? ARCrossForm
            } catch let error as NSError {
                print("ModifyARCrossFormToCloudOperation line 53 Fetch Error: \(error.localizedDescription)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        if let ckr = fjARCrossForm.arcFormCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                ckRecord = CKRecord(coder: unarchiver)
                let modifiedCKRecord = fjARCrossForm.modifyARCrossFormForCloud(ckRecord: ckRecord)
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        print("Error modify ARCCROSSFORM record to private database \(error.localizedDescription)")
                    }
                    print(record)
                    self.fjARCrossForm.arcBackup = true
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    record.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.fjARCrossForm.arcFormCKR = data as NSObject
                }
                modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if let error = error {
                        print("Error modify arcrossForm record to private database \(error.localizedDescription)")
                    }
                    self.saveToCD()
                }
                privateDatabase.add(modifyCKOperation)
            } catch {
                print("")
            }
            
            
        } else {
//            let ckRecord = fjARCrossForm.newARCrossFormToTheCloud()
            let ckRecord = fjARCrossForm.newARCrossFormForCloud(dateFormatter: dateFormatter)
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjARCrossForm.arcFormCKR = data as NSObject
            self.fjARCrossForm.arcBackup = true
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                print(ckRecord)
                self.saveToCD()
            })
        }
        
        guard isCancelled == false else {
            executing(false)
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Modified ARCross Form To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("ModifiedARCFormToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("ModifyARCrossFormToCloudOperation line 129 Fetch Error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                print("ModifiedARCFormToCloudOperation has run and now if finished")
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
        let attribute = "arcFormGuid"
        let entity = "ARCrossForm"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjARCrossFormA = try context.fetch(fetchRequest) as! [ARCrossForm]
            fjARCrossForm = fjARCrossFormA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
}
