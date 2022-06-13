    //
    //  PhotoProvider.swift
    //  StationCommand
    //
    //  Created by DuRand Jones on 7/8/21.
    //

import UIKit
import CoreData
import CloudKit

class PhotoProvider: NSObject {
    
    private(set) var persistentContainer: NSPersistentContainer
    
    let nc = NotificationCenter.default
    var context: NSManagedObjectContext!
    var photo: Photo!
    var staff: UserAttendees!
    var theIncident: Incident!
    var theJournal: Journal!
    var theProject: PromotionJournal!
    var theImageData: ImageData!
    var theType: IncidentTypes!
    var photoR: CKRecord!
    var imageDataR: CKRecord!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    
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
    
//    MARK: -ADDPHOTO to Journal
    func addPhotoToJournal(imageData: Data, imageURL: URL, journalid: NSManagedObjectID, taskContext: NSManagedObjectContext, shouldSave: Bool = true, completionBlock: () -> ()) {
        self.context = taskContext
        self.theJournal = self.context.object(with: journalid) as? Journal
        self.theType = .journal
        let thumbnailImage = Photo.thumbnail(from: imageData, thumbnailPixelSize: 80)
        var destinationURL: URL? // to hold the attachment.imageURL for later use
        
        taskContext.performAndWait {
            photo = Photo(context: taskContext)
            photo.journalGuid = self.theJournal.journalGuid
            photo.photoDate = Date()
            photo.guid = UUID()
            self.theJournal.journalPhotoTaken = true
            photo.journal = self.theJournal
            photo.image = thumbnailImage // transient
            
//            imageData
            
            theImageData = ImageData(context: taskContext)
            theImageData.data = imageData
            theImageData.photoGuid = photo.guid
            photo.imageData = theImageData
            
            if shouldSave {
                save(context: taskContext)
            }
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
        }
        DispatchQueue.global().async {
            self.buildPhotoCKRecord(self.context, self.photo.objectID) { photo in
            print("here is the photo saved to cloud \(photo)")
        }
        }
        
        DispatchQueue.global().async {
            self.buildImageDataCKRecord(self.context, self.theImageData.objectID) {
            imageData in
            print("here is the imageData saved to cloud \(imageData)")
        }
        }
        
        DispatchQueue.global().async {
            var nsError: NSError?
            NSFileCoordinator().coordinate(writingItemAt: destinationURL!, options: .forReplacing, error: &nsError,
                                           byAccessor: { (newURL: URL) -> Void in
                do {
                    try imageData.write(to: newURL, options: .atomic)
                } catch {
                    print("###\(#function): Failed to save an image file: \(destinationURL!)")
                }
            })
            if let nsError = nsError {
                print("###\(#function): \(nsError.localizedDescription)")
            }
        }
        completionBlock()
    }
    
