//
//  NewICS214PersonnelOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/22/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class NewICS214PersonnelOperation: FJOperation {
    
    
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
    
    init(_ context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.objectID = objectID
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "NewICS214PersonnelOperation"
        
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
                try fjICS214Personnel = context.existingObject(with: objectID!) as? ICS214Personnel
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
        
        if objectID == fjICS214Personnel.objectID {
            let ics214 = fjICS214Personnel.ics214PersonnelInfo as! Set<ICS214Form>
            var ckRecordID: CKRecord.ID
            var ckRecord1: CKRecord!
            var ckRecord: CKRecord!
            for ics in ics214 {
                guard let  ckr = ics.ics214CKR as? Data else { return }
                do {
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: ckr)
                    ckRecord1 = CKRecord(coder: unarchiver)
                    ckRecordID = ckRecord1.recordID
                    ckRecord = fjICS214Personnel.newICS214PersonnelToTheCloud(ckRecordID:ckRecordID)
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    ckRecord.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.fjICS214Personnel.ics214PersonnelCKR = data as NSObject
                } catch {
                    print("couldn't unarchive file")
                }
            }
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                self.saveToCD()
            })
            
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
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"New ICS214 Personnel Operation"])
            }
            DispatchQueue.main.async {
                print("NewICS214PersonnelSendToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("NewICS214PersonnelSendToCloudOperation has run and now if finished")
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

}
