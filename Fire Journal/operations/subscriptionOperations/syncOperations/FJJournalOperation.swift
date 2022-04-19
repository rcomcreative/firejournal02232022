//
//  FJJournalOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit


class FJJournalLoader: FJOperation {
    
    let context: NSManagedObjectContext
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjJournalA = [Journal]()
    var fjJournal:Journal!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var fju:FireJournalUser?
    var counter = 0
    var counted = 0
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.counter = self.ckRecordA.count
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJJournalLoader"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
        executing(true)
        
        getTheDetailData()
        
        let count = theCounter()
        
        if (count == 0 || count == 1) {
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
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
            if let guid:String = record["fjpJGuidForReference"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newJournalFromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        
        var counted = 0
        for record in ckRecordA {
            counted += 1
            if counter != counted {
            if let guid:String = record["fjpJGuidForReference"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newJournalFromCloud(record: record)
                } else {
//                    fjJournal.updateJournalFromCloud(ckRecord: record)
                }
            }
            } else {
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjUser])
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    private func getTheDetailData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try self.context.fetch(fetchRequest) as! [FireJournalUser]
            if fetched.isEmpty {
                print("no user available")
            } else {
                fju = fetched.last
               if let ckr = fju?.fjuCKR {
                guard let archivedData = ckr as? Data else { return  }
                    do {
                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                        let ckRecord = CKRecord(coder: unarchiver)
                        let fjuRID = ckRecord?.recordID
                        _ = CKRecord.Reference(recordID: fjuRID!, action: .deleteSelf)
                    } catch {
                        print("couldn't unarchive file")
                    }
                }
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    private func newJournalFromCloud(record: CKRecord)->Void {
        let fjJournalR = record
        let fjuJournal = Journal(context: self.context)
        if let jReference:String = fjJournalR["fjpIncReference"] {
            fjuJournal.fjpIncReference = jReference
        }
        fjuJournal.fjpUserReference = fju?.userGuid
        fjuJournal.fireJournalUserInfo = fju
        fjuJournal.fjpJGuidForReference = fjJournalR["fjpJGuidForReference"]
        fjuJournal.journalBackedUp = fjJournalR["journalBackedUp"] ?? 0
        if let city:String = fjJournalR["journalCity"] {
            fjuJournal.journalCity = city
        }
        fjuJournal.journalCreationDate = fjJournalR["journalCreationDate"]  ?? Date()
        if let dateSearch:String = fjJournalR["journalDateSearch"] {
            fjuJournal.journalDateSearch = dateSearch
        }
        if let discuss:String = fjJournalR["journalDiscussion"] {
            fjuJournal.journalDiscussion = discuss as NSObject
        }
        if let type:String = fjJournalR["journalEntryType"] {
            let journalType:String = type
            if journalType == "Station" {
                fjuJournal.journalEntryType = "Station"
                fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                fjuJournal.journalPrivate = true
            } else if journalType == "Community" {
                fjuJournal.journalEntryType = "Community"
                fjuJournal.journalEntryTypeImageName = "ICONS_communityboard color"
                fjuJournal.journalPrivate = true
            } else if journalType == "Members" {
                fjuJournal.journalEntryType = "Community"
                fjuJournal.journalEntryTypeImageName = "ICONS_Membersboard color"
                fjuJournal.journalPrivate = true
            } else if journalType == "PRIVATE" {
                fjuJournal.journalEntryType = "PRIVATE"
                fjuJournal.journalEntryTypeImageName = "ICONS_BBLUELOCK"
                fjuJournal.journalPrivate = false
            }
            else if journalType == "Fire" || journalType == "EMS" || journalType == "Rescue" {
                fjuJournal.journalEntryType = journalType
                fjuJournal.journalEntryTypeImageName = "NOTJournal"
            }
        }
        if let fireStation:String = fjJournalR["journalFireStation"] {
            fjuJournal.journalFireStation = fireStation
        }
        if let header:String = fjJournalR["journalHeader"] {
            fjuJournal.journalHeader = header
        }
        
//        MARK: -LOCATION-
        /// journalLocation archived with secureCoding
        if fjJournalR["journalLocation"] != nil {
            if let location = fjJournalR["journalLocation"] {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    fjuJournal.journalLocationSC = data as NSObject
                    fjuJournal.journalLatitude = fjJournalR["journalLatitude"] ?? ""
                    fjuJournal.journalLongitude = fjJournalR["journalLongitude"] ?? ""
                } catch {
                    print("got an error here")
                }

            }
        }
        
        fjuJournal.journalModDate = fjJournalR["journalModDate"] ?? Date()
        if let next:String = fjJournalR["journalNextSteps"] {
            fjuJournal.journalNextSteps = next as NSObject
        }
        if let overView:String = fjJournalR["journalOverview"] {
            fjuJournal.journalOverview = overView as NSObject
        }
        fjuJournal.journalPhotoTaken = fjJournalR["journalPhotoTaken"] ?? 0
        if let state:String = fjJournalR["journalState"] {
            fjuJournal.journalState = state
        }
        if let stName:String = fjJournalR["journalStreetName"] {
            fjuJournal.journalStreetName = stName
        }
        if let num:String = fjJournalR["journalStreetNumber"] {
            fjuJournal.journalStreetNumber = num
        }
        if let summary:String = fjJournalR["journalSummary"] {
            fjuJournal.journalSummary = summary as NSObject
        }
        //        TODO: -JOURNAL TAGS-
        //        fjuJournal.journalTag = fjJournalR["journalTag"]
        if let tempApp:String = fjJournalR["journalTempApparatus"] {
            fjuJournal.journalTempApparatus = tempApp
        }
        if let tempAss:String = fjJournalR["journalTempAssignment"] {
            fjuJournal.journalTempAssignment = tempAss
        }
        if let tempFS:String = fjJournalR["journalTempFireStation"] {
            fjuJournal.journalTempFireStation = tempFS
        }
        if let tempP:String = fjJournalR["journalTempPlatoon"] {
            fjuJournal.journalTempPlatoon = tempP
        }
        if let zip:String = fjJournalR["journalZip"] {
            fjuJournal.journalZip = zip
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjJournalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuJournal.fjJournalCKR = data as NSObject
        
        saveTheJournalEntry()
    }
    
    private func saveTheJournalEntry() {
        do {
            counted += 1
            print(counted)
            try self.context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"FJJournal Operation here"])
            }
        } catch let error as NSError {
            let nserror = error
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"FJJournal Operation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity": TheEntities.fjUser])
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
        let attribute = "fjpJGuidForReference"
        let entity = "Journal"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjJournalA = try context.fetch(fetchRequest) as! [Journal]
            fjJournal = fjJournalA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
}
