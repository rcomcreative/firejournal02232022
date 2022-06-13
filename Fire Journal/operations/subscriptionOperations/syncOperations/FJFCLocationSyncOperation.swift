    //
    //  FJFCLocationSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/13/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation


class FJFCLocationSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var ckRecordA = [CKRecord]()
    var theFCLocation: FCLocation!
    var theFCLocationA = [FCLocation]()
    var theJournalsA = [Journal]()
    var theIncidentsA = [Incident]()
    var theProjectsA = [PromotionJournal]()
    var theICS214A = [ICS214Form]()
    var theUserTimeA = [UserTime]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
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
        getTheJournals()
        getTheIncidents()
        getThePromotionJournals()
        getTheICS214s()
        getTheUserTime()
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
        for record in ckRecordA {
            print("new location")
            newFCLocationFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                let result = theFCLocationA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    print("new location")
                    newFCLocationFromCloud(ckRecord: record)
                } else {
                    print("modified location")
                    theFCLocation = result.last
                    updateFCLocationFromCloud(ckRecord: record, theFCLocation: theFCLocation)
                }
            }
        }
        completion()
    }
    
    func updateFCLocationFromCloud(ckRecord: CKRecord, theFCLocation: FCLocation) {
        
        if ckRecord["location"] != nil {
            let location = ckRecord.encryptedValues["location"] as! CLLocation
            theFCLocation.location = location
        }
        
        if let longitude = ckRecord["longitude"] as? Double {
            if longitude != 0.0 {
                theFCLocation.longitude = longitude
            }
        }
        
        if let latitude = ckRecord["latitude"] as? Double {
            if latitude != 0.0 {
                theFCLocation.latitude = latitude
            }
        }
        
        if let streetNumber = ckRecord["streetNumber"] as? String {
            theFCLocation.streetNumber = streetNumber
        }
        
        if let streetName = ckRecord["streetName"] as? String {
            theFCLocation.streetName = streetName
        }
        
        if let city = ckRecord["city"] as? String {
            theFCLocation.city = city
        }
        
        if let state = ckRecord["state"] as? String {
            theFCLocation.state = state
        }
        
        if let zip = ckRecord["zip"] as? String {
            theFCLocation.zip = zip
        }
        
        if let modDate = ckRecord["modDate"] as? Date {
            theFCLocation.modDate = modDate
        }
        
        if let acrossFormGuid = ckRecord["acrossFormGuid"] as? String {
            theFCLocation.acrossFormGuid = acrossFormGuid
        }
        
        if let appSuite = ckRecord["appSuite"] as? String {
            theFCLocation.appSuite = appSuite
        }
        
        if let censusTract = ckRecord["censusTract"] as? String {
            theFCLocation.censusTract = censusTract
        }
        
        if let crossStreet = ckRecord["crossStreet"] as? String {
            theFCLocation.crossStreet = crossStreet
        }
        
        if let prefix = ckRecord["prefix"] as? String {
            theFCLocation.prefix = prefix
        }
        
        if let  locaitonType = ckRecord["locaitonType"] as? String {
            theFCLocation.locaitonType =  locaitonType
        }
        
        if let  streetType = ckRecord["streetType"] as? String {
            theFCLocation.streetType =  streetType
        }
        
        if let  suffix = ckRecord["suffix"] as? String {
            theFCLocation.suffix =  suffix
        }
        
        if let  incidentGuid = ckRecord["incidentGuid"] as? String {
            theFCLocation.incidentGuid = incidentGuid
            let result = theIncidentsA.filter { $0.fjpIncGuidForReference == incidentGuid }
            if !result.isEmpty {
                if let theIncident = result.last {
                    theIncident.theLocation = theFCLocation
                    theIncident.locationAvailable = true
                }
            }
        }
        
        if let  journalGuid = ckRecord["journalGuid"] as? String {
            theFCLocation.journalGuid = journalGuid
            let result = theJournalsA.filter { $0.fjpJGuidForReference == journalGuid }
            if !result.isEmpty {
                if let theJournal = result.last {
                    theJournal.theLocation = theFCLocation
                    theJournal.locationAvailable = true
                }
            }
        }
        
        if let  promotionGuid = ckRecord["promotionGuid"] as? String {
            theFCLocation.promotionGuid = promotionGuid
            let result = theProjectsA.filter { $0.projectGuid == promotionGuid }
            if !result.isEmpty {
                if let theProject = result.last {
                    theProject.theLocation = theFCLocation
                }
            }
        }
        
        if let  ics214Guid = ckRecord["ics214Guid"] as? String {
            theFCLocation.ics214Guid = ics214Guid
            let result = theICS214A.filter { $0.ics214Guid == ics214Guid }
            if !result.isEmpty {
                if let theICS214 = result.last {
                    theICS214.theLocation = theFCLocation
                }
            }
        }
        
        if theFCLocation.fcLocationReference == nil {
            let theFCLocationReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theFCLocationReference, requiringSecureCoding: true)
                theFCLocation.fcLocationReference = data as NSObject
                
            } catch {
                print("promotionJournalReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theFCLocation.fcLocaationCKR = data as NSObject
        
    }
    
    func newFCLocationFromCloud(ckRecord: CKRecord) {
        
        let theFCLocation = FCLocation(context: bkgrdContext)
        
        if ckRecord["location"] != nil {
            let location = ckRecord.encryptedValues["location"] as! CLLocation
            theFCLocation.location = location
        }
        
        if let longitude = ckRecord["longitude"] as? Double {
            if longitude != 0.0 {
                theFCLocation.longitude = longitude
            }
        }
        
        if let latitude = ckRecord["latitude"] as? Double {
            if latitude != 0.0 {
                theFCLocation.latitude = latitude
            }
        }
        
        if let streetNumber = ckRecord["streetNumber"] as? String {
            theFCLocation.streetNumber = streetNumber
        }
        
        if let streetName = ckRecord["streetName"] as? String {
            theFCLocation.streetName = streetName
        }
        
        if let city = ckRecord["city"] as? String {
            theFCLocation.city = city
        }
        
        if let state = ckRecord["state"] as? String {
            theFCLocation.state = state
        }
        
        if let zip = ckRecord["zip"] as? String {
            theFCLocation.zip = zip
        }
        
        if let modDate = ckRecord["modDate"] as? Date {
            theFCLocation.modDate = modDate
        }
        
        if let acrossFormGuid = ckRecord["acrossFormGuid"] as? String {
            theFCLocation.acrossFormGuid = acrossFormGuid
        }
        
        if let appSuite = ckRecord["appSuite"] as? String {
            theFCLocation.appSuite = appSuite
        }
        
        if let censusTract = ckRecord["censusTract"] as? String {
            theFCLocation.censusTract = censusTract
        }
        
        if let crossStreet = ckRecord["crossStreet"] as? String {
            theFCLocation.crossStreet = crossStreet
        }
        
        if let prefix = ckRecord["prefix"] as? String {
            theFCLocation.prefix = prefix
        }
        
        if let  locaitonType = ckRecord["locaitonType"] as? String {
            theFCLocation.locaitonType =  locaitonType
        }
        
        if let  streetType = ckRecord["streetType"] as? String {
            theFCLocation.streetType =  streetType
        }
        
        if let  suffix = ckRecord["suffix"] as? String {
            theFCLocation.suffix =  suffix
        }
        
        if let  incidentGuid = ckRecord["incidentGuid"] as? String {
            theFCLocation.incidentGuid = incidentGuid
            let result = theIncidentsA.filter { $0.fjpIncGuidForReference == incidentGuid }
            if !result.isEmpty {
                if let theIncident = result.last {
                    theIncident.theLocation = theFCLocation
                    theIncident.locationAvailable = true
                }
            }
        }
        
        if let  journalGuid = ckRecord["journalGuid"] as? String {
            theFCLocation.journalGuid = journalGuid
            let result = theJournalsA.filter { $0.fjpJGuidForReference == journalGuid }
            if !result.isEmpty {
                if let theJournal = result.last {
                    theJournal.theLocation = theFCLocation
                    theJournal.locationAvailable = true
                }
            }
        }
        
        if let  promotionGuid = ckRecord["promotionGuid"] as? String {
            theFCLocation.promotionGuid = promotionGuid
            let result = theProjectsA.filter { $0.projectGuid == promotionGuid }
            if !result.isEmpty {
                if let theProject = result.last {
                    theProject.theLocation = theFCLocation
                }
            }
        }
        
        if let  ics214Guid = ckRecord["ics214Guid"] as? String {
            theFCLocation.ics214Guid = ics214Guid
            let result = theICS214A.filter { $0.ics214Guid == ics214Guid }
            if !result.isEmpty {
                if let theICS214 = result.last {
                    theICS214.theLocation = theFCLocation
                }
            }
        }
        
        let theFCLocationReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theFCLocationReference, requiringSecureCoding: true)
            theFCLocation.fcLocationReference = data as NSObject
            
        } catch {
            print("promotionJournalReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theFCLocation.fcLocaationCKR = data as NSObject
        
        
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FCLocation" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            theFCLocationA = try bkgrdContext.fetch(fetchRequest) as! [FCLocation]
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
    
    func getTheICS214s() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        do {
            theICS214A = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func getTheUserTime() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTime" )
        do {
            theUserTimeA = try bkgrdContext.fetch(fetchRequest) as! [UserTime]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func getThePromotionJournals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionJournal" )
        do {
            theProjectsA = try bkgrdContext.fetch(fetchRequest) as! [PromotionJournal]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func getTheJournals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        do {
            theJournalsA = try bkgrdContext.fetch(fetchRequest) as! [Journal]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func getTheIncidents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        do {
            theIncidentsA = try bkgrdContext.fetch(fetchRequest) as! [Incident]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD() {
            do {
                try self.bkgrdContext.save()
                
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJPhotoSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjJournalTags])
                    self.executing(false)
                    self.finish(true)
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
