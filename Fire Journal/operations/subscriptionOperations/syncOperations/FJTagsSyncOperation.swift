    //
    //  FJTagsSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJTagsSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var tagsA = [Tag]()
    var ckRecordA = [CKRecord]()
    var theTag: Tag!
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
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
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
            buildNewTagFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                let result = tagsA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    buildNewTagFromCloud(record: record)
                } else {
                    theTag = result.last
                    updateTagFromCloud(record: record, theTag: theTag)
                }
            }
        }
        completion()
    }
    
    func updateTagFromCloud(record: CKRecord, theTag: Tag) {
        
        if let guid = record["guid"] as? String {
            theTag.guid = UUID(uuidString: guid)
        }
        if let tag = record["name"] as? String {
            theTag.name = tag
        }
        
        if theTag.tagReference == nil {
            let theTagReference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theTagReference, requiringSecureCoding: true)
                theTag.tagReference = data as NSObject
                
            } catch {
                print("tagReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theTag.tagCKR = data as NSObject
        
        
    }
    
    func buildNewTagFromCloud(record: CKRecord) {
        
        let theTag = Tag(context: bkgrdContext)
        if let guid = record["guid"] as? String {
            theTag.guid = UUID(uuidString: guid)
        }
        if let tag = record["name"] as? String {
            theTag.name = tag
        }
        
        let theTagReference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theTagReference, requiringSecureCoding: true)
            theTag.tagReference = data as NSObject
            
        } catch {
            print("tagReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theTag.tagCKR = data as NSObject
        
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            tagsA = try bkgrdContext.fetch(fetchRequest) as! [Tag]
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
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJTagsSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjFCLocation])
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
