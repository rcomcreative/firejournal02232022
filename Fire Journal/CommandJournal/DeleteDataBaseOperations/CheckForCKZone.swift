//
//  CheckForCKZone.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/21/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class CheckForCKZone: FJOperation {

    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    let nc = NotificationCenter.default
    var thread:Thread!
    var zoneID: String!
    var recordZone: CKRecordZone!
    var ckErrorAlert: CKErrorAlert!
    var zoneWithIDs = [CKRecordZone]()
    var zoneIDs = [CKRecordZone.ID]()
    
    init(_ zone: String ) {
        self.zoneID = zone
        privateDatabase = myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
        operation = "Check For CKZone"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        executing(true)
        
        checkForZone() { result in
            switch result {
            case .success(let string):
               print(string)
                self.nc.post(name: .fConCheckTheCKZoneFinished ,object: nil ,userInfo: ["theZone": string] )
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.nc.post(name: .fConCheckTheCKZoneFinished ,object: nil ,userInfo: ["errorMessage": error.localizedDescription] )
                }
                self.executing(false)
                self.finish(true)
                return
            }
            self.executing(false)
            self.finish(true)
            return
        }
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    func checkForZone(withCompletionHandler completionHandler: @escaping (Result<String, Error>) -> Void) {
        self.privateDatabase.fetchAllRecordZones  { [unowned self] zones, error in
            if error == nil {
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
                for zone in zoneWithIDs {
                    let id = zone.zoneID
                    zoneIDs.append(id)
                }
                let theResult = zoneIDs.filter { $0.zoneName != "FireJournalShare"}
                if theResult.isEmpty {
                    completionHandler(.success(""))
                } else {
                    completionHandler(.success(self.zoneID))
                }
            } else {
                if let theError = error as? CKError {
                    print("Error fetchAllRecordZones \(theError)")
                    
                    let errorCode = theError.errorCode
                    
                    switch errorCode {
                    default:
                        var theMessage: String = ""
                        if let theErrorMessage = ckErrorAlert.buildTheError(errorCode: errorCode) {
                            theMessage = theErrorMessage + " -fetchAllRecordZones-"
                        }
                        completionHandler(.failure(theError))
                        DispatchQueue.main.async {
                            self.nc.post(name: .fConCKSubscriptionFailure ,object: nil ,userInfo: ["errorMessage": theMessage] )
                        }
                    }
                    self.executing(false)
                    self.finish(true)
                    return
            }
        }
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
    
}
