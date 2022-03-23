//
//  DeleteICS214PersonnelOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/5/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class DeleteICS214PersonnelOperation: FJOperation {
    //    MARK: -OPERATION PROPERTIES
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
    var thePGuid: String = ""
    
    //    MARK: -init of the deleteICS214Personnel from cloud
    init(_ context: NSManagedObjectContext, modifyDelete: Bool, ckrData: Data, noData: Bool, guid: String, pGuid: String) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.modifyDelete = modifyDelete
        self.ckRNoData = noData
        if self.modifyDelete {
            if ckRNoData {
                self.theGuid = guid
                self.thePGuid = pGuid
            } else {
                self.ckRData = ckrData
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
        
        if modifyDelete {
            if ckRNoData {
                let predicate = NSPredicate(format: "TRUEPREDICATE")
                let predicate2 = NSPredicate(format: "ics214Guid == %@",theGuid)
                let predicate3 = NSPredicate(format: "ics214PersonelGuid == %@",thePGuid)
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2,predicate3])
                let sort = NSSortDescriptor(key: "createdAt", ascending: false)
                let query = CKQuery.init(recordType: "ICS214Personnel", predicate: predicateCan)
                query.sortDescriptors = [sort]
                let operation = CKQueryOperation(query: query)
                
                operation.recordFetchedBlock = { record in
                    self.deleteRecordFromCloud(modifiedCKRecord: record)
                }
            } else {
               do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: ckRData)
                ckRecord = CKRecord(coder: unarchiver)
                deleteRecordFromCloud(modifiedCKRecord: ckRecord)
               } catch {
                    print("")
                }
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Delete ICS214 Personnel Operation"])
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
            let count = try context.count(for:fetchRequest)
            fjICS214PersonnelA = try context.fetch(fetchRequest) as! [ICS214Personnel]
            fjICS214Personnel = fjICS214PersonnelA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    //    MARK: -DELETE THE CKRECORD
    //    MARK: -EITHER FROM GUID SEARCH OR FROM CKRecord Data
    private func deleteRecordFromCloud(modifiedCKRecord: CKRecord) {
        let id = modifiedCKRecord.recordID
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: nil, recordIDsToDelete: [id])
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
        }
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            print("delete successful")
        }
        privateDatabase.add(modifyCKOperation)
    }
    
}
