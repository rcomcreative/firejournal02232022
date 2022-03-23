//
//  ResidenceSyncFromCloudOperation.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/30/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class ResidenceSyncFromCloudOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var residence: Residence!
    var ckRecordA = [CKRecord]()
    var ckRecord: CKRecord!
    var residenceA = [Residence]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, records: [CKRecord] ) {
        self.context = context
        self.ckRecordA = records
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
        
        if !ckRecordA.isEmpty {
            //            MARK: -get all Residence-
            /// will map through the existing Residence to see if this update is to modify or create new Residence
            getAllResidence()
            var guid: String = ""
            var theResidence: String = ""
            for record in ckRecordA {
                guid = record["residenceGuid"] as! String
                theResidence = record["residence"] as! String
                if !residenceA.isEmpty {
                    let result = residenceA.filter { $0.residence == theResidence }
                    if result.isEmpty {
                        buildNewResidenceFromCloud(record: record) {
                            saveToCD()
                        }
                    } else {
                        for form in result {
                            if form.residenceGuid == guid {
                                modifyResidenceFromCloud(record: record, form: form) {
                                saveToCD()
                            }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                              object: nil,
                              userInfo: ["recordEntity":TheEntities.fjLocalPartners])
            }
            DispatchQueue.main.async {
                print("ResidenceSyncFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    func getAllResidence() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Residence" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "residenceGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "residenceCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [Residence]
            if !fetched.isEmpty {
                residenceA = fetched
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    func buildNewResidenceFromCloud(record: CKRecord, withCompletion completion: () -> Void ) {
        let theForm = Residence.init(context: bkgrdContext)
        theForm.modifyResidenceFromCloud(ckRecord: record)
        completion()
    }
    
    func modifyResidenceFromCloud(record: CKRecord, form: Residence, withCompletion completion: () -> Void ) {
        form.modifyResidenceFromCloud(ckRecord: record)
        completion()
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"ResidenceSyncFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("ResidenceSyncFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
}