    func addPhotoToProject(imageData: Data, imageURL: URL, projectID: NSManagedObjectID, taskContext: NSManagedObjectContext, shouldSave: Bool = true, completionBlock: () -> () ) {
        self.context = taskContext
        self.theProject = self.context.object(with: projectID) as? PromotionJournal
        self.theType = .theProject
        let thumbnailImage = Photo.thumbnail(from: imageData, thumbnailPixelSize: 80)
        var destinationURL: URL? // to hold the attachment.imageURL for later use
        
        taskContext.performAndWait {
            photo = Photo(context: taskContext)
            photo.promotionGuid = self.theProject.projectGuid
            photo.photoDate = Date()
            photo.guid = UUID()
            self.theProject.addToPhotos(photo)
            photo.image = thumbnailImage // transient
            
//            imageData
            
            theImageData = ImageData(context: taskContext)
            theImageData.data = imageData
            theImageData.photoGuid = photo.guid
            photo.imageData = theImageData
            
            if shouldSave {
                save(context: taskContext)
            }
            
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
        }
        
        DispatchQueue.global().async {
            self.buildPhotoCKRecord(self.context, self.photo.objectID) { photo in
            print("here is the photo saved to cloud \(photo)")
        }
        }
        
        DispatchQueue.global().async {
            self.buildImageDataCKRecord(self.context, self.theImageData.objectID) {
            imageData in
            print("here is the imageData saved to cloud \(imageData)")
        }
        }
        
        DispatchQueue.global().async {
            var nsError: NSError?
            NSFileCoordinator().coordinate(writingItemAt: destinationURL!, options: .forReplacing, error: &nsError,
                                           byAccessor: { (newURL: URL) -> Void in
                do {
                    try imageData.write(to: newURL, options: .atomic)
                } catch {
                    print("###\(#function): Failed to save an image file: \(destinationURL!)")
                }
            })
            if let nsError = nsError {
                print("###\(#function): \(nsError.localizedDescription)")
            }
        }
        completionBlock()
    }
    
//    MARK: -ADDPHOTO to INcidents
    func addPhotoIncident(imageData: Data, imageURL: URL, incidentid: NSManagedObjectID, taskContext: NSManagedObjectContext, shouldSave: Bool = true, completionBlock: @escaping (_ incidentid: NSManagedObjectID) -> Void ) {
        self.context = taskContext
        self.theIncident = self.context.object(with: incidentid) as? Incident
        self.theType = .allIncidents
        let thumbnailImage = Photo.thumbnail(from: imageData, thumbnailPixelSize: 80)
        var destinationURL: URL? // to hold the attachment.imageURL for later use
        
        self.context.performAndWait {
            photo = Photo(context: self.context)
            photo.incidentGuid = self.theIncident.incidentGuid
            photo.photoDate = Date()
            photo.guid = UUID()
            self.theIncident.incidentPhotoTaken = true
            self.theIncident.addToPhoto(photo)
            photo.image = thumbnailImage // transient
            
            theImageData = ImageData(context: self.context)
            theImageData.data = imageData
            theImageData.photoGuid = photo.guid
            photo.imageData = theImageData
            if shouldSave {
                save(context: self.context)
            }
            
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
        }
        
        DispatchQueue.global().async {
            self.buildPhotoCKRecord(self.context, self.photo.objectID) { photo in
            print("here is the photo saved to cloud \(photo)")
        }
        }
        
        DispatchQueue.global().async {
            self.buildImageDataCKRecord(self.context, self.theImageData.objectID) {
            imageData in
            print("here is the imageData saved to cloud \(imageData)")
        }
        }
        
        DispatchQueue.global().async {
            var nsError: NSError?
            NSFileCoordinator().coordinate(writingItemAt: destinationURL!, options: .forReplacing, error: &nsError,
                                           byAccessor: { (newURL: URL) -> Void in
                do {
                    try imageData.write(to: newURL, options: .atomic)
                } catch {
                    print("###\(#function): Failed to save an image file: \(destinationURL!)")
                }
            })
            if let nsError = nsError {
                print("###\(#function): \(nsError.localizedDescription)")
            }
        }
        completionBlock(incidentid)
        
    }
    
