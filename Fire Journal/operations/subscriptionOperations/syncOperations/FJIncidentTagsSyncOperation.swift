    //
    //  FJIncidentTagsSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/19/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJIncidentTagsSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var incidentTagsA = [IncidentTags]()
    var ckRecordA = [CKRecord]()
    var theIncidentsA = [Incident]()
    var theIncidentTag: IncidentTags!
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
        getTheIncidents()
        
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
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            newIncidentTagFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                let result = incidentTagsA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    newIncidentTagFromCloud(ckRecord: record)
                } else {
                    theIncidentTag = result.last
                    updateIncidentTagFromCloud(ckRecord: record, theIncidentTag: theIncidentTag )
                }
            }
        }
        completion()
    }
    
    func newIncidentTagFromCloud(ckRecord: CKRecord) {
        
        theIncidentTag = IncidentTags(context: bkgrdContext)
        if let tag = ckRecord["incidentTag"] as? String  {
            self.theIncidentTag.incidentTag = tag
        }
        if let incidentGuid = ckRecord["incidentGuid"] as? String  {
            self.theIncidentTag.incidentGuid = incidentGuid
        }
        if let guid =  ckRecord["guid"] as? String {
            self.theIncidentTag.guid = UUID(uuidString: guid)
        }
        if let incidentReference =  ckRecord["incidentReference"] as? String {
            self.theIncidentTag.incidentReference = incidentReference
            let result = theIncidentsA.filter { $0.fjpIncGuidForReference == incidentReference }
            if !result.isEmpty {
                if let theIncident = result.last {
                    theIncident.addToIncidentTags(self.theIncidentTag)
                }
            }
        }
        
        let theIncidentTagReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theIncidentTagReference, requiringSecureCoding: true)
            theIncidentTag.incidentTagReference = data as NSObject
            
        } catch {
            print("promotionCrewReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theIncidentTag.incidentTagCKR = data as NSObject
        
    }
    
    func updateIncidentTagFromCloud(ckRecord: CKRecord, theIncidentTag: IncidentTags) {
        
        if let tag = ckRecord["incidentTag"] as? String  {
            self.theIncidentTag.incidentTag = tag
        }
        if let incidentGuid = ckRecord["incidentGuid"] as? String  {
            self.theIncidentTag.incidentGuid = incidentGuid
        }
        if let guid =  ckRecord["guid"] as? String {
            self.theIncidentTag.guid = UUID(uuidString: guid)
        }
        if let incidentReference =  ckRecord["incidentReference"] as? String {
            self.theIncidentTag.incidentReference = incidentReference
            let result = theIncidentsA.filter { $0.fjpIncGuidForReference == incidentReference }
            if !result.isEmpty {
                if let theIncident = result.last {
                    theIncident.addToIncidentTags(self.theIncidentTag)
                }
            }
        }
        
        
        if theIncidentTag.incidentTagReference == nil {
            let theIncidentTagReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theIncidentTagReference, requiringSecureCoding: true)
                theIncidentTag.incidentTagReference = data as NSObject
                
            } catch {
                print("promotionCrewReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theIncidentTag.incidentTagCKR = data as NSObject
        
    }
    
    func getTheIncidents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        do {
            theIncidentsA = try bkgrdContext.fetch(fetchRequest) as! [Incident]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IncidentTags" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            incidentTagsA = try bkgrdContext.fetch(fetchRequest) as! [IncidentTags]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    fileprivate func saveToCD() {
        
        do {
            try self.bkgrdContext.save()
            
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJIncidentTagsSyncOperation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjAttendee])
                self.executing(false)
                self.finish(true)
            }
        } catch let error as NSError {
            let nserror = error
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
        
    }
    
        //    MARK: -CHECK THREAD
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
    
}
