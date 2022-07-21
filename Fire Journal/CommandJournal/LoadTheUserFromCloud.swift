//
//  LoadTheUserFromCloud.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit

class LoadTheUserFromCloud: NSObject {
    
    let context: NSManagedObjectContext
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    let userDefaults = UserDefaults.standard
    var bkgrndTask: BkgrndTask?
    var thereIsBackgroundTask: Bool = false
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        self.thread = Thread(target:self, selector: #selector(getCloudUser), object:nil)
        self.privateDatabase = myContainer.privateCloudDatabase
        self.nc.addObserver(self, selector:#selector(finishTask(nc:)), name:NSNotification.Name(rawValue: FJkLOADUSERITMESCALLED), object: nil)
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    @objc func getCloudUser() {
        pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
        let userFromCloudOperation = UserFromCloudOperation(context, database: privateDatabase)
        pendingOperations.nfirsIncidentTypeQueue.addOperation(userFromCloudOperation)
        pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
    }
    
    @objc func finishTask(nc: Notification) {
        self.bkgrndTask?.endBackgroundTask()
    }
    
}
