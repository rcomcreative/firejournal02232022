//
//  FireJournalUserSyncFromCloudOperation.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/30/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class FireJournalUserSyncFromCloudOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var fireJournalUser: FireJournalUser!
    var ckRecordA = [CKRecord]()
    var ckRecord: CKRecord!
    var fireJournalUserA = [FireJournalUser]()
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
            //            MARK: -get all Journal-
            /// will map through the existing FireJournalUser to see if this update is to modify or create new FireJournalUser
            getAllFireJournalUserEntries()
            var theGuid: String = ""
            for record in ckRecordA {
                if record["userGuid"] != "" || record["userGuid"] != nil {
                    let guid: String  = record["userGuid"] as? String ?? ""
                    let this = guid.components(separatedBy: ".").first
                    if this == "00" {
                            theGuid = record["userGuid"] as! String
                    if !fireJournalUserA.isEmpty {
                        let result = fireJournalUserA.filter { $0.userGuid == theGuid }
                        if result.isEmpty {
                            buildNewFireJournalUserFromCloud(record: record) {
                                saveToCD()
                            }
                        } else {
                            for form in result {
                                modifyFireJournalUserFromCloud(record: record, form: form) {
                                    saveToCD()
                                }
                            }
                        }
                    } else {
                        print("user doesn't exist")
                    }
                    }
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                              object: nil,
                              userInfo: ["recordEntity":TheEntities.fjResidence])
            }
            DispatchQueue.main.async {
                print("FireJournalUserSyncFromCloudOperation has run and now if finished")
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
    
    func getAllFireJournalUserEntries() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "fjpUserModDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if !fetched.isEmpty {
                fireJournalUserA = fetched
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    func buildNewFireJournalUserFromCloud(record: CKRecord, withCompletion completion: () -> Void ) {
        let theForm = FireJournalUser.init(context: bkgrdContext)
        theForm.modifyFireJournalUserFromCloud(ckRecord: record)
        completion()
    }
    
    func modifyFireJournalUserFromCloud(record: CKRecord, form: FireJournalUser, withCompletion completion: () -> Void ) {
        form.modifyFireJournalUserFromCloud(ckRecord: record)
        completion()
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FireJournalUserSyncFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("FireJournalUserSyncFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
}
