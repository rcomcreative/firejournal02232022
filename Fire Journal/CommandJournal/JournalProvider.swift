//
//  JournalProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/19/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import CoreData
import CloudKit

class JournalProvider: NSObject {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var theJournal: Journal!
    var theJournalTags: JournalTags!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var theJournalR: CKRecord!
    var theJournalTagR: CKRecord!
    var theJournalTagCKRecords = [CKRecord]()
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func theJournalTagsToCloud(_ context: NSManagedObjectContext, _ objectIDs: [NSManagedObjectID], completionHandler: ( @escaping ( _ theTags: [CKRecord]) -> Void )) {
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        self.context = context
        self.theJournalTagCKRecords.removeAll()
        for objectID in objectIDs {
            
            self.theJournalTags = nil
            self.ckRecord = nil
            
            self.theJournalTags = self.context.object(with: objectID) as? JournalTags
            if let ckr = self.theJournalTags.journalTagCKR {
                guard let  archivedData = ckr as? Data else { return }
                do {
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                    self.ckRecord = CKRecord(coder: unarchiver)
                    self.ckRecord["TheEntity"] = "JournalTags"
                    if let tag = self.theJournalTags.journalTag {
                    self.ckRecord["journalTag"] = tag
                    }
                    if let journalGuid = self.theJournalTags.fjpJournalReference {
                    self.ckRecord["fjpJournalReference"] = journalGuid
                    }
                    if let guid = self.theJournalTags.journalGuid {
                        self.ckRecord["fjpJournalReference"] = guid
                    }
                } catch {
                    print("nothing here ")
                }
                
            } else {
                if let guid = self.theJournalTags.journalGuid {
                    let recordName = guid
                    let theJournalTagRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                    let theJournalTagRID = CKRecord.ID(recordName: recordName, zoneID: theJournalTagRZ.zoneID)
                    self.ckRecord = CKRecord.init(recordType: "JournalTags", recordID: theJournalTagRID)
                    let theJournalTagRef = CKRecord.Reference(recordID: theJournalTagRID, action: .deleteSelf)
                    self.ckRecord["TheEntity"] = "JournalTags"
                    if let tag = self.theJournalTags.journalTag {
                    self.ckRecord["journalTag"] = tag
                    }
                    if let journalGuid = self.theJournalTags.fjpJournalReference {
                    self.ckRecord["fjpJournalReference"] = journalGuid
                    }
                    if let guid = self.theJournalTags.journalGuid {
                        self.ckRecord["journalGuid"] = guid
                    }
                    
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: theJournalTagRef, requiringSecureCoding: true)
                        self.theJournalTags.aJournalTagReferenceSC = data as NSObject
                        
                    } catch {
                        print("journalTagsReference to data failed line 514 Incident+Custom")
                    }
                    
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    self.ckRecord.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.theJournalTags.journalTagCKR = data as NSObject
                    
                }
            }
            self.theJournalTagCKRecords.append(ckRecord)
        }
        
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: theJournalTagCKRecords, recordIDsToDelete: nil)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                
                do {
                    try self.context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionTags save merge that"])
                    }
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                }
                
                completionHandler(self.theJournalTagCKRecords)
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(self.theJournalTagCKRecords)
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the journalTags operation error \(error)")
                }
            }
        }
        
        privateDatabase.add(modifyCKOperation)
        
        
        
    }
    
}
