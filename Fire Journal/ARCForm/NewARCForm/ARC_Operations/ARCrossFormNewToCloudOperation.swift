//
//  ARCrossFormNewToCloudOperation.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/25/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class ARCrossFormNewToCloudOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var arcrossForm: ARCrossForm!
    var ckRecordA = [CKRecord]()
    var fjuCKRecord: CKRecord!
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    var jObjectID: NSManagedObjectID!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let dateFormatter = DateFormatter()
    var fetched:Array<Any>!
    
    init(_ context: NSManagedObjectContext,database: CKDatabase, objectID: NSManagedObjectID ) {
        self.context = context
        self.privateDatabase = database
        self.objectID = objectID
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
        
        if objectID != nil {
            do {
                try arcrossForm = context.existingObject(with: objectID!) as? ARCrossForm
            } catch {
                let nserror = error as NSError
                print("The context was unable to find an Incident tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
                return
            }
        } else {
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        if objectID == arcrossForm.objectID {
            let ckRecord = arcrossForm.newARCrossFormForCloud(dateFormatter: dateFormatter)
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            arcrossForm.arcFormCKR = data as NSObject
            arcrossForm.arcBackup = true
            
            privateDatabase.save(ckRecord, completionHandler: { record, error in
                if error != nil {
                    print("ARCrossFormNewToCloudOperation failed with error" + (error?.localizedDescription)!)
                    return
                } else {
                self.saveToCD()
                }
            })

        }
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"ARCrossFormNewToCloudOperation"])
            }
            DispatchQueue.main.async {
                print("ARCrossFormNewToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            let jguid =  arcrossForm.arcFormCampaignGuid ?? ""
            getTheLastJournalSaved(guid: jguid)
            if let object = self.jObjectID {
                if arcrossForm.arcMaster {
                DispatchQueue.main.async {
                    self.nc.post(name: Notification.Name(rawValue: FJkNEWJOURNALForCloudKit), object: nil, userInfo: ["objectID": object])
                }
                }  else {
                   DispatchQueue.main.async {
                            self.nc.post(name: Notification.Name(rawValue: FJkMODIFIEDJOURNALForCloudKit), object: nil, userInfo: ["objectID": object])
                        }
                }
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("ARCrossFormNewToCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
    private func getTheLastJournalSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "arcFormMasterGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [Journal]
            if !fetched.isEmpty {
                let journal = self.fetched.last as! Journal
                self.jObjectID = journal.objectID
            }
        } catch let error as NSError {
            print("ARCrossFormNewToCloudOperation line 149 Fetch Error: \(error.localizedDescription)")
        }
    }
    
}
