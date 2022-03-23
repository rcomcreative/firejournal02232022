//
//  DeleteFromListOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/28/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class DeleteFromListOperation: FJOperation {//    MARK: -OPERATION PROPERTIES
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var ckrData:Data!
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
    var ckRecordID: CKRecord.ID!
    
    //    MARK: -init of the deleteICS214Personnel from cloud
    init(_ context: NSManagedObjectContext, dataObject: Data) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.ckRData = dataObject
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "DeleteFromListOperation"
        
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
        
        unarchiveTheRecord(data: ckRData)
        
        recordIDs.append(ckRecordID)
        
        deleteTheRecords()
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
    }
    
    func unarchiveTheRecord(data:Data) {
        do {
        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data)
        let ckRecord = CKRecord(coder: unarchiver)
            ckRecordID = ckRecord!.recordID
        } catch {
            print("error")
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
