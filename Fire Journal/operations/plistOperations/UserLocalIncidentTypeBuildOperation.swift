//
//  UserLocalIncidentTypeBuildOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserLocalIncidentTypeBuildOperation: FJOperation {
    
    let backgroundContext: NSManagedObjectContext!
    var task: UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    let nc = NotificationCenter.default
    var buildFromLocalIncidentType: BuildFromLocalIncidentType!
    let theGuidDate: Date!
    
    init(_ context: NSManagedObjectContext) {
        self.backgroundContext = context
        bkgrndTask = BkgrndTask.init(bkgrndTask: task)
        bkgrndTask?.operation = "UserLocalIncidentTypeBuildOperation"
        bkgrndTask?.registerBackgroundTask()
        theGuidDate = Date()
        super.init()
    }
    
    override func main() {
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("UserLocalIncidentTypeBuildOperation is done cancelled")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.backgroundContext)
        executing(true)
        
        buildLocalIncidentType {
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.backgroundContext, userInfo:["info":"UserLocalIncidentTypeBuildOperation updated merge that"])
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue: FJkPLISTSCALLED),
                                object: nil,
                                userInfo: ["plist": PlistsToLoad.fjkPLISTUserLocalIncidentTypeLoader])
                    }
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("UserLocalIncidentTypeBuildOperation is done save")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("UserLocalIncidentTypeBuildOperation is done \(error)")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("UserLocalIncidentTypeBuildOperation is done cancelled")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
    }
    
    func buildLocalIncidentType(withCompletion completion: () -> Void ) {
        buildFromLocalIncidentType = BuildFromLocalIncidentType.init()
        let localIncidentTypesA = buildFromLocalIncidentType.localIncidents
        for localIncidentTypes in localIncidentTypesA {
                let guidDate = GuidFormatter.init(date: theGuidDate)
                let guid = guidDate.formatGuid()
                let theGuid = "52."+guid
            if let local = localIncidentTypes.localIncident {
            let localIncident = UserLocalIncidentType(context: backgroundContext)
                localIncident.localIncidentGuid = theGuid
                localIncident.localIncidentTypeName = local.localIncident
            }
        }
        completion()
    }
    
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
