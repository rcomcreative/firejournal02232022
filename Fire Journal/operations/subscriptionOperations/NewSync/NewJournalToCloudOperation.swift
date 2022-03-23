//
//  NewJournalToCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/9/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class NewJournalToCloudOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjJournalA = [Journal]()
    var fjJournal:Journal!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "NewJournalToCloudOperation"
         
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
        
        if(objectID) != nil {
            do {
                try fjJournal = context.existingObject(with: objectID!) as? Journal
            } catch {
                let nserror = error as NSError
                print("The NewJournalToCloudOperation context was unable to find an Journal tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        if objectID == fjJournal.objectID {
            let ckRecord = fjJournal.newJournalForCloud(dateFormatter: dateFormatter)
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fjJournal.fjJournalCKR = data as NSObject
            self.fjJournal.journalBackedUp = true
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                let ckRecord = record
                print("here is the jouranl CKRECORD \(String(describing: ckRecord))")
                self.saveToCD()
                if error != nil {
                    
                }
            })
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"New Journal To Cloud Operation"])
            }
            DispatchQueue.main.async {
                print("NewJournalToCloudOperation has run and now is finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The NewJournalToCloudOperation context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("NewJournalToCloudOperation has run and now is finished")
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
        let attribute = "fjpJGuidForReference"
        let entity = "Journal"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjJournalA = try context.fetch(fetchRequest) as! [Journal]
            fjJournal = fjJournalA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
}
