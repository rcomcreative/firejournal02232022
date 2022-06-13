    //
    //  FJProjectTagsSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJProjectTagsSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var promotionTagsA = [PromotionJournalTags]()
    var promotionJournalA = [PromotionJournal]()
    var thePromotionTag: PromotionJournalTags!
    var ckRecordA = [CKRecord]()
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
            newPromotionTagFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                let result = promotionTagsA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    newPromotionTagFromCloud(ckRecord: record)
                } else {
                    thePromotionTag = result.last
                    updatePromotionTagFromCloud(ckRecord: record, promotionTag: thePromotionTag )
                }
            }
        }
        completion()
    }
    
    func updatePromotionTagFromCloud(ckRecord: CKRecord, promotionTag: PromotionJournalTags) {
        
        if let tag = ckRecord["tag"] as? String{
            promotionTag.tag = tag
        }
        if let guid = ckRecord["guid"] as? String{
            promotionTag.guid = UUID(uuidString: guid)
        }
        if let guid = ckRecord["promotionGuid"] as? String {
            promotionTag.promotionGuid = guid
            
            if promotionTag.promotionTag == nil {
                if let theGuid = UUID(uuidString: guid) {
                    let result = promotionJournalA.filter { $0.guid == theGuid }
                    if !result.isEmpty {
                        if let theProject = result.last {
                            theProject.addToPromotionTag(promotionTag)
                        }
                    }
                }
            }
        }
        
        if promotionTag.promotionTagsReference == nil {
            
            let theProjectTagReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectTagReference, requiringSecureCoding: true)
                promotionTag.promotionTagsReference = data as NSObject
                
            } catch {
                print("promotionCrewReference to data failed line 514 Incident+Custom")
            }
            
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        promotionTag.promotionTagsCKR = data as NSObject
        
        
    }
    
    func newPromotionTagFromCloud(ckRecord: CKRecord) {
        
        let promotionTag = PromotionJournalTags(context: bkgrdContext)
        
        if let tag = ckRecord["tag"] as? String{
            promotionTag.tag = tag
        }
        if let guid = ckRecord["guid"] as? String{
            promotionTag.guid = UUID(uuidString: guid)
        }
        if let guid = ckRecord["promotionGuid"] as? String {
            promotionTag.promotionGuid = guid
           
                let result = promotionJournalA.filter { $0.projectGuid == guid }
                if !result.isEmpty {
                    if let theProject = result.last {
                        theProject.addToPromotionTag(promotionTag)
                    }
           
            }
        }
        
        
        
        let theProjectTagReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectTagReference, requiringSecureCoding: true)
            promotionTag.promotionTagsReference = data as NSObject
            
        } catch {
            print("promotionCrewReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        promotionTag.promotionTagsCKR = data as NSObject
        
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionJournalTags" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            promotionTagsA = try bkgrdContext.fetch(fetchRequest) as! [PromotionJournalTags]
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
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJProjectTagsSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjPromotionCrew])
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
