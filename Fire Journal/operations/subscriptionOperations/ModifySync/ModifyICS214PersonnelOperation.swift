//
//  ModifyICS214PersonnelOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/22/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ModifyICS214PersonnelOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214PersonnelA = [ICS214Personnel]()
    var fjICS214Personnel:ICS214Personnel!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    var modifyDelete: Bool = false
    var ckRData: Data!
    var ckRNoData: Bool = false
    var theGuid: String = ""
    var objectIDs = [NSManagedObjectID]()
    var theGuids = [String]()
    var ckRDatas = [Data]()
    
    init(_ context: NSManagedObjectContext, objectID: [NSManagedObjectID], modifyDelete: Bool, ckrData: [Data], noData: Bool, guid: [String]) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectIDs = objectID
        self.modifyDelete = modifyDelete
        self.ckRNoData = noData
        if self.modifyDelete {
            if ckRNoData {
                self.theGuids = guid
            } else {
                self.ckRDatas = ckrData
            }
        }
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
        
        if(objectID) != nil {
            do {
                try fjICS214Personnel = bkgrdContext.existingObject(with: objectID!) as? ICS214Personnel
            } catch {
                let nserror = error as NSError
                print("The context was unable to find an ICS214Personnel tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
        if let ckr = fjICS214Personnel.ics214PersonnelCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                ckRecord = CKRecord(coder: unarchiver)
                
                let modifiedCKRecord = fjICS214Personnel.modifyICS214PersonnelForCloud(ckRecord: ckRecord)
                modifyRecord(modifiedCKRecord:modifiedCKRecord)
            } catch {
                print("")
            }
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Modified ICS214 PERSONNEL Operation"])
            }
            DispatchQueue.main.async {
                print("ModifiedICS214PersonnelOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
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
        let attribute = "ics214PersonelGuid"
        let entity = "ICS214Personnel"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjICS214PersonnelA = try bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
            fjICS214Personnel = fjICS214PersonnelA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func modifyRecord(modifiedCKRecord: CKRecord) {
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            print(record)
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            record.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjICS214Personnel.ics214PersonnelCKR = data as NSObject
        }
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            self.saveToCD()
        }
        privateDatabase.add(modifyCKOperation)
    }
    
    private func deleteRecordFromCloud(modifiedCKRecord: CKRecord) {
        let id = modifiedCKRecord.recordID
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: nil, recordIDsToDelete: [id])
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            print(record)
        }
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            
            for id in self.objectIDs {
                do {
                    try self.fjICS214Personnel = self.bkgrdContext.existingObject(with: id) as? ICS214Personnel
                    self.bkgrdContext.delete(self.fjICS214Personnel)
                } catch {
                    let nserror = error as NSError
                    print("The context was unable to find an ICS214Personnel tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                    return
                }
            }
            
        }
        privateDatabase.add(modifyCKOperation)
    
    }
    
}
