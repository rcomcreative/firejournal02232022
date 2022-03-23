//
//  ARCrossFormBackedUpOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class ARCrossFormBackedUpOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    
    var arcFormA = [ARCrossForm]()
    
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
                print("calling the check UserTime backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKUSERTIMEBACKEDUP ) ,object:nil )
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
        
        checkARCFormBackup()
        
        guard isCancelled == false else {
            DispatchQueue.main.async {
                print("calling the check UserTime backup Operation")
                self.nc.post(name: Notification.Name(rawValue: FJkCHECKUSERTIMEBACKEDUP ) ,object:nil )
            }
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
    }
    
    func checkARCFormBackup() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "arcBackup == %@", NSNumber(value: false ))
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [ARCrossForm]
            if !fetched.isEmpty {
                 arcFormA = fetched
            }
        } catch let error as NSError {
            print("arcForm Search Fetch failed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"CheckIARCForm4BackupOperation"])
            }

        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }

}
