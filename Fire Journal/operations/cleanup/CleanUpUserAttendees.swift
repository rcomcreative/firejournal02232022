//
//  CleanUpUserAttendees.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class CleanUpUserAttendees: FJOperation {
    //    MARK: -OPERATION PROPERTIES
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjUserAttendeesA = [UserAttendees]()
    var fjUserAttendees:UserAttendees!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    var modifyDelete: Bool = false
    var ckRData: Data!
    var ckRNoData: Bool = false
    var theGuid: String = ""
    var records = [CKRecord]()
    var recordIDs = [CKRecord.ID]()
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        print("CleanUpUserAttendees is going to start running")
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "CleanUpUserAttendees"
         
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
        
        getAllUserAttendees()
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Clean Up User Attendees here"])
            }
        } catch {
            let nserror = error as NSError
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
    
    private func getAllUserAttendees() {
        var membersWithICSPosition = [UserAttendees]()
        var membersWithOutICSPosition = [UserAttendees]()
        var membersName = [String]()
        let predicate = NSPredicate(format: "attendeeGuid != %@","")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        let entity = "UserAttendees"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        
        fetchRequest.predicate = predicateCan
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
            if fetched.isEmpty {
                return
            } else {
                for member:UserAttendees in fetched {
                    member.attendee = member.attendee!.trimmingCharacters(in: .whitespaces)
                    if let memberName = member.attendee {
                        if !membersName.contains(memberName) {
                            membersName.append(memberName)
                            if member.attendeeICSPosition != "" {
                                if member.fjUserAttendeeCKR != nil {
                                    membersWithICSPosition.append(member)
                                }
                            }
                        }
                    } else {
                        membersWithOutICSPosition.append(member)
                    }
                    
                    
                    
                    if member.attendeeICSPosition != "" {
                        
                    } else {
                        membersWithOutICSPosition.append(member)
                    }
                }
                
                for member in membersWithOutICSPosition {
                    bkgrdContext.delete(member)
                }
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Clean Up User Attendees here"])
                    }
                } catch {
                    let nserror = error as NSError
                    print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
                }
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "CleanUpUserAttendees fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            print(errorMessage)
        }
        
        for name in membersName {
            let predicate = NSPredicate(format: "attendee == %@",name)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            let entity = "UserAttendees"
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
            let sectionSortDescriptor = NSSortDescriptor(key: "attendeeModDate", ascending: true )
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicateCan
            do {
                let fetched = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
                if fetched.isEmpty {
                    return
                } else {
                    var userW:UserAttendees?
                    if let user = fetched.last {
                        if user.attendeeICSPosition != "" {
                            if user.attendeeHomeAgency != "" {
                                userW = user
                            }
                        }
                    }
                    var toDelete = [UserAttendees]()
                    for user in fetched {
                        if user != userW {
                            toDelete.append(user)
                        }
                    }
                    for byeUser in toDelete {
                        bkgrdContext.delete(byeUser)
                    }
                    do {
                        try bkgrdContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Clean Up User Attendees here"])
                        }
                    } catch {
                        let nserror = error as NSError
                        print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
                    }
                    
                }
            }catch {
                
            }
                    
        }
        //        MARK: -FETCH ALL OF THE CLOUDKIT IDS FOR USERATTENDEES AND DELETE
        fetchRecords()
    }
    
    private func fetchRecords() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
//        let predicate2 = NSPredicate(format: "attendeeGuid == %@",theGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,])
        let query = CKQuery(recordType: "UserAttendees", predicate: predicateCan)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = { record in
            self.records.append(record)
            print("\(record)")
        }
        
        self.privateDatabase.add(queryOperation)
        
        queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            if error != nil {
                print(error!)
            }
            print("here is the count of records in CleanUpUserAttendees \(self.records.count)")
            for record in self.records {
                self.recordIDs.append(record.recordID)
            }
            self.deleteTheRecords()
        }
        
        func setupAndAdd(operation: CKQueryOperation) {
            self.privateDatabase.add(operation)
        }
    }
    
    func deleteTheRecords() {
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: nil, recordIDsToDelete: self.recordIDs)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify ics214 record to private database \(error.localizedDescription)")
            }
            print("CleanUpUserAttendees has run on and deleted all of user attendees and now needs to run the correct ones through  \(String(describing: deletedRecords))")
            self.correctTheCloudKitUserAttendees()
        }
        privateDatabase.add(modifyCKOperation)
    }
    
    
    private func correctTheCloudKitUserAttendees() {
        var ckRecordA = [CKRecord]()
        let predicate = NSPredicate(format: "attendeeGuid != %@","")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        let entity = "UserAttendees"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        
        fetchRequest.predicate = predicateCan
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
            if fetched.isEmpty {
                return
            } else {
                for user:UserAttendees in fetched {
                    if let ckr = user.fjUserAttendeeCKR {
                        guard let archivedData = ckr as? Data else { return  }
                        do {
                            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                            ckRecord = CKRecord(coder: unarchiver)
                            ckRecord = user.modifyUserAttendeesFormForCloud(ckRecord: ckRecord)
                            ckRecordA.append(ckRecord)
                            } catch {
                               print("couldn't unarchive file")
                            }
                    }
                }
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: ckRecordA, recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    print(record)
                    let guid = record["attendeeGuid"] as? String
                    self.getTheRecord(guid: guid!, record: record)
                }
                modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if let error = error {
                        print("Error modify Incident record to private database \(error.localizedDescription)")
                    }
                    self.saveToCD()
                    DispatchQueue.main.async {
                        print("CleanupuserAttendee has run and now if finished \(String(describing: savedRecords))")
                        self.executing(false)
                        self.finish(true)
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                }
                privateDatabase.add(modifyCKOperation)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    private func getTheRecord(guid:String, record:CKRecord) {
        let predicate = NSPredicate(format: "attendeeGuid == %@",guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        let entity = "UserAttendees"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        
        fetchRequest.predicate = predicateCan
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
            let attendee:UserAttendees = fetched.last!
            attendee.attendeeBackUp = true
            attendee.attendeeModDate = Date()
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            record.encodeSystemFields(with: coder)
            let data = coder.encodedData
            attendee.fjUserAttendeeCKR = data as NSObject
            
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
