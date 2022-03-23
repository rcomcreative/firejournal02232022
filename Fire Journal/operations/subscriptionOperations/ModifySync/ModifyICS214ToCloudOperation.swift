//
//  ModifyICS214ToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/19/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ModifyICS214ToCloudOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214A = [ICS214Form]()
    var fjICS214:ICS214Form!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    var arrayOfIds = [CKRecord.ID]()
    var arrayOfRecords = [CKRecord]()
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "ModifyICS214ToCloudOperation"
        
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
                try fjICS214 = bkgrdContext.existingObject(with: objectID!) as? ICS214Form
            } catch {
                let nserror = error as NSError
                print("The ICS214Form context was unable to find an Incident tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            print("ModifyICS214ToCloudOperation has stopped as there was no objectID")
            return
        }
        
        if let ckr = fjICS214.ics214CKR {
            recordGuid = fjICS214.ics214Guid!
            guard let  archivedData = ckr as? Data else { return }
            do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                ckRecord = CKRecord(coder: unarchiver)
                let modifiedCKRecord = fjICS214.modifyICS214ForCloud(ckRecord: ckRecord)
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [modifiedCKRecord], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        print("Error modify ics214 record to private database \(error.localizedDescription)")
                    }
                    print(record)
                    self.fjICS214.ics214BackedUp = true
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    record.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.fjICS214.ics214CKR = data as NSObject
                    self.saveToCD()
                    self.cleanUpPersonnel()
                }
                modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if let error = error {
                        print("Error modify ics214 record to private database \(error.localizedDescription)")
                    }
                    self.saveToCD()
                    self.cleanUpPersonnel()
                }
                privateDatabase.add(modifyCKOperation)
            } catch {
                print("hey")
            }
            
           
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Modified User Time To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("ModifiedUserTimeToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")

            DispatchQueue.main.async {
                print("ModifiedUserTimeToCloudOperation has run and now if finished")
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
        let attribute = "ics214Guid"
        let entity = "ICS214Form"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjICS214A = try context.fetch(fetchRequest) as! [ICS214Form]
            fjICS214 = fjICS214A.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func clearPersonnelIDs(theGuid: String)->[CKRecord.ID] {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "ics214Guid == %@",theGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        let query = CKQuery.init(recordType: "ICS214Personnel", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { record in
            let id = record.recordID
            self.arrayOfIds.append(id)
        }
        return arrayOfIds
    }
    
    private func getPersonnel(theGuid: String)->[CKRecord] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel")
        fetchRequest.predicate = NSPredicate(format: "ics214Guid == %@", theGuid)
        do {
            let fetchedPersonnel = try bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
            for personnel in fetchedPersonnel {
                if personnel.ics214PersonnelCKR != nil {
                    guard let ckr = personnel.ics214PersonnelCKR as? Data else { return [] }
                do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: ckr)
                let ckRecord = CKRecord(coder: unarchiver)
                    let id = (ckRecord?.recordID)!
                    if arrayOfIds.contains(id) {
                        arrayOfIds.remove(object: id)
                    }
                    arrayOfRecords.append(ckRecord!)
                } catch {
                    print("hey")
                    }
                }
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "TeamTVC contactsSaveBTapped()2 fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            print(errorMessage)
        }
        return arrayOfRecords
    }
    
    private func cleanUpPersonnel() {
        _ = clearPersonnelIDs(theGuid: recordGuid)
        _ = getPersonnel(theGuid: recordGuid)
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: arrayOfRecords, recordIDsToDelete: arrayOfIds)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            print("here is personnel saved \(record)")
        }
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            print("here is savedRecords \(String(describing: savedRecords)) and deletedRecords \(String(describing: deletedRecords))")
        }
        privateDatabase.add(modifyCKOperation)
    }
    
    
}
