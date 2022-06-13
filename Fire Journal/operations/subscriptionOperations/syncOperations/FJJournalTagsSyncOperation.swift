//
//  FJJournalTagsSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/19/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FJJournalTagsSyncOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var journalTagsA = [JournalTags]()
    var theJournalsA = [Journal]()
    var ckRecordA = [CKRecord]()
    var theJournalTag: JournalTags!
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
        getTheJournals()
        
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
            newJournalTagsFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let journalGuid = record["journalGuid"] as? String  {
                let result = journalTagsA.filter { $0.journalGuid == journalGuid }
                if result.isEmpty {
                    newJournalTagsFromCloud(ckRecord: record)
                } else {
                    theJournalTag = result.last
                    updateJournalTagsFromCloud(ckRecord: record, theJournalTag: theJournalTag )
                }
            }
        }
        completion()
    }
    
    func newJournalTagsFromCloud(ckRecord: CKRecord) {
        
        theJournalTag = JournalTags(context: bkgrdContext)
        if let tag =  ckRecord["journalTag"] as? String {
            self.theJournalTag.journalTag  = tag
        }
        if let journalGuid =  ckRecord["fjpJournalReference"] as? String {
          theJournalTag.fjpJournalReference = journalGuid
            let result = theJournalsA.filter { $0.fjpJGuidForReference == journalGuid }
            if !result.isEmpty {
                if let journal = result.last {
                    journal.addToJournalTags(theJournalTag)
                }
            }
        }
        if let guid = ckRecord["journalGuid"] as? String {
            theJournalTag.journalGuid = guid
        }
        
        let theJournalTagReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theJournalTagReference, requiringSecureCoding: true)
            theJournalTag.aJournalTagReferenceSC = data as NSObject
            
        } catch {
            print("journalTagsReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theJournalTag.journalTagCKR = data as NSObject
        
    }
    
    func updateJournalTagsFromCloud(ckRecord: CKRecord, theJournalTag: JournalTags) {
        
        if let tag =  ckRecord["journalTag"] as? String {
            self.theJournalTag.journalTag  = tag
        }
        if let journalGuid =  ckRecord["fjpJournalReference"] as? String {
          theJournalTag.fjpJournalReference = journalGuid
            let result = theJournalsA.filter { $0.fjpJGuidForReference == journalGuid }
            if !result.isEmpty {
                if let journal = result.last {
                    journal.addToJournalTags(theJournalTag)
                }
            }
        }
        if let guid = ckRecord["journalGuid"] as? String {
            theJournalTag.journalGuid = guid
        }
        
        if theJournalTag.aJournalTagReferenceSC == nil {
        let theJournalTagReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theJournalTagReference, requiringSecureCoding: true)
            theJournalTag.aJournalTagReferenceSC = data as NSObject
            
        } catch {
            print("promotionCrewReference to data failed line 514 Incident+Custom")
        }
        }
            
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theJournalTag.journalTagCKR = data as NSObject
        
    }
    
    func getTheJournals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        do {
            theJournalsA = try bkgrdContext.fetch(fetchRequest) as! [Journal]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
        
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "JournalTags" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            journalTagsA = try bkgrdContext.fetch(fetchRequest) as! [JournalTags]
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
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJJournalTagsSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjIncidentTags])
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
