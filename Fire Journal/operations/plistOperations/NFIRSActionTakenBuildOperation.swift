//
//  NFIRSActionTakenBuildOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class NFIRSActionTakenBuildOperation: FJOperation {
    
    let backgroundContext: NSManagedObjectContext!
    var task: UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    let nc = NotificationCenter.default
    var buildFromActionsTaken: BuildFromActionsTaken!
    let theGuidDate: Date!
    
    init(_ context: NSManagedObjectContext) {
        self.backgroundContext = context
        bkgrndTask = BkgrndTask.init(bkgrndTask: task)
        bkgrndTask?.operation = "NFIRSActionTakenBuildOperation"
        bkgrndTask?.registerBackgroundTask()
        theGuidDate = Date()
        super.init()
    }
    
    override func main() {
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("NFIRSActionTakenBuildOperation is done cancelled")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.backgroundContext)
        executing(true)
        
        buildNFIRSActionTaken {
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.backgroundContext, userInfo:["info":"NFIRSActionTakenBuildOperation updated merge that"])
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue: FJkPLISTSCALLED),
                                object: nil,
                                userInfo: ["plist": PlistsToLoad.fjkPLISTActionTakenLoader])
                    }
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("NFIRSActionTakenBuildOperation is done save")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    self.bkgrndTask?.endBackgroundTask()
                    self.executing(false)
                    self.finish(true)
                    print("NFIRSActionTakenBuildOperation is done \(error)")
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        
        guard isCancelled == false else {
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("NFIRSActionTakenBuildOperation is done cancelled")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    func buildNFIRSActionTaken(withCompletion completion: () -> Void ) {
        buildFromActionsTaken = BuildFromActionsTaken.init()
        let actionsTakenA = buildFromActionsTaken.actionsTaken
        for action in actionsTakenA {
            let guidDate = GuidFormatter.init(date: theGuidDate)
            let guid = guidDate.formatGuid()
            let theGuid = "55."+guid
            if let anAction = action.actionTaken {
                let nfirsAction = NFIRSActionsTaken(context: backgroundContext)
                nfirsAction.actionTakenGuid = theGuid
                nfirsAction.actionTaken = anAction.actionTaken
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
