    //
    //  FJStatusSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJStatusSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var statusA = [Status]()
    var ckRecordA = [CKRecord]()
    var theStatus: Status!
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        super.init()
    }
    
    deinit {
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
    }
    
    override func main() {
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector: #selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
        executing(true)
        let count = theCounter()
        
        if count == 0 {
            chooseNewWithGuid {
                saveToCD()
            }
        } else {
            chooseNewOrUpdate {
                saveToCD()
            }
        }
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        if let record = ckRecordA.last {
            newStatusFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guidString"] as? String {
                let result = statusA.filter { $0.guidString == guid }
                if result.isEmpty {
                    newStatusFromCloud(record: record)
                } else {
                    theStatus = result.last
                    updateTheStatus(record: record)
                }
            }
        }
        completion()
    }
    
    func updateTheStatus(record: CKRecord) {
        
        if let agreement = record["agreement"] as? Bool {
            theStatus.agreement = agreement
        }
        
        if let theDate = record["agreementDate"] as? Date {
            theStatus.agreementDate = theDate
        }
        
        if let guid = record["guidString"] as? String {
            theStatus.guidString = guid
        } else {
            theStatus.guidString = ""
        }
        
        if let shiftDate = record["shiftDate"] as? Date {
            theStatus.shiftDate = shiftDate
        }
        
        if theStatus.statusReference == nil {
            
            let theShiftReference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theShiftReference, requiringSecureCoding: true)
                self.theStatus.statusReference = data as NSObject
                
            } catch {
                print("self.theStatus.statusReference to data failed line 514 Incident+Custom")
            }
            
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.theStatus.statusCKR = data as NSObject
        
    }
    
    func newStatusFromCloud(record: CKRecord) {
        
        theStatus = Status(context: bkgrdContext)
        if let agreement = record["agreement"] as? Bool {
            theStatus.agreement = agreement
        }
        
        if let theDate = record["agreementDate"] as? Date {
            theStatus.agreementDate = theDate
        }
        
        if let guid = record["guidString"] as? String {
            theStatus.guidString = guid
        } else {
            theStatus.guidString = ""
        }
        
        if let shiftDate = record["shiftDate"] as? Date {
            theStatus.shiftDate = shiftDate
        }
        
        let theShiftReference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theShiftReference, requiringSecureCoding: true)
            self.theStatus.statusReference = data as NSObject
            
        } catch {
            print("promotionJournalReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.theStatus.statusCKR = data as NSObject
        
    }
    
    fileprivate func saveToCD() {
        
            do {
                try self.bkgrdContext.save()
                
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJStatusSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjPromotionJournal])
                    self.executing(false)
                    self.finish(true)
                }
            } catch let error as NSError {
                let nserror = error
                print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            }
       
        
    }
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Status" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            statusA = try bkgrdContext.fetch(fetchRequest) as! [Status]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
}
