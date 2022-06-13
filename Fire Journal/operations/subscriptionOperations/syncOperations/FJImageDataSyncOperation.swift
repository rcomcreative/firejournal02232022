    //
    //  FJImageDataSyncOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 5/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class FJImageDataSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext: NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    var imageDataA = [ImageData]()
    var ckRecordA = [CKRecord]()
    var theImageData: ImageData!
    var thePhotoA = [Photo]()
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
        getThePhotos()
        
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
            print("here is new imageData")
            newImageDataFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["photoGuid"] as? String  {
                let result = imageDataA.filter { $0.photoGuid == UUID(uuidString: guid) }
                if result.isEmpty {
                    print("here is new imageData")
                    newImageDataFromCloud(ckRecord: record)
                } else {
                    print("here is modified imageData")
                    theImageData = result.last
                    updateImageDataFromCloud(ckRecord: record, theImageData: theImageData )
                }
            }
        }
        completion()
    }
    
    func updateImageDataFromCloud(ckRecord: CKRecord, theImageData: ImageData) {
        
        if let asset = ckRecord["data"] as? CKAsset {
            if let data = imageDataFromCloudKit(asset: asset)  {
                theImageData.data = data
            }
        }
        
        if let pGuid = ckRecord["photoGuid"] as? String {
            if  let theGuid = UUID(uuidString: pGuid) {
                theImageData.photoGuid = theGuid
                let result = thePhotoA.filter { $0.guid == theGuid}
                if !result.isEmpty {
                    let photo = result.last
                    photo?.imageData = theImageData
                }
            }
        }
        
        if theImageData.imageDataReference == nil {
            let theImageDataReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: theImageDataReference, requiringSecureCoding: true)
                theImageData.imageDataReference = data as NSObject
                
            } catch {
                print("tagReference to data failed line 514 Incident+Custom")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theImageData.imageDataCKR = data as NSObject
        
    }
    
    func newImageDataFromCloud(ckRecord: CKRecord) {
        
        let theImageData = ImageData(context: bkgrdContext)
        
        if let asset = ckRecord["data"] as? CKAsset {
            if let data = imageDataFromCloudKit(asset: asset)  {
                theImageData.data = data
            }
        }
        
        if let pGuid = ckRecord["photoGuid"] as? String {
            if  let theGuid = UUID(uuidString: pGuid) {
                theImageData.photoGuid = theGuid
                let result = thePhotoA.filter { $0.guid == theGuid}
                if !result.isEmpty {
                    let photo = result.last
                    photo?.imageData = theImageData
                }
            }
        }
        
        let theImageDataReference = CKRecord.Reference(recordID: ckRecord.recordID, action: .deleteSelf)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: theImageDataReference, requiringSecureCoding: true)
            theImageData.imageDataReference = data as NSObject
            
        } catch {
            print("tagReference to data failed line 514 Incident+Custom")
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theImageData.imageDataCKR = data as NSObject
        
    }
    
    func getThePhotos() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo" )
        do {
            thePhotoA = try bkgrdContext.fetch(fetchRequest) as! [Photo]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageData" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            imageDataA = try bkgrdContext.fetch(fetchRequest) as! [ImageData]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
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
    
    fileprivate func saveToCD() {
        
            do {
                try self.bkgrdContext.save()
                
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJImageDataSyncOperation here"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjTags])
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
