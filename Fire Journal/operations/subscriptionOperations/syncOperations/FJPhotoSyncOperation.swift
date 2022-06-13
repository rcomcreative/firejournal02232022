    //
    //  FJPhotoSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJPhotoSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var photoA = [Photo]()
    var ckRecordA = [CKRecord]()
    var thePhoto: Photo!
    var theJournalsA = [Journal]()
    var theIncidentsA = [Incident]()
    var theProjectsA = [PromotionJournal]()
    var theStaffA = [UserAttendees]()
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
        getTheStaff()
        getTheJournals()
        getTheIncidents()
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
            print("here is new photo")
            newPhotoFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["guid"] as? String  {
                let result = photoA.filter { $0.guid == UUID(uuidString: guid) }
                if result.isEmpty {
                    print("here is new photo")
                    newPhotoFromCloud(ckRecord: record)
                } else {
                    thePhoto = result.last
                    print("here is modified photo")
                    updatePhotoFromCloud(ckRecord: record, thePhoto: thePhoto)
                }
            }
        }
        completion()
    }
    
    func updatePhotoFromCloud(ckRecord: CKRecord, thePhoto: Photo) {
        
        if let guid = ckRecord["guid"] as? String {
            thePhoto.guid = UUID(uuidString: guid)
        }
        if let theDate = ckRecord["photoDate"] as? Date {
            thePhoto.photoDate = theDate
        }
        
        if let asset = ckRecord["image"] as? CKAsset {
            if let data = imageDataFromCloudKit(asset: asset)  {
                let thumbnail = Photo.thumbnail(from: data, thumbnailPixelSize: 80)
                thePhoto.image = thumbnail
            }
        }
        
        if let sGuid = ckRecord["userAttendeeGuid"] as? String {
            let guid = UUID(uuidString: sGuid)
            let result = theStaffA.filter { $0.staffGuid == guid}
            if !result.isEmpty {
                thePhoto.userAttendeeGuid = guid
            }
        }
        
        if let jGuid = ckRecord["journalGuid"] as? String {
            let guid = UUID(uuidString: jGuid)
            let result = theJournalsA.filter { $0.journalGuid == guid}
            if !result.isEmpty {
                thePhoto.journalGuid = guid
            }
        }
        
        if let iGuid = ckRecord["incidentGuid"] as? String {
            let guid = UUID(uuidString: iGuid)
            let result = theIncidentsA.filter { $0.incidentGuid == guid}
            if !result.isEmpty {
                thePhoto.incidentGuid = guid
            }
        }
        
        
        if let pGuid = ckRecord["promotionGuid"] as? String {
            let result = theProjectsA.filter { $0.projectGuid == pGuid}
            if !result.isEmpty {
                thePhoto.promotionGuid = pGuid
            }
        }
        
        if thePhoto.photoReference == nil {
            let thePhotoReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: thePhotoReference, requiringSecureCoding: true)
                thePhoto.photoReference = data as NSObject
                
            } catch {
                print("tagReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        thePhoto.photoCKR = data as NSObject
        
    }
    
    
    func newPhotoFromCloud(ckRecord: CKRecord) {
        
        let thePhoto = Photo(context: bkgrdContext)
        if let guid = ckRecord["guid"] as? String {
            thePhoto.guid = UUID(uuidString: guid)
        }
        if let theDate = ckRecord["photoDate"] as? Date {
            thePhoto.photoDate = theDate
        }
        
        if let asset = ckRecord["image"] as? CKAsset {
            if let data = imageDataFromCloudKit(asset: asset)  {
                if !data.isEmpty {
                    let thumbnail = Photo.thumbnail(from: data, thumbnailPixelSize: 80)
                    thePhoto.image = thumbnail
                }
            }
        }
        
        if let sGuid = ckRecord["userAttendeeGuid"] as? String {
            let guid = UUID(uuidString: sGuid)
            let result = theStaffA.filter { $0.staffGuid == guid}
            if !result.isEmpty {
                thePhoto.userAttendeeGuid = guid
            }
        }
        
        if let jGuid = ckRecord["journalGuid"] as? String {
            let guid = UUID(uuidString: jGuid)
            let result = theJournalsA.filter { $0.journalGuid == guid}
            if !result.isEmpty {
                thePhoto.journalGuid = guid
            }
        }
        
        if let iGuid = ckRecord["incidentGuid"] as? String {
            let guid = UUID(uuidString: iGuid)
            let result = theIncidentsA.filter { $0.incidentGuid == guid}
            if !result.isEmpty {
                thePhoto.incidentGuid = guid
            }
        }
        
        
        if let pGuid = ckRecord["promotionGuid"] as? String {
            let result = theProjectsA.filter { $0.projectGuid == pGuid}
            if !result.isEmpty {
                thePhoto.promotionGuid = pGuid
            }
        }
        
        let thePhotoReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: thePhotoReference, requiringSecureCoding: true)
            thePhoto.photoReference = data as NSObject
            
        } catch {
            print("tagReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        thePhoto.photoCKR = data as NSObject
        
    }
    
        //    MARK: -Image from CloudKit to CoreData
        /// Take CKAsset from CloudKit -signature, move it to Data
        /// - Parameter asset: CKAsset
        /// - Returns: Data object
    func imageDataFromCloudKit(asset: CKAsset) -> Data? {
        var data: Data!
        do {
            data = try Data(contentsOf: asset.fileURL!)
            return data
        } catch {
            print("error in return image f")
        }
        return data
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            photoA = try bkgrdContext.fetch(fetchRequest) as! [Photo]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
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
    
    func getTheStaff() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees" )
        do {
            theStaffA = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
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
                                 userInfo: ["recordEntity":TheEntities.fjImageData])
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
