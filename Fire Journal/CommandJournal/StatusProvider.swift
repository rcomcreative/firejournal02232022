    //
    //  StatusProvider.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/29/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import CoreData
import CloudKit
import CoreMedia

class StatusProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    
    private var fetchedResultsController: NSFetchedResultsController<Status>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Status> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [Status] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var status: Status!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var statusR: CKRecord!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    deinit {
        print("Status Provider is be deinitialized")
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
    }
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        if let userInfo = notification.userInfo as! [String: Any]? {
            if let theStatus = userInfo["status"] as? Bool {
                if theStatus {
                    DispatchQueue.main.async {
                        if self.context != nil {
                            self.context.mergeChanges(fromContextDidSave: notification)
                        }
                    }
                }
            }
        }
    }
    
    func getTheStatus(context: NSManagedObjectContext) -> [Status]? {
        
        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "shiftDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Status lin 56 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    

    
    func getStatusFromCloud(_ context: NSManagedObjectContext, completionHandler: ( @escaping (_ status: Status) -> Void)) {
        self.context = context
        var status: Status!
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        let sort = NSSortDescriptor(key: "shiftDate", ascending: false)
        let query = CKQuery.init(recordType: "Status", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        
        var statusRecordsA = [CKRecord]()
        
        operation.recordMatchedBlock = { recordid, result in
            switch result {
            case .success(let record):
                statusRecordsA.append(record)
            case .failure(let error):
                print("error on retrieving status \(error)")
            }
        }
        
        operation.queryResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                if !statusRecordsA.isEmpty {
                    let theResult = statusRecordsA.sorted(by: { return $0.creationDate! < $1.creationDate! })
                    self.ckRecord = theResult.last!
                    status = updateTheStatus(self.ckRecord, self.context)
                    completionHandler(status)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the status operation error \(error)")
                }
            }
        }
        
        privateDatabase.add(operation)
        
    }
    
    func updateTheStatus(_ ckRecord: CKRecord,_ context: NSManagedObjectContext) -> Status {
        self.context = context
        if let statusA = getTheStatus(context: self.context) {
            if !statusA.isEmpty {
                if let theADate = ckRecord["agreementDate"] as? Date {
                    let result = statusA.filter { $0.agreementDate == theADate }
                    if !result.isEmpty {
                        status = result.last
                        
                        if let fcLocationChanged = ckRecord["locationMovedToFCLocation"] as? Int64 {
                            if fcLocationChanged == 1 {
                                status.locationMovedToFCLocation = true
                            } else {
                                status.locationMovedToFCLocation = false
                            }
                        }
                        
                        if let theDate = ckRecord["shiftDate"] as? Date {
                            if theDate == status.shiftDate {
                                if let guid: String = ckRecord["guidString"] as? String {
                                    if guid == "" {
                                        status.guidString = guid
                                    }
                                } else {
                                    if let shiftDate = status.shiftDate {
                                        if theDate > shiftDate {
                                            status.shiftDate = theDate
                                            if let guid: String = ckRecord["guidString"] as? String {
                                                status.guidString = guid
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        do {
                            try self.context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"status save merge that","status": true])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            print(error)
                        }
                    } else {
                        self.status = Status(context: self.context)
                        if let fcLocationChanged = ckRecord["locationMovedToFCLocation"] as? Int64 {
                            if fcLocationChanged == 1 {
                                self.status.locationMovedToFCLocation = true
                            } else {
                                self.status.locationMovedToFCLocation = false
                            }
                        }

                        if let theDate = ckRecord["shiftDate"] as? Date {
                            self.status.shiftDate = theDate
                        }
                        if let shiftGuid = ckRecord["guidString"] as? String {
                            self.status.guidString = shiftGuid
                        }
                        
                        if let aDate = ckRecord["agreementDate"] as? Date {
                            self.status.agreementDate = aDate
                            self.status.agreement = true
                        }
                        
                        let coder = NSKeyedArchiver(requiringSecureCoding: true)
                        ckRecord.encodeSystemFields(with: coder)
                        let data = coder.encodedData
                        self.status.statusCKR = data as NSObject
                        
                        do {
                            try self.context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"status save merge that","status": true])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            print(error)
                        }
                        
                    }
                }
                
                
            }
        }
        
        
        return status
    }
    
    func addFCLocationsToStatus(objectID: NSManagedObjectID, _ context: NSManagedObjectContext, completionHander: ( @escaping (_ status: Status) -> Void )) {
        self.context = context
        self.status = self.context.object(with: objectID) as? Status
        self.status.locationMovedToFCLocation = true
        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"status save merge that", "status": true ])
            }
        } catch let error as NSError {
            let theError: String = error.localizedDescription
            let error = "There was an error in saving " + theError
            print(error)
        }
        completionHander(self.status)
    }
    
    func createStatusCKRecord(_ context: NSManagedObjectContext, _ objectID: NSManagedObjectID, completionHandler: ( @escaping (_ status: Status) -> Void)) {
        self.context = context
        self.status = self.context.object(with: objectID) as? Status
        if let recordName = self.status.guidString {
            
                //            check if there there is already a ckRecord
            if let ckr = status.statusCKR {
                guard let  archivedData = ckr as? Data else { return }
                do {
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                    statusR = CKRecord(coder: unarchiver)
                    statusR["guidString"] = self.status.guidString
                    if let agreementDate = self.status.agreementDate {
                        statusR["agreementDate"] = agreementDate
                    }
                    if self.status.agreement {
                        statusR["agreement"] = 1
                    } else {
                        statusR["agreement"] = 0
                    }
                    if self.status.locationMovedToFCLocation {
                        statusR["locationMovedToFCLocation"] = 1
                    } else {
                        statusR["locationMovedToFCLocation"] = 0
                    }
                    let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: [statusR], recordIDsToDelete: nil)
                    modifyCKOperation.savePolicy = .changedKeys
                    modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
                        switch result {
                        case .success(_):
                            
                            let coder = NSKeyedArchiver(requiringSecureCoding: true)
                            self.statusR.encodeSystemFields(with: coder)
                            let data = coder.encodedData
                            self.status.statusCKR = data as NSObject
                            
                            do {
                                try self.context.save()
                                DispatchQueue.main.async {
                                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"status save merge that","status": true])
                                }
                            } catch let error as NSError {
                                let theError: String = error.localizedDescription
                                let error = "There was an error in saving " + theError
                                print(error)
                            }
                            
                        case .failure(let error):
                            DispatchQueue.main.async {
                                
                                let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                                print("here is the status operation error \(error)")
                            }
                        }
                    }
                    
                    privateDatabase.add(modifyCKOperation)
                    
                } catch {
                    print("nothing here ")
                }
            } else {
                
                let statusRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let statusRID = CKRecord.ID(recordName: recordName, zoneID: statusRZ.zoneID)
                statusR = CKRecord.init(recordType: "Status", recordID: statusRID)
                let statusRef = CKRecord.Reference(recordID: statusRID, action: .deleteSelf)
                statusR["theEntity"] = "Status"
                statusR["guidString"] = recordName
                if let shiftDate = self.status.shiftDate {
                    statusR["shiftDate"] = shiftDate
                }
                if let agreementDate = self.status.agreementDate {
                    statusR["agreementDate"] = agreementDate
                }
                if self.status.agreement {
                    statusR["agreement"] = 1
                } else {
                    statusR["agreement"] = 0
                }
                if self.status.locationMovedToFCLocation {
                    statusR["locationMovedToFCLocation"] = 1
                } else {
                    statusR["locationMovedToFCLocation"] = 0
                }
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: statusRef, requiringSecureCoding: true)
                    self.status.statusReference = data as NSObject
                    
                } catch {
                    print("statusReference to data failed line 514 Incident+Custom")
                }
                
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                statusR.encodeSystemFields(with: coder)
                let data = coder.encodedData
                self.status.statusCKR = data as NSObject
                
                privateDatabase.save(statusR, completionHandler: { record, error in
                    
                    do {
                        try self.context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"status save merge that", "status": true ])
                        }
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




