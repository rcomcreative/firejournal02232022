//
//  NFIRSIncidentTypeBuildOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NFIRSIncidentTypeBuildOperation: FJOperation {
    
    let backgroundContext: NSManagedObjectContext!
    var task: UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    let nc = NotificationCenter.default
    var buildFromNFIRSIncidentType: BuildFromNFIRSIncidentType!
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
            print("NFIRSIncidentTypeBuildOperation is done cancelled")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.backgroundContext)
        executing(true)
        
        
        buildTheNFIRSIncidentType {
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.backgroundContext, userInfo:["info":"NFIRSIncidentType updated merge that"])
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue: FJkPLISTSCALLED),
                                object: nil,
                                userInfo: ["plist": PlistsToLoad.fjkPLISTNFIRSIncidentLoader])
                    }
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("NFIRSIncidentType is done save")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("NFIRSIncidentTypeBuildOperation is done \(error)")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("NFIRSIncidentTypeBuildOperation is done cancelled")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
    }
    
    
    func buildTheNFIRSIncidentType(withCompletion completion: () -> Void ) {
        buildFromNFIRSIncidentType = BuildFromNFIRSIncidentType.init()
        let nfirsA = buildFromNFIRSIncidentType.nfirsIncidentTypes
        for nfirs in nfirsA {
            let guidDate = GuidFormatter.init(date: theGuidDate)
            let guid = guidDate.formatGuid()
            let theGuid = "54."+guid
            if let theNFIRS = nfirs.nfirsIncidentTypes {
                let incidentType = NFIRSIncidentType(context: backgroundContext)
                incidentType.incidentTypeGuid = theGuid
                incidentType.displayOrder = Int64(theNFIRS.displayOrder)
                incidentType.incidentTypeNumber = theNFIRS.incidentTypeNumber
                incidentType.incidentTypeName = theNFIRS.incidentTypeName
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
