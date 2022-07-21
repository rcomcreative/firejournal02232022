    //
    //  DeleteZoneIDOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/15/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //
import UIKit
import CoreData
import CloudKit

class DeleteZoneIDOperation: FJOperation {
    
    
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    let nc = NotificationCenter.default
    var thread:Thread!
    var zoneID: String!
    var recordZone: CKRecordZone!
    var ckErrorAlert: CKErrorAlert!
    var zoneWithIDs = [CKRecordZone]()
    
    init(_ zone: String ) {
        self.zoneID = zone
        privateDatabase = myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
        operation = "DeleteZoneIDOperatio"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        executing(true)
        fetchAllRecordZones()
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
        //    MARK:- MAKE SURE OPERATION IS ON BACKGROUND THREAD
    @objc func checkTheThread() {
        let testThread: Bool = thread.isMainThread
        if testThread == false {
            print("this thread is on the main")
            executing(false)
            finish(true)
            return
        }
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
        //    MARK: -RETRY KEY-
    func fetchAllRecordZones() {
        self.privateDatabase.fetchAllRecordZones  { [unowned self] zones, error in
            if error == nil {
                print("here are the zones \(String(describing: zones))")
                if zones?.count == 1 {
//                    DispatchQueue.main.async {
//                        self.nc.removeObserver(self, name: .fConCKZoneSuccess, object: nil)
//                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
//                        self.executing(false)
//                        self.finish(true)
//                        return
//                    }
                } else {
                    guard let response = zones  else {
                        print(" no zones here ")
                        return
                    }
                    
                    for zone in response {
                        let deleteZone = CKRecordZone.init(zoneName: "_default")
                        if zone.zoneID == deleteZone.zoneID {
                            print("the zone is default")
                        } else {
                            zoneWithIDs.append(zone)
                        }
                    }
                    
                    
                    self.removeAllZonesInCloudKit()
                }
            } else {
                if let theError = error as? CKError {
                    print("Error fetchAllRecordZones \(theError)")
                    
                    let errorCode = theError.errorCode
                    
                    switch errorCode {
                    case 6, 7, 16, 22, 23, 27:
                        if let retryerror = theError.userInfo[CKErrorRetryAfterKey] as? Double {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + retryerror ) {
                                self.fetchAllRecordZones()
                            }
                        }
                    default:
                        var theMessage: String = ""
                        if let theErrorMessage = ckErrorAlert.buildTheError(errorCode: errorCode) {
                            theMessage = theErrorMessage + " -fetchAllRecordZones-"
                        }
                        DispatchQueue.main.async {
                            self.nc.post(name: .fConCKSubscriptionFailure ,object: nil ,userInfo: ["errorMessage": theMessage] )
                        }
                    }
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    self.executing(false)
                    self.finish(true)
                    return
                    
                    
                    
                }
            }
        }
    }
    
    
        //    MARK:- REMOVEALLZONES-
    private func removeAllZonesInCloudKit() {
        var zoneID = [CKRecordZone.ID]()
        
        for zone in zoneWithIDs {
            let id = zone.zoneID
            zoneID.append(id)
        }
        let result = zoneID.filter { $0.zoneName != "_defaultZone"}
        let modifyRecordZone = CKModifyRecordZonesOperation.init(recordZonesToSave: [], recordZoneIDsToDelete: result )
        modifyRecordZone.modifyRecordZonesCompletionBlock = { (savedRecordZones: [CKRecordZone]?, deletedRecordZoneIDs: [CKRecordZone.ID]?, error: Error?) in
            if let error = error  as? CKError  {
                print("Error creating record zone \(error.localizedDescription)")
                
                
                let errorCode = error.errorCode
                
                switch errorCode {
                case 6, 7, 16, 22, 23, 27:
                    if let retryerror = error.userInfo[CKErrorRetryAfterKey] as? Double {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + retryerror ) {
                            self.removeAllZonesInCloudKit()
                        }
                    }
                default:
                    var theMessage: String = ""
                    if let theErrorMessage = self.ckErrorAlert.buildTheError(errorCode: errorCode) {
                    theMessage = theErrorMessage + " -remove record zones-"
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name: .fConCKZoneFailure ,object: nil ,userInfo: ["errorMessage": theMessage] )
                    }
                }
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.executing(false)
                self.finish(true)
                return
            } else {
                print("here is the deleted zone \(String(describing: deletedRecordZoneIDs))")
                DispatchQueue.main.async {
                    self.nc.post(name: .fConCKZoneSuccess, object: nil)
                }
                self.nc.removeObserver(self, name: .fConCKZoneSuccess, object: nil)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.executing(false)
                self.finish(true)
                return
            }
        }
        modifyRecordZone.qualityOfService = .default
        self.privateDatabase.add(modifyRecordZone)
        
    }
    
    
    
    
    
}
