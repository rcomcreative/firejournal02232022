//
//  UserFDIDBuildOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserFDIDBuildOperation: FJOperation {
    
    let backgroundContext: NSManagedObjectContext!
    var task: UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    let nc = NotificationCenter.default
    var buildFromFDIDPlist: BuildFromFDIDPlist!
    let theGuidDate: Date!
    
    init(_ context: NSManagedObjectContext) {
        self.backgroundContext = context
        bkgrndTask = BkgrndTask.init(bkgrndTask: task)
        bkgrndTask?.operation = "UserFDIDBuildOperation"
        bkgrndTask?.registerBackgroundTask()
        theGuidDate = Date()
        super.init()
    }
    
    override func main() {
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("UserFDIDBuildOperation is done save")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.backgroundContext)
        executing(true)
        
        buildTheFDIDs {
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.backgroundContext, userInfo:["info":"UserFDID updated merge that"])
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                                object: nil,
                                userInfo: ["plist":PlistsToLoad.fjkPLISTUserFDIDLoader])
                    }
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("UserFDIDBuildOperation is done save")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("UserFDIDBuildOperation is done save")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("UserFDIDBuildOperation is done save")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func buildTheFDIDs(withCompletion completion: () -> Void ) {
        buildFromFDIDPlist = BuildFromFDIDPlist.init()
        let fdidA = buildFromFDIDPlist.fdids
        for afdid in fdidA {
            let theFDID = afdid.fdid
            let fdid = UserFDID(context: self.backgroundContext)
            let guidDate = GuidFormatter(date: theGuidDate)
            let guid = guidDate.formatGuid()
            let theGuid = "76"+guid
            fdid.fdidGuid = theGuid
            fdid.fireDepartmentName = theFDID.department
            fdid.fdidNumber = theFDID.fdid
            fdid.hqCity = theFDID.city
            fdid.hqState = theFDID.state
            if let city = fdid.hqCity {
                print("here is the fdid city - \(city)")
            }
        }
        completion()
    }
    
}
