//
//  ICS214BackedUpOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class ICS214BackedUpOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    
    var ics214FormA = [ICS214Form]()
    
    var ckRecordA = [CKRecord]()
    var ckRecord:CKRecord!
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    var thread:Thread!
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, database: CKDatabase ) {
        self.context = context
        self.privateDatabase = database
        super.init()
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
    
    override func main() {
        
        guard isCancelled == false else {
            DispatchQueue.main.async {
                print("calling the check ARCrossForm backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKARCFORMBACKEDUP ) ,object:nil )
            }
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
        
        checkICS214Backup()
        
        guard isCancelled == false else {
            DispatchQueue.main.async {
                print("calling the check ARCrossForm backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKARCFORMBACKEDUP ) ,object:nil )
            }
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
    }
    
    func checkICS214Backup() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "ics214BackedUp == %@", NSNumber(value: false ))
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214ModDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Form]
            if !fetched.isEmpty {
                 ics214FormA = fetched
            }
        } catch let error as NSError {
            print("ics214 Search Fetch failed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"CheckICS214BackupOperation"])
            }

        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }

}
