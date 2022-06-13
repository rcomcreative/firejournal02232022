    //
    //  FJProjectCrewSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJProjectCrewSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var promotionCrewA = [PromotionCrew]()
    var promotionJournalA = [PromotionJournal]()
    var ckRecordA = [CKRecord]()
    var thePromotionCrew: PromotionCrew!
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
        getThePromotionJournals()
        
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
            newPromotionCrewFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                let result = promotionCrewA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    newPromotionCrewFromCloud(ckRecord: record)
                } else {
                    thePromotionCrew = result.last
                    updatePromotionCrewFromCloud(ckRecord: record, theProjectCrew: thePromotionCrew )
                }
            } 
        }
        completion()
    }
    
    func updatePromotionCrewFromCloud(ckRecord: CKRecord, theProjectCrew: PromotionCrew) {
        
        if let firstName = ckRecord["first"] as? String {
            theProjectCrew.first = firstName
        }
        if let fullName = ckRecord["fullName"] as? String {
            theProjectCrew.fullName = fullName
        }
        if let guid =  ckRecord["guid"] as? String {
            theProjectCrew.guid = UUID(uuidString: guid)
        }
        if let lastName = ckRecord["last"] as? String {
            theProjectCrew.last = lastName
        }
        if let rank = ckRecord["rank"] as? String {
            theProjectCrew.rank = rank
        }
        
        if theProjectCrew.promotion == nil {
            if let guid =  ckRecord["guid"] as? String {
                theProjectCrew.promotionGuid = UUID(uuidString: guid)
                if let guid = theProjectCrew.promotionGuid {
                    let result = promotionJournalA.filter { $0.guid == guid }
                    if !result.isEmpty {
                        if let theProject = result.last {
                            theProject.addToCrew(theProjectCrew)
                        }
                    }
                }
            }
        }
        
        if theProjectCrew.promotionCrewReference == nil {
            let theProjectCrewReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectCrewReference, requiringSecureCoding: true)
                theProjectCrew.promotionCrewReference = data as NSObject
                
            } catch {
                print("promotionCrewReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theProjectCrew.promotionCrewCKR = data as NSObject
        
    }
    
    func newPromotionCrewFromCloud(ckRecord: CKRecord) {
        
        let theProjectCrew = PromotionCrew(context: bkgrdContext)
        
        if let firstName = ckRecord["first"] as? String {
            theProjectCrew.first = firstName
        }
        if let fullName = ckRecord["fullName"] as? String {
            theProjectCrew.fullName = fullName
        }
        if let guid =  ckRecord["guid"] as? String {
            theProjectCrew.guid = UUID(uuidString: guid)
        }
        if let lastName = ckRecord["last"] as? String {
            theProjectCrew.last = lastName
        }
        if let rank = ckRecord["rank"] as? String {
            theProjectCrew.rank = rank
        }
        if let guid =  ckRecord["guid"] as? String {
            theProjectCrew.promotionGuid = UUID(uuidString: guid)
            if let guid = theProjectCrew.promotionGuid {
                let result = promotionJournalA.filter { $0.guid == guid }
                if !result.isEmpty {
                    if let theProject = result.last {
                        theProject.addToCrew(theProjectCrew)
                    }
                }
            }
        }
        
        let theProjectCrewReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectCrewReference, requiringSecureCoding: true)
            theProjectCrew.promotionCrewReference = data as NSObject
            
        } catch {
            print("promotionCrewReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theProjectCrew.promotionCrewCKR = data as NSObject
        
    }
    
    func getThePromotionJournals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionJournal" )
        do {
            promotionJournalA = try bkgrdContext.fetch(fetchRequest) as! [PromotionJournal]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionCrew" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            promotionCrewA = try bkgrdContext.fetch(fetchRequest) as! [PromotionCrew]
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
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJProjectCrewSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjPhoto])
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
