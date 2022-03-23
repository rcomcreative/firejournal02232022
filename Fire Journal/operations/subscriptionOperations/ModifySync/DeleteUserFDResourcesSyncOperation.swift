//
//  DeleteUserFDResourcesSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/26/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class DeleteUserFDResourcesSyncOperation: FJOperation {
    //    MARK: -OPERATION PROPERTIES
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
    var modifyDelete: Bool = false
    var ckRData: Data!
    var ckRNoData: Bool = false
    var theGuid: String = ""
    var thePGuid: String = ""
    var ckRecordName = ""
    var records = [CKRecord]()
    var recordIDs = [CKRecord.ID]()
    
    //    MARK: -init of the deleteICS214Personnel from cloud
    init(_ context: NSManagedObjectContext, modifyDelete: Bool, guid: String) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.modifyDelete = modifyDelete
        self.theGuid = guid
       
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "DeleteUserFDResourcesSyncOperation"
         
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
        
        if theGuid != "" {
            fetchRecords()
        } else {
            DispatchQueue.main.async {
                print("DeleteUserFDResourcesSyncOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
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
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func fetchRecords() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "fdResourceGuid == %@",theGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        let query = CKQuery(recordType: "UserFDResources", predicate: predicateCan)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = { record in
            self.records.append(record)
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
            
            if self.recordIDs.count>0 {
                self.deleteTheRecords()
            } else {
                DispatchQueue.main.async {
                    print("DeleteUserFDResourcesSyncOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
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
                print("Error modify DeleteUserFDResourcesSyncOperation record to private database \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                print("DeleteUserFDResourcesSyncOperation has run and now if finished \(String(describing: deletedRecords))")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        privateDatabase.add(modifyCKOperation)
    }
}
