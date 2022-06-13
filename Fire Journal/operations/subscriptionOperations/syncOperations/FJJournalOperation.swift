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
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjJournalA = [Journal]()
    var fjJournal: Journal!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var counter = 0
    var counted = 0
    
    var theUser: FireJournalUser!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
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
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
        executing(true)
        
        getTheUser()
        
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
            let count = try bkgrdContext.count(for:fetchRequest)
            fjJournalA = try bkgrdContext.fetch(fetchRequest) as! [Journal]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            newJournalFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["fjpJGuidForReference"] {
                let result = fjJournalA.filter { $0.fjpJGuidForReference == guid }
                if result.isEmpty {
                    newJournalFromCloud(record: record)
                } else {
                    fjJournal = result.last
                    updateJournalFromCloud(fjJournalR: record, fjuJournal: fjJournal)
                }
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
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
    
    func updateJournalFromCloud( fjJournalR: CKRecord, fjuJournal: Journal ) {
        
        if let jReference:String = fjJournalR["fjpIncReference"] {
            fjuJournal.fjpIncReference = jReference
        }
        fjuJournal.fjpUserReference = theUser?.userGuid
        fjuJournal.fireJournalUserInfo = theUser
        if let fjpJGuidForReference = fjJournalR["fjpJGuidForReference"] as? String{
            fjuJournal.fjpJGuidForReference = fjpJGuidForReference
        }
        if let journalBackedUp = fjJournalR["journalBackedUp"] as? Double {
            fjuJournal.journalBackedUp = journalBackedUp as NSNumber
        }
        if let journalCreationDate = fjJournalR["journalCreationDate"]  as? Date {
            fjuJournal.journalCreationDate = journalCreationDate
        }
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
        
        
            if fjuJournal.theLocation != nil {
                if fjJournalR["journalLocation"] != nil {
                if let  theJournalLocation = fjuJournal.theLocation {
                    if let location = fjJournalR["journalLocation"] as? CLLocation {
                        
                        
                        theJournalLocation.location = location
                        theJournalLocation.latitude = location.coordinate.latitude
                        theJournalLocation.longitude = location.coordinate.longitude
                        
                    }
                    
                    if let modDate = fjuJournal.journalModDate {
                        theJournalLocation.modDate = modDate
                    } else {
                        theJournalLocation.modDate = Date()
                    }
                    if let stName = fjJournalR["journalStreetName"] as? String {
                        theJournalLocation.streetName = stName
                    }
                    if let num = fjJournalR["journalStreetNumber"] as? String {
                        theJournalLocation.streetNumber = num
                    }
                    
                    if let city:String = fjJournalR["journalCity"] {
                        theJournalLocation.city = city
                    }
                    
                    if let state = fjJournalR["journalState"] as? String {
                        theJournalLocation.state = state
                    }
                    if let zip = fjJournalR["journalZip"] as? String  {
                        theJournalLocation.zip = zip
                    }
                    
                    if let jReference = fjJournalR["fjpJGuidForReference"] as? String {
                        theJournalLocation.journalGuid = jReference
                    }
                }
            }
        }
        
        if let journalModDate = fjJournalR["journalModDate"] as? Date {
            fjuJournal.journalModDate = journalModDate
        }
        if let next  = fjJournalR["journalNextSteps"] as? String {
            fjuJournal.journalNextSteps = next as NSObject
        }
        if let overView = fjJournalR["journalOverview"] as? String{
            fjuJournal.journalOverview = overView as NSObject
        }
        if let journalPhotoTaken = fjJournalR["journalPhotoTaken"] as? Double {
            fjuJournal.journalPhotoTaken = journalPhotoTaken as NSNumber
        }
        if let locationAvailable = fjJournalR["locationAvailable"] as? Double {
            if locationAvailable == 1 {
            fjuJournal.locationAvailable = true
            } else {
                fjuJournal.locationAvailable = false
            }
        }
        if let journalTagsAvailable = fjJournalR["journalTagsAvailable"] as? Double {
            if journalTagsAvailable == 1 {
            fjuJournal.journalTagsAvailable = true
            } else {
                fjuJournal.journalTagsAvailable = false
            }
        }
        
        if let summary = fjJournalR["journalSummary"] as? String  {
            fjuJournal.journalSummary = summary as NSObject
        }
            //        TODO: -JOURNAL TAGS-
            //        fjuJournal.journalTag = fjJournalR["journalTag"]
        if let tempApp = fjJournalR["journalTempApparatus"] as? String {
            fjuJournal.journalTempApparatus = tempApp
        }
        if let tempAss = fjJournalR["journalTempAssignment"] as? String  {
            fjuJournal.journalTempAssignment = tempAss
        }
        if let tempFS = fjJournalR["journalTempFireStation"] as? String {
            fjuJournal.journalTempFireStation = tempFS
        }
        if let tempP = fjJournalR["journalTempPlatoon"] as? String  {
            fjuJournal.journalTempPlatoon = tempP
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjJournalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuJournal.fjJournalCKR = data as NSObject
        
    }
    
    private func newJournalFromCloud(record: CKRecord)->Void {
        let fjJournalR = record
        let fjuJournal = Journal(context: bkgrdContext)
        if let jReference:String = fjJournalR["fjpIncReference"] {
            fjuJournal.fjpIncReference = jReference
        }
        fjuJournal.fjpUserReference = theUser?.userGuid
        fjuJournal.fireJournalUserInfo = theUser
        if let fjpJGuidForReference = fjJournalR["fjpJGuidForReference"] as? String{
            fjuJournal.fjpJGuidForReference = fjpJGuidForReference
        }
        if let journalBackedUp = fjJournalR["journalBackedUp"] as? Double {
            fjuJournal.journalBackedUp = journalBackedUp as NSNumber
        }
        if let journalCreationDate = fjJournalR["journalCreationDate"]  as? Date {
            fjuJournal.journalCreationDate = journalCreationDate
        }
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
        if let journalModDate = fjJournalR["journalModDate"] as? Date {
            fjuJournal.journalModDate = journalModDate
        }
        
            //        MARK: -LOCATION-
            /// journalLocation archived with secureCoding
        var theJournalLocation = FCLocation(context: bkgrdContext)
        theJournalLocation.guid = UUID.init()
        if fjJournalR["journalLocation"] != nil {
            if let location = fjJournalR["journalLocation"] as? CLLocation {

                theJournalLocation.location = location
                theJournalLocation.latitude = location.coordinate.latitude
                theJournalLocation.longitude = location.coordinate.longitude
                
            }
           
            if let modDate = fjuJournal.journalModDate {
                theJournalLocation.modDate = modDate
            } else {
                theJournalLocation.modDate = Date()
            }
            if let stName = fjJournalR["journalStreetName"] as? String {
                theJournalLocation.streetName = stName
            }
            if let num = fjJournalR["journalStreetNumber"] as? String {
                theJournalLocation.streetNumber = num
            }
            
            if let city:String = fjJournalR["journalCity"] {
                theJournalLocation.city = city
            }
            
            if let state = fjJournalR["journalState"] as? String {
                theJournalLocation.state = state
            }
            if let zip = fjJournalR["journalZip"] as? String  {
                theJournalLocation.zip = zip
            }
            
            if let jReference = fjJournalR["fjpJGuidForReference"] as? String {
                theJournalLocation.journalGuid = jReference
            }
            
            theJournalLocation.journal = fjuJournal
            
        }
        
        if let next  = fjJournalR["journalNextSteps"] as? String {
            fjuJournal.journalNextSteps = next as NSObject
        }
        if let overView = fjJournalR["journalOverview"] as? String{
            fjuJournal.journalOverview = overView as NSObject
        }
        if let journalPhotoTaken = fjJournalR["journalPhotoTaken"] as? Double {
            fjuJournal.journalPhotoTaken = journalPhotoTaken as NSNumber
        }
        
        if let journalTagsAvailable = fjJournalR["journalTagsAvailable"] as? Double {
            if journalTagsAvailable == 1 {
            fjuJournal.journalTagsAvailable = true
            } else {
                fjuJournal.journalTagsAvailable = false
            }
        }
        if let locationAvailable = fjJournalR["locationAvailable"] as? Double {
                       if locationAvailable == 1 {
                       fjuJournal.locationAvailable = true
                       } else {
                           fjuJournal.locationAvailable = false
                       }
                   }
        
        if let summary = fjJournalR["journalSummary"] as? String  {
            fjuJournal.journalSummary = summary as NSObject
        }
            //        TODO: -JOURNAL TAGS-
            //        fjuJournal.journalTag = fjJournalR["journalTag"]
        if let tempApp = fjJournalR["journalTempApparatus"] as? String {
            fjuJournal.journalTempApparatus = tempApp
        }
        if let tempAss = fjJournalR["journalTempAssignment"] as? String  {
            fjuJournal.journalTempAssignment = tempAss
        }
        if let tempFS = fjJournalR["journalTempFireStation"] as? String {
            fjuJournal.journalTempFireStation = tempFS
        }
        if let tempP = fjJournalR["journalTempPlatoon"] as? String  {
            fjuJournal.journalTempPlatoon = tempP
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjJournalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuJournal.fjJournalCKR = data as NSObject
        
        
    }
    
    
    
    
    fileprivate func saveToCD() {
        
        do {
            try self.bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext,userInfo:["info":"FJJournal Operation here"])
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
    
}
