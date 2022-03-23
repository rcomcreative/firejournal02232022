//
//  AllModifiedARCrossFormToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/19/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class AllModifiedARCrossFormToCloudOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjARCrossFormA = [ARCrossForm]()
    var fjARCrossFormRecords = [CKRecord]()
    var fjARCrossForm:ARCrossForm!
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
            print("the modified object ids is empty MODIFIED ARCForm")
        } else {
            for objectID in objectIDs {
                do {
                    try fjARCrossForm = context.existingObject(with: objectID) as? ARCrossForm
                    if let ckr = fjARCrossForm.arcFormCKR {
                        guard let archivedData = ckr as? Data else { return  }
                        var record: CKRecord!
                        do {
                            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                            record  = CKRecord(coder: unarchiver)
                            ckRecord = fjARCrossForm.modifyARCrossFormForCloud(ckRecord: record)
                            fjARCrossFormRecords.append(ckRecord)
                        } catch {
                            print("couldn't unarchive file")
                        }
                    }
                } catch let error as NSError {
                    print("AllModifiedARCrossFormToCloudOperation line 66 Fetch Error: \(error.localizedDescription)")
                    return
                }
            }
            
            let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: fjARCrossFormRecords, recordIDsToDelete: nil)
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
                    print("savedRecords Modified ARCForms is empty")
                } else {
                    for record in (savedRecords)! {
                        let guid = record["arcFormGuid"] as! String
                        let arcForm:ARCrossForm = self.theARCrossForm(guid: guid)
                        arcForm.arcBackup = true
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        record.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        arcForm.arcFormCKR = data as NSObject
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"All Modified ARCrossForm To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("AllModifiedARCrossFormToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("AllModifiedARCrossFormToCloudOperation line 124 Fetch Error: \(error.localizedDescription)")        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func theARCrossForm(guid: String)->ARCrossForm {
        var arcForm:ARCrossForm!
        let attribute = "arcFormGuid"
        let entity = "ARCrossForm"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            fjARCrossFormA = try context.fetch(fetchRequest) as! [ARCrossForm]
            arcForm = fjARCrossFormA.last
        } catch let error as NSError {
            print("AllModifiedARCrossFormToCloudOperation line 149 Fetch Error: \(error.localizedDescription)")
        }
        return arcForm
    }

}
