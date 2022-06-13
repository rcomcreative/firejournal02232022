//
//  FJUserAttendeesFromCloudSyncingOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 1/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FJUserAttendeesFromCloudSyncingOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjUserAttendeesA = [UserAttendees]()
    var fjUserAttendees: UserAttendees!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    
    var theUser: FireJournalUser!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    deinit {
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJUserAttendeesFromCloudSyncingOperation"
        
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
            finish(true)
            return
        }
        
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjUserAttendeesA = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
//            print("here is new attendee")
                    newFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["attendeeGuid"] {
                let result = fjUserAttendeesA.filter { $0.attendeeGuid == guid }
                if result.isEmpty {
//                    print("here is new attendee")
                    newFromCloud(record: record)
                } else {
//                    print("here is modified attendee")
                    fjUserAttendees = result.last
                    updateAttendeeFromCloud(fjUserAttendeeRecord: record, fjUserAttendees: fjUserAttendees)
                }
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    func updateAttendeeFromCloud(fjUserAttendeeRecord: CKRecord, fjUserAttendees: UserAttendees) {
        
        if let attendeeGuid = fjUserAttendeeRecord["attendeeGuid"] as? String {
            fjUserAttendees.attendeeGuid = attendeeGuid
        }
        if let attendee = fjUserAttendeeRecord["attendee"] as? String {
            fjUserAttendees.attendee = attendee
        }
        if let attendeeEmail = fjUserAttendeeRecord["attendeeEmail"] as? String {
            fjUserAttendees.attendeeEmail = attendeeEmail
        }
        if let attendeePhone = fjUserAttendeeRecord["attendeePhone"] as? String {
            fjUserAttendees.attendeePhone = attendeePhone
        }
        if let attendeeHomeAgency = fjUserAttendeeRecord["attendeeHomeAgency"] as? String {
            fjUserAttendees.attendeeHomeAgency = attendeeHomeAgency
        }
        if let attendeeICSPosition = fjUserAttendeeRecord["attendeeICSPosition"] as? String {
            fjUserAttendees.attendeeICSPosition = attendeeICSPosition
        }
        if let attendeeModDate = fjUserAttendeeRecord["attendeeModDate"] as? Date {
            fjUserAttendees.attendeeModDate = attendeeModDate
        }
        
        if let staffGuid = fjUserAttendeeRecord["staffGuid"] as? String {
            fjUserAttendees.staffGuid = UUID(uuidString: staffGuid)
        }
        
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            fjUserAttendeeRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            fjUserAttendees.fjUserAttendeeCKR = data as NSObject
        
    }
    
    private func newFromCloud(record: CKRecord)->Void {
        
        let fjUserAttendeeRecord = record
        
        let fjUserAttendees = UserAttendees(context: bkgrdContext)
        if let attendeeGuid = fjUserAttendeeRecord["attendeeGuid"] as? String {
            fjUserAttendees.attendeeGuid = attendeeGuid
        }
        if let attendee = fjUserAttendeeRecord["attendee"] as? String {
            fjUserAttendees.attendee = attendee
        }
        if let attendeeEmail = fjUserAttendeeRecord["attendeeEmail"] as? String {
            fjUserAttendees.attendeeEmail = attendeeEmail
        }
        if let attendeePhone = fjUserAttendeeRecord["attendeePhone"] as? String {
            fjUserAttendees.attendeePhone = attendeePhone
        }
        if let attendeeHomeAgency = fjUserAttendeeRecord["attendeeHomeAgency"] as? String {
            fjUserAttendees.attendeeHomeAgency = attendeeHomeAgency
        }
        if let attendeeICSPosition = fjUserAttendeeRecord["attendeeICSPosition"] as? String {
            fjUserAttendees.attendeeICSPosition = attendeeICSPosition
        }
        if let attendeeModDate = fjUserAttendeeRecord["attendeeModDate"] as? Date {
            fjUserAttendees.attendeeModDate = attendeeModDate
        }
        
        if let staffGuid = fjUserAttendeeRecord["staffGuid"] as? String {
            fjUserAttendees.staffGuid = UUID(uuidString: staffGuid)
        }
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            fjUserAttendeeRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            fjUserAttendees.fjUserAttendeeCKR = data as NSObject
           
        
    }
    
    fileprivate func saveToCD() {
        
        do {
            try self.bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJuser Attendees from cloud syncing Operation"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjICS214ActivityLog])
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
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
