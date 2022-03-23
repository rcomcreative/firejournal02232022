//
//  AllModifiedICS214ToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/19/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class AllModifiedICS214ToCloudOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214A = [ICS214Form]()
    var fjICS214Records = [CKRecord]()
    var fjICS214:ICS214Form!
    var objectID:NSManagedObjectID? = nil
    var objectIDs = [NSManagedObjectID]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    
    init(_ context: NSManagedObjectContext, objectIDs: [NSManagedObjectID]) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectIDs = objectIDs
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
        
        if objectIDs.isEmpty {
            print("the modified object ids is empty MODIFIED ICS214")
        } else {
            for objectID in objectIDs {
                do {
                    try fjICS214 = context.existingObject(with: objectID) as? ICS214Form
                    if let ckr = fjICS214.ics214CKR {
                        guard let  archivedData = ckr as? Data else { return }
                        do {
                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                        let record = CKRecord(coder: unarchiver)
                        ckRecord = fjICS214.modifyICS214ForCloud(ckRecord: record!)
                        fjICS214Records.append(ckRecord)
                        } catch {
                            print("")
                        }
                    }
                } catch let error as NSError {
                    print("AllModifiedARCrossFormToCloudOperation line 66 Fetch Error: \(error.localizedDescription)")
                    return
                }
            }
            
            let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: fjICS214Records, recordIDsToDelete: nil)
            modifyCKOperation.savePolicy = .changedKeys
            modifyCKOperation.perRecordCompletionBlock = { record, error in
                if let error = error {
                    print("Error modify Incident record to private database \(error.localizedDescription)")
                }
                print(record)
            }
            modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                if let error = error {
                    print("Error modify Incident record to private database \(error.localizedDescription)")
                }
                if (savedRecords?.isEmpty)! {
                    print("savedRecords Modified Incidents is empty")
                } else {
                    for record in (savedRecords)! {
                        let guid = record["ics214Guid"] as! String
                        let ics214:ICS214Form = self.theICS214(guid: guid)
                        ics214.ics214BackedUp = true
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        record.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        ics214.ics214CKR = data as NSObject
                    }
                }
                self.saveToCD()
            }
            privateDatabase.add(modifyCKOperation)
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"All Modified User time To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("AllModifiedUserTimeOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("AllModifiedARCrossFormToCloudOperation line 125 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func theICS214(guid: String)->ICS214Form {
        var ics214:ICS214Form!
        let attribute = "ics214Guid"
        let entity = "ICS214Form"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            fjICS214A = try context.fetch(fetchRequest) as! [ICS214Form]
            ics214 = fjICS214A.last
        } catch let error as NSError {
            print("AllModifiedICS214ToCloudOperation line 150 Fetch Error: \(error.localizedDescription)")
        }
        return ics214
    }

}
