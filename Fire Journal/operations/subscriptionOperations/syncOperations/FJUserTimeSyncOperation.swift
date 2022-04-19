//
//  FJUserTimeSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/12/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit


class FJUserTimeSyncOperation: FJOperation {

    let context: NSManagedObjectContext
    var privateDatabase:CKDatabase!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var thread:Thread!
    var fjUserTimeA = [UserTime]()
    var fjUserTime:UserTime!
    var ckRecordA = [CKRecord]()
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJUserTimeSyncOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
//        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTime" )
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
            if let guid:String = record["userTimeGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newUserTimeFromTheCloud(ckRecord: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["userTimeGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newUserTimeFromTheCloud(ckRecord: record)
                } else {
                    fjUserTime.updateUserTimeFromTheCloud(ckRecord: record)
                }
            }
        }
        completion()
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    private func theCount(guid: String)->Int {
        let attribute = "userTimeGuid"
        let entity = "UserTime"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjUserTimeA = try context.fetch(fetchRequest) as! [UserTime]
            fjUserTime = fjUserTimeA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func newUserTimeFromTheCloud(ckRecord: CKRecord) {
        let fjUserTimeRecord = ckRecord
        let fjuUserTime = UserTime(context: context)
        fjuUserTime.endShiftDiscussion = fjUserTimeRecord["endShiftDiscussion"] ?? ""
        fjuUserTime.endShiftSupervisor = fjUserTimeRecord["endShiftSupervisor"] ?? ""
        fjuUserTime.endShiftStatus = fjUserTimeRecord["endShiftStatus"] ?? false
        fjuUserTime.enShiftRelievedBy = fjUserTimeRecord["enShiftRelievedBy"] ?? ""
        fjuUserTime.entryState = fjUserTimeRecord["entryState"] ?? 0
        fjuUserTime.startShiftApparatus = fjUserTimeRecord["startShiftApparatus"] ?? ""
        fjuUserTime.startShiftAssignment = fjUserTimeRecord["startShiftAssignment"] ?? ""
        fjuUserTime.startShiftCrew = fjUserTimeRecord["startShiftCrew"] ?? ""
        fjuUserTime.startShiftDiscussion = fjUserTimeRecord["startShiftDiscussion"] ?? ""
        fjuUserTime.startShiftFireStation = fjUserTimeRecord["startShiftFireStation"] ?? ""
        fjuUserTime.startShiftPlatoon = fjUserTimeRecord["startShiftPlatoon"] ?? ""
        fjuUserTime.startShiftRelieving = fjUserTimeRecord["startShiftRelieving"] ?? ""
        fjuUserTime.startShiftSupervisor = fjUserTimeRecord["startShiftSupervisor"] ?? ""
        fjuUserTime.startShiftResources = fjUserTimeRecord["startShiftResource"] ?? ""
        fjuUserTime.startShiftStatus = fjUserTimeRecord["startShiftStatus"] ?? false
        fjuUserTime.updateShiftDiscussion = fjUserTimeRecord["updateShiftDiscussion"] ?? ""
        fjuUserTime.updateShiftFireStation = fjUserTimeRecord["updateShiftFireStation"] ?? ""
        fjuUserTime.updateShiftPlatoon = fjUserTimeRecord["updateShiftPlatoon"] ?? ""
        fjuUserTime.updateShiftRelievedBy = fjUserTimeRecord["updateShiftRelievedBy"] ?? ""
        fjuUserTime.updateShiftSupervisor = fjUserTimeRecord["updateShiftSupervisor"] ?? ""
        fjuUserTime.updateShiftStatus = fjUserTimeRecord["updateShiftStatus"] ?? false
        if let endShiftDate:Date = fjUserTimeRecord["userEndShiftTime"] {
            fjuUserTime.userEndShiftTime = endShiftDate
        }
        if let startShiftTime:Date = fjUserTimeRecord["userStartShiftTime"] {
            fjuUserTime.userStartShiftTime = startShiftTime
        }
        fjuUserTime.userTimeBackup = fjUserTimeRecord["userTimeBackup"] ?? false
        fjuUserTime.userTimeDayOfYear = fjUserTimeRecord["userTimeDayOfYear"] ?? ""
        fjuUserTime.userTimeGuid = fjUserTimeRecord["userTimeGuid"] ?? ""
        fjuUserTime.userTimeYear = fjUserTimeRecord["userTimeYear"] ?? ""
        if let updateDate:Date = fjUserTimeRecord["userUpdateShiftTime"] {
            fjuUserTime.userUpdateShiftTime = updateDate
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserTimeRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuUserTime.fjUserTimeCKR = data as NSObject
    }
    
    fileprivate func saveToCD() {
        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"FJUser Time Sync Operation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjICS214])
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
}
