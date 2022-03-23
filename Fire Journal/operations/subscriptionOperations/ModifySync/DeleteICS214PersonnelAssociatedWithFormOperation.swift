//
//  DeleteICS214PersonnelAssociatedWithFormOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/6/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class DeleteICS214PersonnelAssociatedWithFormOperation: FJOperation {
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
    var records = [CKRecord]()
    var recordIDs = [CKRecord.ID]()
    
    //    MARK: -init of the deleteICS214Personnel from cloud
    init(_ context: NSManagedObjectContext, guid: String) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.theGuid = guid
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "DeleteICS214PersonnelAssociatedWithFormOperation"
        
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
        
        fetchRecords()
        
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Delete ICS214 Personnel Associated With Form Operation"])
            }
            DispatchQueue.main.async {
                print("DeleteICS214PersonnelAssociatedWithFormOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("DeleteICS214PersonnelAssociatedWithFormOperation The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("DeleteICS214PersonnelAssociatedWithFormOperation has run and now if finished")
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
    
    private func fetchRecords() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "ics214Guid == %@",theGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        let query = CKQuery(recordType: "ICS214Personnel", predicate: predicateCan)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = { record in
            self.records.append(record)
            print("\(record)")
        }
        
        self.privateDatabase.add(queryOperation)
        
        queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            if error != nil {
                print(error!)
            }
            print("here is the count of records \(self.records.count)")
            for record in self.records {
                self.recordIDs.append(record.recordID)
            }
           self.deleteTheRecords()
        }
        
        func setupAndAdd(operation: CKQueryOperation) {
            self.privateDatabase.add(operation)
        }
    }
    
    func deleteTheRecords() {
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: nil, recordIDsToDelete: self.recordIDs)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                print("DeleteICS214PersonnelAssociatedWithFormOperation has run and now if finished \(String(describing: deletedRecords))")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        privateDatabase.add(modifyCKOperation)
    }
    
   
}
