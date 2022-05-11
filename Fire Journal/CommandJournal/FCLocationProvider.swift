//
//  FCLocationProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/10/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//
import UIKit
import CoreData
import CloudKit

class FCLocationProvider: NSObject {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var fcLocation: FCLocation!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var fcLocationR: CKRecord!
    
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
    
    func updateFCLocationToCloud(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ theLocation: FCLocation) -> Void)) {
        
        self.context = context
        self.fcLocation = self.context.object(with: objectID) as? FCLocation
        
        if let ckr = self.fcLocation.fcLocaationCKR {
            guard let  archivedData = ckr as? Data else { return }
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                fcLocationR = CKRecord(coder: unarchiver)
                fcLocationR["theEntity"] = "FCLocation"
                fcLocationR["longitude"] = self.fcLocation.longitude
                fcLocationR["latitude"] = self.fcLocation.latitude
                fcLocationR["location"] = self.fcLocation.location
                if let guid = self.fcLocation.guid {
                    fcLocationR["guid"] = guid.uuidString
                }
                if let incident = self.fcLocation.incidentGuid {
                    fcLocationR["incidentGuid"] = incident
                }
                if let journal = self.fcLocation.journalGuid {
                    fcLocationR["journalGuid"] = journal
                }
                if let promotionGuid = self.fcLocation.promotionGuid {
                    fcLocationR["promotionGuid"] = promotionGuid
                }
                if let acrossFormGuid = self.fcLocation.acrossFormGuid {
                    fcLocationR["acrossFormGuid"] = acrossFormGuid
                }
                if let ics214Guid = self.fcLocation.ics214Guid {
                    fcLocationR["ics214Guid"] = ics214Guid
                }
                if let modDate = self.fcLocation.modDate {
                    fcLocationR["modDate"] = modDate
                }
                if let streetName = self.fcLocation.streetName {
                    fcLocationR["streetName"] = streetName
                }
                if let streetNumber = self.fcLocation.streetNumber {
                    fcLocationR["streetNumber"] = streetNumber
                }
                if let city = self.fcLocation.city {
                    fcLocationR["city"] = city
                }
                if let state = self.fcLocation.state {
                    fcLocationR["state"] = state
                }
                if let zip = self.fcLocation.zip {
                    fcLocationR["zip"] = zip
                }
                
                let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [fcLocationR], recordIDsToDelete: nil)
                modifyCKOperation.savePolicy = .changedKeys
                modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
                    switch result {
                    case .success(_):
                        
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        self.fcLocationR.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        self.fcLocation.fcLocaationCKR = data as NSObject
                        
                        do {
                            try self.context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"fcLocation save merge that"])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            print(error)
                        }
                        
                        completionHandler(self.fcLocation)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            
                            let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                            print("here is the fcLocation operation error \(error)")
                        }
                    }
                }
                
                privateDatabase.add(modifyCKOperation)
                
            } catch {
                print("nothing here ")
            }
        } else {
            
            if let guid = self.fcLocation.guid {
                let recordName = guid.uuidString
                let fcLocationRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let fcLocationRID = CKRecord.ID(recordName: recordName, zoneID: fcLocationRZ.zoneID)
                fcLocationR = CKRecord.init(recordType: "FCLocation", recordID: fcLocationRID)
                let fcLocationRef = CKRecord.Reference(recordID: fcLocationRID, action: .deleteSelf)
                
                fcLocationR["theEntity"] = "FCLocation"
                fcLocationR["longitude"] = self.fcLocation.longitude
                fcLocationR["latitude"] = self.fcLocation.latitude
                fcLocationR["location"] = self.fcLocation.location
                if let guid = self.fcLocation.guid {
                    fcLocationR["guid"] = guid.uuidString
                }
                if let incident = self.fcLocation.incidentGuid {
                    fcLocationR["incidentGuid"] = incident
                }
                if let journal = self.fcLocation.journalGuid {
                    fcLocationR["journalGuid"] = journal
                }
                if let promotionGuid = self.fcLocation.promotionGuid {
                    fcLocationR["promotionGuid"] = promotionGuid
                }
                if let acrossFormGuid = self.fcLocation.acrossFormGuid {
                    fcLocationR["acrossFormGuid"] = acrossFormGuid
                }
                if let ics214Guid = self.fcLocation.ics214Guid {
                    fcLocationR["ics214Guid"] = ics214Guid
                }
                if let modDate = self.fcLocation.modDate {
                    fcLocationR["modDate"] = modDate
                }
                if let streetName = self.fcLocation.streetName {
                    fcLocationR["streetName"] = streetName
                }
                if let streetNumber = self.fcLocation.streetNumber {
                    fcLocationR["streetNumber"] = streetNumber
                }
                if let city = self.fcLocation.city {
                    fcLocationR["city"] = city
                }
                if let state = self.fcLocation.state {
                    fcLocationR["state"] = state
                }
                if let zip = self.fcLocation.zip {
                    fcLocationR["zip"] = zip
                }
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: fcLocationRef, requiringSecureCoding: true)
                    self.fcLocation.fcLocationReference = data as NSObject
                    
                } catch {
                    print("fcLocationReference to data failed line 514 Incident+Custom")
                }
                
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                fcLocationR.encodeSystemFields(with: coder)
                let data = coder.encodedData
                self.fcLocation.fcLocaationCKR = data as NSObject
                
                privateDatabase.save(fcLocationR, completionHandler: { record, error in
                    
                    do {
                        try self.context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"fcloation save merge that"])
                        }
                        
                        completionHandler(self.fcLocation)
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
