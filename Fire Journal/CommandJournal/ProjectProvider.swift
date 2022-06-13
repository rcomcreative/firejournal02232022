    //
    //  ProjectProvider.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/11/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //
import UIKit
import CoreData
import CloudKit

class ProjectProvider: NSObject {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var theProject: PromotionJournal!
    var theProjectCrew: PromotionCrew!
    var theProjectTags: PromotionJournalTags!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var theProjectR: CKRecord!
    var theProjectCrewR: CKRecord!
    var theProjectTagR: CKRecord!
    var theProjectTagCKRecords = [CKRecord]()
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func theProjectToCloud(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ theProject: PromotionJournal) -> Void)) {
        self.context = context
        self.theProject = self.context.object(with: objectID) as? PromotionJournal
        if let ckr = self.theProject.promotionJournalCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                self.theProjectR = CKRecord(coder: unarchiver)
                if let guid = self.theProject.guid {
                    self.theProjectR["guid"] = guid.uuidString
                }
                if self.theProject.projectPhotosAvailable {
                    self.theProjectR["projectPhotosAvailable"] = 1
                } else {
                    self.theProjectR["projectPhotosAvailable"] = 0
                }
                if self.theProject.locationAvailable {
                    self.theProjectR["locationAvailable"] = 1
                } else {
                    self.theProjectR["locationAvailable"] = 0
                }
                if self.theProject.projectTagsAvailable {
                    self.theProjectR["projectTagsAvailable"] = 1
                } else {
                    self.theProjectR["projectTagsAvailable"] = 0
                }
                if let overview = self.theProject.overview as? String {
                    self.theProjectR["overview"] = overview
                }
                if let projectGuid = self.theProject.projectGuid {
                    self.theProjectR["projectGuid"] = projectGuid
                }
                if let projectName = self.theProject.projectName {
                    self.theProjectR["projectName"] = projectName
                }
                if let projectType = self.theProject.projectType {
                    self.theProjectR["projectType"] = projectType
                }
                if let theDate = self.theProject.promotionDate {
                    self.theProjectR["promotionDate"] = theDate
                }
                if let studyClassNote = self.theProject.studyClassNote as? String {
                    self.theProjectR["studyClassNote"] = studyClassNote
                }
                if let theUTguid = self.theProject.userTimeGuid {
                    self.theProjectR["userTimeGuid"] = theUTguid
                }
                self.theProjectR["theEntity"] = "ProjectJournal"
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [self.theProjectR], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        self.theProjectR.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        self.theProject.promotionJournalCKR = data as NSObject
                        
                        do {
                            try self.context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionJournal save merge that"])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            print(error)
                        }
                        
                        completionHandler(self.theProject)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the promotionJournal operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(modifyCKOperation)
                
            } catch {
                print("nothing here ")
            }
        } else {
            if let guid = self.theProject.guid {
                let recordName = guid.uuidString
                let theProjectRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let theProjectRID = CKRecord.ID(recordName: recordName, zoneID: theProjectRZ.zoneID)
                self.theProjectR = CKRecord.init(recordType: "ProjectJournal", recordID: theProjectRID)
                let theProjectRef = CKRecord.Reference(recordID: theProjectRID, action: .deleteSelf)
                
                if let guid = self.theProject.guid {
                    self.theProjectR["guid"] = guid.uuidString
                }
                if let overview = self.theProject.overview as? String {
                    self.theProjectR["overview"] = overview
                }
                if let projectGuid = self.theProject.projectGuid {
                    self.theProjectR["projectGuid"] = projectGuid
                }
                if let projectName = self.theProject.projectName {
                    self.theProjectR["projectName"] = projectName
                }
                if let projectType = self.theProject.projectType {
                    self.theProjectR["projectType"] = projectType
                }
                if let theDate = self.theProject.promotionDate {
                    self.theProjectR["promotionDate"] = theDate
                }
                if let studyClassNote = self.theProject.studyClassNote as? String {
                    self.theProjectR["studyClassNote"] = studyClassNote
                }
                if let theUTguid = self.theProject.userTimeGuid {
                    self.theProjectR["userTimeGuid"] = theUTguid
                }
                if self.theProject.projectPhotosAvailable {
                    self.theProjectR["projectPhotosAvailable"] = 1
                } else {
                    self.theProjectR["projectPhotosAvailable"] = 0
                }
                if self.theProject.locationAvailable {
                    self.theProjectR["locationAvailable"] = 1
                } else {
                    self.theProjectR["locationAvailable"] = 0
                }
                if self.theProject.projectTagsAvailable {
                    self.theProjectR["projectTagsAvailable"] = 1
                } else {
                    self.theProjectR["projectTagsAvailable"] = 0
                }
                self.theProjectR["theEntity"] = "ProjectJournal"
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectRef, requiringSecureCoding: true)
                    self.theProject.promotionJournalReference = data as NSObject
                    
                } catch {
                    print("promotionJournalReference to data failed line 514 Incident+Custom")
                }
                
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                self.theProjectR.encodeSystemFields(with: coder)
                let data = coder.encodedData
                self.theProject.promotionJournalCKR = data as NSObject
                
                privateDatabase.save(self.theProjectR, completionHandler: { record, error in
                    
                    do {
                        try self.context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionJournal save merge that"])
                        }
                        
                        completionHandler(self.theProject)
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        print(error)
                    }
                    
                })
                
            }
        }
    }
    
    func theProjectCrewToCloud(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ theCrew: PromotionCrew) -> Void)) {
        self.context = context
        self.theProjectCrew = self.context.object(with: objectID) as? PromotionCrew
        if let ckr = self.theProjectCrew.promotionCrewCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                self.theProjectCrewR = CKRecord(coder: unarchiver)
                self.theProjectCrewR["theEntity"] = "ProjectCrew"
                if let firstName = self.theProjectCrew.first {
                    self.theProjectCrewR["first"] = firstName
                }
                if let fullName = self.theProjectCrew.fullName {
                    self.theProjectCrewR["fullName"] = fullName
                }
                if let guid = self.theProjectCrew.guid {
                    self.theProjectCrewR["guid"] = guid.uuidString
                }
                if let lastName = self.theProjectCrew.last {
                    self.theProjectCrewR["last"] = lastName
                }
                if let rank = self.theProjectCrew.rank {
                    self.theProjectCrewR["rank"] = rank
                }
                if let guid = self.theProjectCrew.promotionGuid {
                    self.theProjectCrewR["guid"] = guid.uuidString
                }
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [self.theProjectCrewR], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        self.theProjectR.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        self.theProjectCrew.promotionCrewCKR = data as NSObject
                        
                        do {
                            try self.context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionCrew save merge that"])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            print(error)
                        }
                        
                        completionHandler(self.theProjectCrew)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the promotionCrew operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(modifyCKOperation)
                
            } catch {
                print("nothing here ")
            }
        } else {
            
            if let guid = self.theProjectCrew.guid {
                let recordName = guid.uuidString
                let theProjectCrewRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let theProjectCrewRID = CKRecord.ID(recordName: recordName, zoneID: theProjectCrewRZ.zoneID)
                self.theProjectCrewR = CKRecord.init(recordType: "ProjectCrew", recordID: theProjectCrewRID)
                let theProjectCrewRef = CKRecord.Reference(recordID: theProjectCrewRID, action: .deleteSelf)
                
                self.theProjectCrewR["theEntity"] = "ProjectCrew"
                if let firstName = self.theProjectCrew.first {
                    self.theProjectCrewR["first"] = firstName
                }
                if let fullName = self.theProjectCrew.fullName {
                    self.theProjectCrewR["fullName"] = fullName
                }
                if let guid = self.theProjectCrew.guid {
                    self.theProjectCrewR["guid"] = guid.uuidString
                }
                if let lastName = self.theProjectCrew.last {
                    self.theProjectCrewR["last"] = lastName
                }
                if let rank = self.theProjectCrew.rank {
                    self.theProjectCrewR["rank"] = rank
                }
                if let guid = self.theProjectCrew.promotionGuid {
                    self.theProjectCrewR["guid"] = guid.uuidString
                }
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectCrewRef, requiringSecureCoding: true)
                    self.theProjectCrew.promotionCrewReference = data as NSObject
                    
                } catch {
                    print("promotionCrewReference to data failed line 514 Incident+Custom")
                }
                
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                self.theProjectCrewR.encodeSystemFields(with: coder)
                let data = coder.encodedData
                self.theProjectCrew.promotionCrewCKR = data as NSObject
                
                privateDatabase.save(self.theProjectCrewR, completionHandler: { record, error in
                    
                    do {
                        try self.context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionCrew save merge that"])
                        }
                        
                        completionHandler(self.theProjectCrew)
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        print(error)
                    }
                    
                })
                
            }
        }
    }
    
    func theProjectTagsToCloud(_ context: NSManagedObjectContext, _ objectIDs: [NSManagedObjectID], completionHandler: ( @escaping (_ theTags: [CKRecord]) -> Void )) {
        self.context = context
        self.theProjectTagCKRecords.removeAll()
        for objectID in objectIDs {
            self.theProjectTagR = nil
            self.theProjectTags = nil
            self.theProjectTags = self.context.object(with: objectID) as? PromotionJournalTags
            if let ckr = self.theProjectTags.promotionTagsCKR {
                guard let  archivedData = ckr as? Data else { return }
                do {
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                    self.theProjectTagR = CKRecord(coder: unarchiver)
                    self.theProjectTagR["theEntity"] = "ProjectTags"
                    if let tag = self.theProjectTags.tag {
                        self.theProjectTagR["tag"] = tag
                    }
                    if let guid = self.theProjectTags.guid {
                        self.theProjectTagR["guid"] = guid.uuidString
                    }
                    if let guid = self.theProjectTags.promotionGuid {
                        self.theProjectTagR["promotionGuid"] = guid
                    }
                    
                } catch {
                    print("nothing here ")
                }
                
            } else {
                
                if let guid = self.theProjectTags.guid {
                    let recordName = guid.uuidString
                    let theProjectTagRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                    let theProjectTagRID = CKRecord.ID(recordName: recordName, zoneID: theProjectTagRZ.zoneID)
                    self.theProjectTagR = CKRecord.init(recordType: "ProjectTags", recordID: theProjectTagRID)
                    let theProjectTagRef = CKRecord.Reference(recordID: theProjectTagRID, action: .deleteSelf)
                    self.theProjectTagR["theEntity"] = "ProjectTags"
                    if let tag = self.theProjectTags.tag {
                        self.theProjectTagR["tag"] = tag
                    }
                    if let guid = self.theProjectTags.guid {
                        self.theProjectTagR["guid"] = guid.uuidString
                    }
                    if let guid = self.theProjectTags.promotionGuid {
                        self.theProjectTagR["promotionGuid"] = guid
                    }
                    
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectTagRef, requiringSecureCoding: true)
                        self.theProjectTags.promotionTagsReference = data as NSObject
                        
                    } catch {
                        print("promotionTagsReference to data failed line 514 Incident+Custom")
                    }
                    
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    self.theProjectTagR.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.theProjectTags.promotionTagsCKR = data as NSObject
            }
            }
            theProjectTagCKRecords.append(self.theProjectTagR)
        }
            let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: theProjectTagCKRecords, recordIDsToDelete: nil)
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
                    
                    completionHandler(self.theProjectTagCKRecords)
                case .failure(let error):
                    DispatchQueue.main.async {
                        completionHandler(self.theProjectTagCKRecords)
                        let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                        print("here is the promotionTags operation error \(error)")
                    }
                }
            }
            
            privateDatabase.add(modifyCKOperation)
        
    }
    
    func theProjectTagToCloud(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ theTag: PromotionJournalTags) -> Void)) {
        self.context = context
        self.theProjectTags = self.context.object(with: objectID) as? PromotionJournalTags
        if let ckr = self.theProjectTags.promotionTagsCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                self.theProjectTagR = CKRecord(coder: unarchiver)
                self.theProjectTagR["theEntity"] = "ProjectTags"
                if let tag = self.theProjectTags.tag {
                    self.theProjectTagR["tag"] = tag
                }
                if let guid = self.theProjectTags.guid {
                    self.theProjectTagR["guid"] = guid.uuidString
                }
                if let guid = self.theProjectTags.promotionGuid {
                    self.theProjectTagR["promotionGuid"] = guid
                }
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [self.theProjectTagR], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        self.theProjectTagR.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        self.theProjectTags.promotionTagsCKR = data as NSObject
                        
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
                        
                        completionHandler(self.theProjectTags)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the promotionTags operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(modifyCKOperation)
                
            } catch {
                print("nothing here ")
            }
            
        } else {
            
            if let guid = self.theProjectTags.guid {
                let recordName = guid.uuidString
                let theProjectTagRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let theProjectTagRID = CKRecord.ID(recordName: recordName, zoneID: theProjectTagRZ.zoneID)
                self.theProjectTagR = CKRecord.init(recordType: "ProjectTags", recordID: theProjectTagRID)
                let theProjectTagRef = CKRecord.Reference(recordID: theProjectTagRID, action: .deleteSelf)
                self.theProjectTagR["theEntity"] = "ProjectTags"
                if let tag = self.theProjectTags.tag {
                    self.theProjectTagR["tag"] = tag
                }
                if let guid = self.theProjectTags.guid {
                    self.theProjectTagR["guid"] = guid.uuidString
                }
                if let guid = self.theProjectTags.promotionGuid {
                    self.theProjectTagR["promotionGuid"] = guid
                }
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: theProjectTagRef, requiringSecureCoding: true)
                    self.theProjectTags.promotionTagsReference = data as NSObject
                    
                } catch {
                    print("promotionTagsReference to data failed line 514 Incident+Custom")
                }
                
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                self.theProjectTagR.encodeSystemFields(with: coder)
                let data = coder.encodedData
                self.theProjectTags.promotionTagsCKR = data as NSObject
                
                privateDatabase.save(self.theProjectTagR, completionHandler: { record, error in
                    
                    do {
                        try self.context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionTags save merge that"])
                        }
                        
                        completionHandler(self.theProjectTags)
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        print(error)
                    }
                    
                })
            }
        }
    }
    
}
