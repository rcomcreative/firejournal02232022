//
//  NationalPartnersSyndFromCloudOperation.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/30/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class NationalPartnersSyncFromCloudOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var nationalPartners: NationalPartners!
    var nationalPartnersA = [NationalPartners]()
    var ckRecordA = [CKRecord]()
    var ckRecord: CKRecord!
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
            //            MARK: -get all LocalPartners-
            /// will map through the existing LocalPartners to see if this update is to modify or create new LocalPartners
            getAllNationalPartners()
            var guid: String = ""
            var theNationalPartners: String = ""
            for record in ckRecordA {
                guid = record["partnerGuid"] as! String
                theNationalPartners = record["partnerName"] as! String
                if !nationalPartnersA.isEmpty {
                    let result = nationalPartnersA.filter { $0.partnerName == theNationalPartners }
                    if result.isEmpty {
                        buildNewNationalPartnersFromCloud(record: record) {
                            saveToCD()
                        }
                    } else {
                        for form in result {
                            if form.partnerGuid == guid {
                                modifyNationalPartnersFromCloud(record: record, form: form) {
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
                              userInfo: ["recordEntity":TheEntities.fjFINISHED])
            }
            DispatchQueue.main.async {
                print("NationalPartnersSyncFromCloudOperation has run and now if finished")
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
    
    func getAllNationalPartners() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NationalPartners" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "partnerGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "partnerCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [NationalPartners]
            if !fetched.isEmpty {
                nationalPartnersA = fetched
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    func buildNewNationalPartnersFromCloud(record: CKRecord, withCompletion completion: () -> Void ) {
        let theForm = NationalPartners.init(context: bkgrdContext)
        theForm.modifyNationalPartnersFromCloud(ckRecord: record)
        completion()
    }
    
    func modifyNationalPartnersFromCloud(record: CKRecord, form: NationalPartners, withCompletion completion: () -> Void ) {
        form.modifyNationalPartnersFromCloud(ckRecord: record)
        completion()
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NationalPartnersSyncFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("NationalPartnersSyncFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
}
