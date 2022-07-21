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
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
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
        operation = "FJUserTimeSyncOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
        executing(true)
        
        
        let count = theCounter()
        getTheUser()
        
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
            let count = try bkgrdContext.count(for:fetchRequest)
            fjUserTimeA = try bkgrdContext.fetch(fetchRequest) as! [UserTime]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theUser = bkgrdContext.object(with: id) as? FireJournalUser
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
                //                    newUserTimeFromTheCloud(ckRecord: record)
            fjUserTime = UserTime(context: bkgrdContext)
            fjUserTime.updateUserTimeFromTheCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["userTimeGuid"] {
                let result = fjUserTimeA.filter { $0.userTimeGuid == guid }
                if result.isEmpty {
                        //                    newUserTimeFromTheCloud(ckRecord: record)
                    fjUserTime = UserTime(context: bkgrdContext)
                    fjUserTime.updateUserTimeFromTheCloud(ckRecord: record)
                } else {
                    fjUserTime = result.last
                    fjUserTime.updateUserTimeFromTheCloud(ckRecord: record)
                        //                    updateUserTimeFromCloud(fjUserTimeRecord: record, fjuUserTime: fjUserTime)
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
    
    private func newUserTimeFromTheCloud(ckRecord: CKRecord) {
        let fjUserTimeRecord = ckRecord
        let fjuUserTime = UserTime(context: bkgrdContext)
        
        if let endShiftDiscussion = fjUserTimeRecord["endShiftDiscussion"] as? String {
            fjuUserTime.endShiftDiscussion = endShiftDiscussion
        }
        if let endShiftSupervisor = fjUserTimeRecord["endShiftSupervisor"] as? String {
            fjuUserTime.endShiftSupervisor = endShiftSupervisor
        }
        if let endShiftStatus = fjUserTimeRecord["endShiftStatus"] as? Bool {
            fjuUserTime.endShiftStatus = endShiftStatus
        }
        if let enShiftRelievedBy = fjUserTimeRecord["enShiftRelievedBy"]  as? String {
            fjuUserTime.enShiftRelievedBy = enShiftRelievedBy
        }
        if let entryState = fjUserTimeRecord["entryState"] as? Int64 {
            fjuUserTime.entryState = entryState
        }
        if let startShiftApparatus = fjUserTimeRecord["startShiftApparatus"] as? String {
            fjuUserTime.startShiftApparatus = startShiftApparatus
        }
        if let startShiftAssignment = fjUserTimeRecord["startShiftAssignment"]  as? String {
            fjuUserTime.startShiftAssignment = startShiftAssignment
        }
        if let startShiftCrew = fjUserTimeRecord["startShiftCrew"]  as? String {
            fjuUserTime.startShiftCrew = startShiftCrew
        }
        if let startShiftDiscussion = fjUserTimeRecord["startShiftDiscussion"]  as? String {
            fjuUserTime.startShiftDiscussion = startShiftDiscussion
        }
        if let startShiftFireStation = fjUserTimeRecord["startShiftFireStation"]  as? String {
            fjuUserTime.startShiftFireStation = startShiftFireStation
        }
        if let startShiftPlatoon = fjUserTimeRecord["startShiftPlatoon"]  as? String {
            fjuUserTime.startShiftPlatoon = startShiftPlatoon
        }
        if let startShiftRelieving = fjUserTimeRecord["startShiftRelieving"]  as? String {
            fjuUserTime.startShiftRelieving = startShiftRelieving
        }
        if let startShiftSupervisor = fjUserTimeRecord["startShiftSupervisor"]  as? String {
            fjuUserTime.startShiftSupervisor = startShiftSupervisor
        }
        if let startShiftResources = fjUserTimeRecord["startShiftResource"]  as? String {
            fjuUserTime.startShiftResources = startShiftResources
        }
        if let startShiftStatus = fjUserTimeRecord["startShiftStatus"] as? Bool {
            fjuUserTime.startShiftStatus = startShiftStatus
        }
        if let updateShiftDiscussion = fjUserTimeRecord["updateShiftDiscussion"]  as? String {
            fjuUserTime.updateShiftDiscussion = updateShiftDiscussion
        }
        if let updateShiftFireStation = fjUserTimeRecord["updateShiftFireStation"]  as? String {
            fjuUserTime.updateShiftFireStation = updateShiftFireStation
        }
        if let updateShiftPlatoon = fjUserTimeRecord["updateShiftPlatoon"]  as? String {
            fjuUserTime.updateShiftPlatoon = updateShiftPlatoon
        }
        if let updateShiftRelievedBy = fjUserTimeRecord["updateShiftRelievedBy"]  as? String {
            fjuUserTime.updateShiftRelievedBy = updateShiftRelievedBy
        }
        if let updateShiftSupervisor = fjUserTimeRecord["updateShiftSupervisor"]  as? String {
            fjuUserTime.updateShiftSupervisor = updateShiftSupervisor
        }
        if let updateShiftStatus = fjUserTimeRecord["updateShiftStatus"] as? Bool {
            fjuUserTime.updateShiftStatus = updateShiftStatus
        }
        if let endShiftDate:Date = fjUserTimeRecord["userEndShiftTime"] {
            fjuUserTime.userEndShiftTime = endShiftDate
        }
        if let startShiftTime:Date = fjUserTimeRecord["userStartShiftTime"] {
            fjuUserTime.userStartShiftTime = startShiftTime
        }
        if let userTimeBackup = fjUserTimeRecord["userTimeBackup"] as? Bool {
            fjuUserTime.userTimeBackup = userTimeBackup
        }
        if let userTimeDayOfYear = fjUserTimeRecord["userTimeDayOfYear"]  as? String {
            fjuUserTime.userTimeDayOfYear = userTimeDayOfYear
        }
        if let userTimeGuid = fjUserTimeRecord["userTimeGuid"]  as? String {
            fjuUserTime.userTimeGuid = userTimeGuid
        }
        if let userTimeYear = fjUserTimeRecord["userTimeYear"]  as? String {
            fjuUserTime.userTimeYear = userTimeYear
        }
        if let updateDate:Date = fjUserTimeRecord["userUpdateShiftTime"] {
            fjuUserTime.userUpdateShiftTime = updateDate
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserTimeRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuUserTime.fjUserTimeCKR = data as NSObject
        
        if theUser != nil {
            theUser.addToUserTime(fjuUserTime)
        }
    }
    
    func updateUserTimeFromCloud(fjUserTimeRecord: CKRecord, fjuUserTime: UserTime) {
        
        if let endShiftDiscussion = fjUserTimeRecord["endShiftDiscussion"] as? String {
            fjuUserTime.endShiftDiscussion = endShiftDiscussion
        }
        if let endShiftSupervisor = fjUserTimeRecord["endShiftSupervisor"] as? String {
            fjuUserTime.endShiftSupervisor = endShiftSupervisor
        }
        if let endShiftStatus = fjUserTimeRecord["endShiftStatus"] as? Bool {
            fjuUserTime.endShiftStatus = endShiftStatus
        }
        if let enShiftRelievedBy = fjUserTimeRecord["enShiftRelievedBy"]  as? String {
            fjuUserTime.enShiftRelievedBy = enShiftRelievedBy
        }
        if let entryState = fjUserTimeRecord["entryState"] as? Int64 {
            fjuUserTime.entryState = entryState
        }
        if let startShiftApparatus = fjUserTimeRecord["startShiftApparatus"] as? String {
            fjuUserTime.startShiftApparatus = startShiftApparatus
        }
        if let startShiftAssignment = fjUserTimeRecord["startShiftAssignment"]  as? String {
            fjuUserTime.startShiftAssignment = startShiftAssignment
        }
        if let startShiftCrew = fjUserTimeRecord["startShiftCrew"]  as? String {
            fjuUserTime.startShiftCrew = startShiftCrew
        }
        if let startShiftDiscussion = fjUserTimeRecord["startShiftDiscussion"]  as? String {
            fjuUserTime.startShiftDiscussion = startShiftDiscussion
        }
        if let startShiftFireStation = fjUserTimeRecord["startShiftFireStation"]  as? String {
            fjuUserTime.startShiftFireStation = startShiftFireStation
        }
        if let startShiftPlatoon = fjUserTimeRecord["startShiftPlatoon"]  as? String {
            fjuUserTime.startShiftPlatoon = startShiftPlatoon
        }
        if let startShiftRelieving = fjUserTimeRecord["startShiftRelieving"]  as? String {
            fjuUserTime.startShiftRelieving = startShiftRelieving
        }
        if let startShiftSupervisor = fjUserTimeRecord["startShiftSupervisor"]  as? String {
            fjuUserTime.startShiftSupervisor = startShiftSupervisor
        }
        if let startShiftResources = fjUserTimeRecord["startShiftResource"]  as? String {
            fjuUserTime.startShiftResources = startShiftResources
        }
        if let startShiftStatus = fjUserTimeRecord["startShiftStatus"] as? Bool {
            fjuUserTime.startShiftStatus = startShiftStatus
        }
        if let updateShiftDiscussion = fjUserTimeRecord["updateShiftDiscussion"]  as? String {
            fjuUserTime.updateShiftDiscussion = updateShiftDiscussion
        }
        if let updateShiftFireStation = fjUserTimeRecord["updateShiftFireStation"]  as? String {
            fjuUserTime.updateShiftFireStation = updateShiftFireStation
        }
        if let updateShiftPlatoon = fjUserTimeRecord["updateShiftPlatoon"]  as? String {
            fjuUserTime.updateShiftPlatoon = updateShiftPlatoon
        }
        if let updateShiftRelievedBy = fjUserTimeRecord["updateShiftRelievedBy"]  as? String {
            fjuUserTime.updateShiftRelievedBy = updateShiftRelievedBy
        }
        if let updateShiftSupervisor = fjUserTimeRecord["updateShiftSupervisor"]  as? String {
            fjuUserTime.updateShiftSupervisor = updateShiftSupervisor
        }
        if let updateShiftStatus = fjUserTimeRecord["updateShiftStatus"] as? Bool {
            fjuUserTime.updateShiftStatus = updateShiftStatus
        }
        if let endShiftDate:Date = fjUserTimeRecord["userEndShiftTime"] {
            fjuUserTime.userEndShiftTime = endShiftDate
            fjuUserTime.shiftCompleted = true
        }
        if let startShiftTime:Date = fjUserTimeRecord["userStartShiftTime"] {
            fjuUserTime.userStartShiftTime = startShiftTime
        }
        if let userTimeBackup = fjUserTimeRecord["userTimeBackup"] as? Bool {
            fjuUserTime.userTimeBackup = userTimeBackup
        }
        if let userTimeDayOfYear = fjUserTimeRecord["userTimeDayOfYear"]  as? String {
            fjuUserTime.userTimeDayOfYear = userTimeDayOfYear
        }
        if let userTimeGuid = fjUserTimeRecord["userTimeGuid"]  as? String {
            fjuUserTime.userTimeGuid = userTimeGuid
        }
        if let userTimeYear = fjUserTimeRecord["userTimeYear"]  as? String {
            fjuUserTime.userTimeYear = userTimeYear
        }
        if let updateDate:Date = fjUserTimeRecord["userUpdateShiftTime"] {
            fjuUserTime.userUpdateShiftTime = updateDate
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserTimeRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuUserTime.fjUserTimeCKR = data as NSObject
        
        if fjuUserTime.fireJournalUser == nil {
            if theUser != nil {
                theUser.addToUserTime(fjuUserTime)
            }
        }
        
    }
    
    fileprivate func saveToCD() {
        
        do {
            try self.bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext,userInfo:["info":"FJUser Time Sync Operation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjStatus])
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
