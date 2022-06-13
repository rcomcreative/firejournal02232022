//
//  FJUpdateJournalAddressToFCLocationOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FJUpdateJournalAddressToFCLocationOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    var privateDatabase:CKDatabase!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    
    var ckRecordA = [CKRecord]()
    var theFCLocation: FCLocation!
    var theFCLocationA = [FCLocation]()
    var theJournalsA = [Journal]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
        self.privateDatabase = myContainer.privateCloudDatabase
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
        getTheJournals()
        let result = theJournalsA.filter { $0.journalLocationSC != nil }
        if !result.isEmpty {
            createFCLocationForJournals(journals: theJournalsA) {
                saveToCD()
                updateCloudKitWithFCLocationCKRecords() {
                    DispatchQueue.main.async {
                        self.nc.post(name: .fireJournalFCLocationsUpdated, object: nil)
                        self.executing(false)
                        self.finish(true)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalFCLocationsUpdated, object: nil)
                self.executing(false)
                self.finish(true)
            }
        }
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    func updateCloudKitWithFCLocationCKRecords(withCompletion completion: @escaping() -> Void) {
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: ckRecordA, recordIDsToDelete: nil)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                print("here is to succes \(ckRecordA)")
                completion()
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the fcLocation operation error \(error)")
                    
                    completion()
                }
            }
        }
        
        privateDatabase.add(modifyCKOperation)
    }
    
    func createFCLocationForJournals(journals: [Journal], withCompletion completion: () -> Void ) {
        for journal in journals {
            let theLocation = FCLocation(context: bkgrdContext)
            theLocation.guid = UUID.init()
            theLocation.journalGuid = journal.fjpJGuidForReference
            journal.theLocation = theLocation
            
            if let location = journal.journalLocationSC {
                guard let  archivedData = location as? Data else { return }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                    
                    theLocation.location = unarchivedLocation
                    theLocation.latitude = unarchivedLocation.coordinate.latitude
                    theLocation.longitude = unarchivedLocation.coordinate.longitude
                    
                    if journal.journalStreetNumber != "" || journal.journalStreetNumber != nil  && journal.journalStreetName != "" || journal.journalStreetName != nil {
                        if let streetNumber = journal.journalStreetNumber {
                            theLocation.streetNumber = streetNumber
                        }
                        if let streetName = journal.journalStreetName {
                            theLocation.streetName = streetName
                        }
                        if let city = journal.journalCity {
                            theLocation.city = city
                        }
                        if let state = journal.journalState {
                            theLocation.state = state
                        }
                        if let zip = journal.journalZip {
                            theLocation.zip = zip
                        }
                    } else {
                        CLGeocoder().reverseGeocodeLocation(unarchivedLocation, completionHandler: { (placemarks, error) -> Void in
                            
                            if error != nil {
                                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                                return
                            }
                            guard let count = placemarks?.count else {
                                print("There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                                return
                            }
                            if count != 0 {
                                guard let pm = placemarks?[0] else { return }
                                if pm.thoroughfare != nil {
                                    if let pmCity = pm.locality {
                                        theLocation.city = "\(pmCity)"
                                    } else {
                                        theLocation.city = ""
                                    }
                                    if let pmSubThroughfare = pm.subThoroughfare {
                                        theLocation.streetNumber = "\(pmSubThroughfare)"
                                    } else {
                                        theLocation.streetNumber = ""
                                    }
                                    if let pmThoroughfare = pm.thoroughfare {
                                        theLocation.streetName = "\(pmThoroughfare)"
                                    } else {
                                        theLocation.streetName = ""
                                    }
                                    if let pmState = pm.administrativeArea {
                                        theLocation.state = "\(pmState)"
                                    } else {
                                        theLocation.state = ""
                                    }
                                    if let pmZip = pm.postalCode {
                                        theLocation.zip = "\(pmZip)"
                                    } else {
                                        theLocation.zip = ""
                                    }
                                }
                            }
                        })
                    }
                    
                } catch {
                    print("something's going on here")
                }
            }
            
            if let recordName = theLocation.guid?.uuidString {
                let fcLocationRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                let fcLocationRID = CKRecord.ID(recordName: recordName, zoneID: fcLocationRZ.zoneID)
                let fcLocationR = CKRecord.init(recordType: "FCLocation", recordID: fcLocationRID)
                let fcLocationRef = CKRecord.Reference(recordID: fcLocationRID, action: .deleteSelf)
                
                fcLocationR["theEntity"] = "FCLocation"
                fcLocationR["longitude"] = theLocation.longitude
                fcLocationR["latitude"] = theLocation.latitude
                fcLocationR.encryptedValues["location"] = theLocation.location
                if let guid = theLocation.guid {
                    fcLocationR["guid"] = guid.uuidString
                }
                if let incident = theLocation.incidentGuid {
                    fcLocationR["incidentGuid"] = incident
                }
                if let modDate = theLocation.modDate {
                    fcLocationR["modDate"] = modDate
                }
                if let streetName = theLocation.streetName {
                    fcLocationR["streetName"] = streetName
                }
                if let streetNumber = theLocation.streetNumber {
                    fcLocationR["streetNumber"] = streetNumber
                }
                if let city = theLocation.city {
                    fcLocationR["city"] = city
                }
                if let state = theLocation.state {
                    fcLocationR["state"] = state
                }
                if let zip = theLocation.zip {
                    fcLocationR["zip"] = zip
                }
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: fcLocationRef, requiringSecureCoding: true)
                    theLocation.fcLocationReference = data as NSObject
                    
                } catch {
                    print("fcLocationReference to data failed line 514 Incident+Custom")
                }
                
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                fcLocationR.encodeSystemFields(with: coder)
                let data = coder.encodedData
                theLocation.fcLocaationCKR = data as NSObject
                
                ckRecordA.append(fcLocationR)
        }
            completion()
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
    
    fileprivate func saveToCD() {
            do {
                try self.bkgrdContext.save()
                
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJUpdateJournalAddressToFCLocationOperation here"])
                }
            } catch let error as NSError {
                let nserror = error
                print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            }
    }
    
//    MARK: -CHECK THREAD
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
        
        
    
}
