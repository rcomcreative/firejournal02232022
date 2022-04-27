    //
    //  PhotoProvider.swift
    //  StationCommand
    //
    //  Created by DuRand Jones on 7/8/21.
    //

import UIKit
import CoreData
import CloudKit

class PhotoProvider {
    
    private(set) var persistentContainer: NSPersistentContainer
    
    let nc = NotificationCenter.default
    var context: NSManagedObjectContext!
    var photo: Photo!
    var staff: UserAttendees!
    var theIncident: Incident!
    var theJournal: Journal!
    var theProject: PromotionJournal!
    var theType: IncidentTypes!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
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
            photo.journalGuid = theJournal.journalGuid
            self.theJournal.journalPhotoTaken = true
            photo.journal = self.theJournal
            photo.image = thumbnailImage // transient
            
//            imageData
            
            let theImageData = ImageData(context: taskContext)
            theImageData.data = imageData
            theImageData.photoGuid = photo.guid
            theImageData.attachment = photo
            
            if shouldSave {
                save(context: taskContext)
            }
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
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
            photo.promotionGuid = self.theProject.projectGuid
            self.theProject.addToPhotos(photo)
            photo.image = thumbnailImage // transient
            if shouldSave {
                save(context: taskContext)
            }
            
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
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
    func addPhotoIncident(imageData: Data, imageURL: URL, incidentid: NSManagedObjectID, taskContext: NSManagedObjectContext, shouldSave: Bool = true, completionBlock: () -> () ) {
        self.context = taskContext
        self.theIncident = self.context.object(with: incidentid) as? Incident
        self.theType = .allIncidents
        let thumbnailImage = Photo.thumbnail(from: imageData, thumbnailPixelSize: 80)
        var destinationURL: URL? // to hold the attachment.imageURL for later use
        
        taskContext.performAndWait {
            photo = Photo(context: taskContext)
            photo.incidentGuid = self.theIncident.incidentGuid
            photo.photoDate = Date()
            photo.guid = UUID()
            photo.incidentGuid = theIncident.incidentGuid
            self.theIncident.incidentPhotoTaken = true
            self.theIncident.addToPhoto(photo)
            photo.image = thumbnailImage // transient
            if shouldSave {
                save(context: taskContext)
            }
            
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
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
            
            if shouldSave {
                save(context: taskContext)
            }
            
            guard let theGuid = photo.guid else { return }
            destinationURL = photo.imageURL(guid: theGuid)
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
            taskContext.perform {
                guard let attachment = taskContext.object(with: attachmentObjectID) as? Photo else { return }
                
                
                let imageData = ImageData(context: taskContext)
                imageData.data = data
                imageData.photoGuid = attachment.guid
                imageData.attachment = attachment
                
                print("###\(#function): Saving an ImageData entity and then resetting the context.")
                do {
                    try taskContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Photo save merge that"])
                    }
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                }
                taskContext.reset() // lower the memory footprint
                
                newAttachmentCount -= 1
                if newAttachmentCount == 0 {
                    completionHandler?()
                }
                
            }
            
        }
        
        
        
    }
    
}
