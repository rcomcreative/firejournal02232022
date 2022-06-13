    //
    //  FJProjectJournalSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJProjectJournalSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var promotionJournalA = [PromotionJournal]()
    var theUserTimeA = [UserTime]()
    var ckRecordA = [CKRecord]()
    var thePromotionJournal: PromotionJournal!
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
            print("Project here new")
            newProjectJournalFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                
                let result = promotionJournalA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    print("Project here empty")
                    newProjectJournalFromCloud(ckRecord: record)
                } else {
                    thePromotionJournal = result.last
                    print("project herre exists")
                    updateThePromotionJournal(ckRecord: record, theProjectJournal: thePromotionJournal)
                }
            }
            
        }
        completion()
    }
    
    func updateThePromotionJournal(ckRecord: CKRecord, theProjectJournal: PromotionJournal ) {
        
        if let guid = ckRecord["guid"] as? String {
            theProjectJournal.guid   = UUID(uuidString: guid)
        }
        if let overview =  ckRecord["overview"] as? String {
            theProjectJournal.overview = overview as NSObject
        }
        if let projectGuid = ckRecord["projectGuid"] as? String {
            theProjectJournal.projectGuid = projectGuid
        }
        if let projectName = ckRecord["projectName"] as? String {
            theProjectJournal.projectName = projectName
        }
        if let projectType =  ckRecord["projectType"] as? String {
            theProjectJournal.projectType = projectType
        }
        if let theDate = ckRecord["promotionDate"] as? Date {
            theProjectJournal.promotionDate = theDate
        }
        if let studyClassNote = ckRecord["studyClassNote"] as? String {
            theProjectJournal.studyClassNote = studyClassNote as NSObject
        }
        if let projectPhotosAvailable = ckRecord["projectPhotosAvailable"] as? Double {
            if projectPhotosAvailable == 1 {
            theProjectJournal.projectPhotosAvailable = true
            } else {
                theProjectJournal.projectPhotosAvailable = false
            }
        }
        if let locationAvailable = ckRecord["locationAvailable"] as? Double {
            if locationAvailable == 1 {
                theProjectJournal.locationAvailable = true
            } else {
                theProjectJournal.locationAvailable = false
            }
        }
        if let projectTagsAvailable = ckRecord["projectTagsAvailable"] as? Double {
            if projectTagsAvailable == 1 {
                theProjectJournal.projectTagsAvailable = true
            } else {
                theProjectJournal.projectTagsAvailable = false
            }
        }
        
        if let theUTguid = ckRecord["userTimeGuid"] as? String {
            theProjectJournal.userTimeGuid = theUTguid
            if theProjectJournal.user == nil {
                let result = theUserTimeA.filter { $0.userTimeGuid == theUTguid }
                if !result.isEmpty {
                    if let theUserTime = result.last {
                        theUserTime.addToPromotion(theProjectJournal)
                    }
                }
            }
        }
        
        if theProjectJournal.user == nil {
            if theUser != nil {
                theUser.addToPromotion(theProjectJournal)
            }
        }
        
        if theProjectJournal.promotionJournalReference == nil {
            let theProjectJournalReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectJournalReference, requiringSecureCoding: true)
                theProjectJournal.promotionJournalReference = data as NSObject
                
            } catch {
                print("promotionJournalReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theProjectJournal.promotionJournalCKR = data as NSObject
        
        
    }
    
    func newProjectJournalFromCloud(ckRecord: CKRecord) {
        
        let theProjectJournal = PromotionJournal(context: bkgrdContext)
        if let guid = ckRecord["guid"] as? String {
            theProjectJournal.guid   = UUID(uuidString: guid)
        }
        if let overview =  ckRecord["overview"] as? String {
            theProjectJournal.overview = overview as NSObject
        }
        if let projectGuid = ckRecord["projectGuid"] as? String {
            theProjectJournal.projectGuid = projectGuid
        }
        if let projectName = ckRecord["projectName"] as? String {
            theProjectJournal.projectName = projectName
        }
        if let projectType =  ckRecord["projectType"] as? String {
            theProjectJournal.projectType = projectType
        }
        if let theDate = ckRecord["promotionDate"] as? Date {
            theProjectJournal.promotionDate = theDate
        }
        if let studyClassNote = ckRecord["studyClassNote"] as? String {
            theProjectJournal.studyClassNote = studyClassNote as NSObject
        }
        if let projectPhotosAvailable = ckRecord["projectPhotosAvailable"] as? Double {
            if projectPhotosAvailable == 1 {
            theProjectJournal.projectPhotosAvailable = true
            } else {
                theProjectJournal.projectPhotosAvailable = false
            }
        }
        if let locationAvailable = ckRecord["locationAvailable"] as? Double {
            if locationAvailable == 1 {
                theProjectJournal.locationAvailable = true
            } else {
                theProjectJournal.locationAvailable = false
            }
        }
        if let projectTagsAvailable = ckRecord["projectTagsAvailable"] as? Double {
            if projectTagsAvailable == 1 {
                theProjectJournal.projectTagsAvailable = true
            } else {
                theProjectJournal.projectTagsAvailable = false
            }
        }
        if let theUTguid = ckRecord["userTimeGuid"] as? String {
            theProjectJournal.userTimeGuid = theUTguid
            let result = theUserTimeA.filter { $0.userTimeGuid == theUTguid }
            if !result.isEmpty {
                if let theUserTime = result.last {
                    theUserTime.addToPromotion(theProjectJournal)
                }
            }
        }
        
        if theUser != nil {
            theUser.addToPromotion(theProjectJournal)
        }
        
        let theProjectJournalReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectJournalReference, requiringSecureCoding: true)
            theProjectJournal.promotionJournalReference = data as NSObject
            
        } catch {
            print("promotionJournalReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theProjectJournal.promotionJournalCKR = data as NSObject
        
    }
    
    func getTheUserTime() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTime" )
        do {
            theUserTimeA = try bkgrdContext.fetch(fetchRequest) as! [UserTime]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
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
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionJournal" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            promotionJournalA = try bkgrdContext.fetch(fetchRequest) as! [PromotionJournal]
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
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJProjectJournalSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjPromotionTags])
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
