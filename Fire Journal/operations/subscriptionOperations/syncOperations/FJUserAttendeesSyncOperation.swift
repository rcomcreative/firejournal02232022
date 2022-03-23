//
//  FJUserAttendeesSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/22/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FJUserAttendeesSyncOperation: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjAttendeesA = [UserAttendees]()
    var fjUserAttendee:UserAttendees!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
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
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["attendeeGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newUserAttendeeFormFromCloud(ckRecord: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        var counted = 0
        let counter = ckRecordA.count
        for record in ckRecordA {
            if let guid:String = record["attendeeGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newUserAttendeeFormFromCloud(ckRecord: record)
                } else {
                    _ = fjUserAttendee.modifyUserAttendeesFormForCloud(ckRecord: record)
                }
            }
            counted += 1
            print("here is COUNTED \(counted) and \(counter)")
            if counted == counter {
                finish(true)
                return
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJUSER ATTENDEE SYNC Operation here"])
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
    
    private func theCount(guid: String)->Int {
        let attribute = "attendeeGuid"
        let entity = "UserAttendees"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            let attendees = try context.fetch(fetchRequest) as! [UserAttendees]
            fjUserAttendee = attendees.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func newUserAttendeeFormFromCloud(ckRecord: CKRecord)->Void {
        let fjUserAttendeeRecord = ckRecord
        
        let fjUserAttendees = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjUserAttendees.attendeeGuid = fjUserAttendeeRecord["attendeeGuid"]
        fjUserAttendees.attendee = fjUserAttendeeRecord["attendee"]
        fjUserAttendees.attendeeEmail = fjUserAttendeeRecord["attendeeEmail"]
        fjUserAttendees.attendeePhone = fjUserAttendeeRecord["attendeePhone"]
        fjUserAttendees.attendeeHomeAgency = fjUserAttendeeRecord["attendeeHomeAgency"]
        fjUserAttendees.attendeeICSPosition = fjUserAttendeeRecord["attendeeICSPosition"]
        fjUserAttendees.attendeeBackUp = true
        fjUserAttendees.attendeeModDate = fjUserAttendeeRecord["attendeeModDate"]
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserAttendeeRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjUserAttendees.fjUserAttendeeCKR = data as NSObject
        
    }
}