        //    MARK:- AddPhoto for UserAttendees
    /**
     Create a Photo. Note that ".thumbnail" is a transient attribute and is not persisted to the store.
     */
    func addPhotoStaff(imageData: Data, imageURL: URL, staff: UserAttendees, taskContext: NSManagedObjectContext,
                       shouldSave: Bool = true,logo: Bool) {
        self.staff = staff
        self.context = taskContext
        self.theType = .deptMember
        let thumbnailImage = Photo.thumbnail(from: imageData, thumbnailPixelSize: 80)
        var destinationURL: URL? // to hold the attachment.imageURL for later use
        
        taskContext.performAndWait {
            photo = Photo(context: taskContext)
            photo.userAttendeeGuid = staff.staffGuid
            photo.photoDate = Date()
            photo.guid = UUID()
            staff.photoAvailable = true
            staff.photo = photo
            photo.image = thumbnailImage // transient
            
            theImageData = ImageData(context: self.context)
            theImageData.data = imageData
            theImageData.photoGuid = photo.guid
            photo.imageData = theImageData
            
            if shouldSave {
                save(context: taskContext)
            }
            
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
        }
        
        DispatchQueue.global().async {
            self.buildPhotoCKRecord(self.context, self.photo.objectID) { photo in
            print("here is the photo saved to cloud \(photo)")
        }
        }
        
        DispatchQueue.global().async {
            self.buildImageDataCKRecord(self.context, self.theImageData.objectID) {
            imageData in
            print("here is the imageData saved to cloud \(imageData)")
        }
        }
        
        DispatchQueue.global().async {
            var nsError: NSError?
            NSFileCoordinator().coordinate(writingItemAt: destinationURL!, options: .forReplacing, error: &nsError,
                                           byAccessor: { (newURL: URL) -> Void in
                do {
                    try imageData.write(to: newURL, options: .atomic)
                } catch {
                    print("###\(#function): Failed to save an image file: \(destinationURL!)")
                }
            })
            if let nsError = nsError {
                print("###\(#function): \(nsError.localizedDescription)")
            }
        }
        
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Photo save merge that"])
            }
            if theType != nil {
                switch theType {
                case .deptMember:
                    DispatchQueue.main.async {
                            let objectID = self.staff.objectID
                            self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
                    }
                case .allIncidents:
                    DispatchQueue.main.async {
                            let objectID = self.theIncident.objectID
                            self.nc.post(name: NSNotification.Name(rawValue: FJkCKModifiedIncidentsToCloud), object: nil, userInfo:["objectIDs": [objectID]])
                    }
                case .journal:
                    DispatchQueue.main.async {
                            let objectID = self.theJournal.objectID
                            self.nc.post(name: NSNotification.Name(rawValue: FJkCKModifiedJournalsToCloud), object: nil, userInfo:["objectID":objectID])
                    }
                default: break
                }
            }
                    } catch let error as NSError {
            let theError: String = error.localizedDescription
            let error = "There was an error in saving " + theError
            print(error)
        }
    }
    
    func buildPhotoCKRecord(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ photo: Photo) -> Void)) {
        var asset: CKAsset!
        self.context = context
        self.photo = self.context.object(with: objectID) as? Photo
        if let guid = photo.guid {
                let recordName = guid.uuidString
                let photoRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let photoRID = CKRecord.ID(recordName: recordName, zoneID: photoRZ.zoneID)
                photoR = CKRecord.init(recordType: "Photo", recordID: photoRID)
                let photoRef = CKRecord.Reference(recordID: photoRID, action: .deleteSelf)
            if let guid = self.photo.incidentGuid {
                photoR["incidentGuid"] = guid.uuidString
            }
            if let guid = self.photo.journalGuid {
                photoR["journalGuid"] = guid.uuidString
            }
            if let guid = self.photo.promotionGuid {
                photoR["promotionGuid"] = guid
            }
            if let guid = self.photo.userAttendeeGuid {
                photoR["userAttendeeGuid"] = guid.uuidString
            }
            if let theDate = self.photo.photoDate {
                photoR["photoDate"] = theDate
            }
            guard let theGuid = photo.guid else { return }
            let destinationURL = photo.assetURL(guid: theGuid)
            if let image = photo.image {
            asset = createAsset(image, destinationURL)
                if asset != nil {
                    photoR["image"] = asset
                }
            }
            photoR["theEntity"] = "Photo"
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: photoRef, requiringSecureCoding: true)
                self.photo.photoReference = data as NSObject
                
            } catch {
                print("photoReference to data failed line 514 Incident+Custom")
            }
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            photoR.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.photo.photoCKR = data as NSObject
            
            privateDatabase.save(photoR, completionHandler: { record, error in
                if error != nil {
                    print("error \(error?.localizedDescription)")
                } else {
                    print("here is the photo record \(record)")
                }
                do {
                    try self.context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"photo save merge that"])
                    }
                    completionHandler(self.photo)
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                }
                
            })
        }
        
    }
    
    func createAsset(_ image: UIImage, _ url: URL) -> CKAsset {
        var asset: CKAsset!
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: url)
                print("file saved")
                asset = CKAsset.init(fileURL: url)
            } catch {
                print("Error trying to saving resident image to directory \(error)")
            }
        }
        return asset
    }
    
    func buildImageDataCKRecord(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ imageData: ImageData) -> Void)) {
        var asset: CKAsset!
        self.context = context
        theImageData = self.context.object(with: objectID) as? ImageData
        photo = theImageData.attachment
        if let guid = theImageData.photoGuid {
            let recordName = guid.uuidString
            let imageDataRZ = CKRecordZone.init(zoneName: "FireJournalShare")
            let imageDataRID = CKRecord.ID(recordName: recordName, zoneID: imageDataRZ.zoneID)
            imageDataR = CKRecord.init(recordType: "ImageData", recordID: imageDataRID)
            let imageDataRef = CKRecord.Reference(recordID: imageDataRID, action: .deleteSelf)
            imageDataR["theEntity"] = "ImageData"
            imageDataR["photoGuid"] = recordName
            let destinationURL = photo.assetURL(guid: theImageData.photoGuid!)
            if theImageData.data != nil {
                if let image = UIImage.init(data: theImageData.data!) {
                    asset = createAsset(image, destinationURL)
                    if asset != nil {
                        imageDataR["data"] = asset
                    }
                }
            }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: imageDataRef, requiringSecureCoding: true)
                self.theImageData.imageDataReference = data as NSObject
                
            } catch {
                print("imageDataReference to data failed line 514 Incident+Custom")
            }
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            imageDataR.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.theImageData.imageDataCKR = data as NSObject
            
            privateDatabase.save(imageDataR, completionHandler: { record, error in
                
                do {
                    try self.context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"imageData save merge that"])
                    }
                    completionHandler(self.theImageData)
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                }
                
            })
        }
    }

    
    
    /**
     Cache the image data of the newly-created attachment in a local file.
     
     Save to the store for synchronization only when the post is saved.
     */
    func saveImageDataiIfNeeded(for attachments: NSSet, taskContext: NSManagedObjectContext,
                                completionHandler: (() -> Void)? = nil) {
        self.context = taskContext
        guard let attachments = attachments.allObjects as? [Photo] else {
            completionHandler?()
            return
        }
            // Filter out attachments from previous editing sessions
        let newAttachments = attachments.filter { return $0.imageData == nil }
        
        guard !newAttachments.isEmpty else {
            completionHandler?()
            return
        }
        
        var newAttachmentCount = newAttachments.count
        for attachment in newAttachments {
            
            guard let theGuid = attachment.guid else { return }
            
            let fileURL = attachment.imageURL(guid: theGuid)
            var data: Data?
            
            var nsError: NSError?
            NSFileCoordinator().coordinate(
                readingItemAt: fileURL, options: .withoutChanges, error: &nsError, byAccessor: { (newURL: URL) -> Void in
                data = UIImage(contentsOfFile: newURL.path)?.jpegData(compressionQuality: 1)
            }
            )
            
            if let nsError = nsError {
                print("###\(#function): \(nsError.localizedDescription)")
            }
            
            guard data != nil else {
                print("###\(#function): Failed to read full image data for attachment: \(attachment)")
                return
            }
            
                //            Load image data using a taskContext. Reset the context after saving each image.
            let attachmentObjectID = attachment.objectID
            self.context.perform {
                guard let attachment = self.context.object(with: attachmentObjectID) as? Photo else { return }
                
                
                let imageData = ImageData(context: self.context)
                imageData.data = data
                imageData.photoGuid = attachment.guid
                imageData.attachment = attachment
                
                print("###\(#function): Saving an ImageData entity and then resetting the context.")
                do {
                    try self.context .save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"Photo save merge that"])
                    }
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                }
                self.context.reset() // lower the memory footprint
                
                newAttachmentCount -= 1
                if newAttachmentCount == 0 {
                    completionHandler?()
                }
                
            }
            
        }
        
        
        
    }
    
}
