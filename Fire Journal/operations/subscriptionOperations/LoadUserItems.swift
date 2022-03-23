//
//  LoadUserItems.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

public enum CKRecordsToLoad: String {
    case fJkCKRFireJournalUser = "fJkCKRFireJournalUser"
    case fJkCKRIncident = "fJkCKRIncident"
    case fJkCKRJournal = "fJkCKRJournal"
    case fJkCKRForms = "fJkCKRForms"
    case fJkCKRFormsTOC = "fJkCKRFormsTOC"
    case fJkCKRICS214Form = "fJkCKRICS214Form"
    case fJkCKRARCrossForm = "fJkCKRARCrossForm"
    case fJkCKRUserAttendees = "fJkCKRUserAttendees"
    case fJkCKRUserCrews = "fJkCKRUserCrews"
    case fJkCKRUserResourcesGroups = "fJkCKRUserResourcesGroups"
    case fJkCKRUserTime = "fJkCKRUserTime"
}

final class LoadUserItems {
    let context: NSManagedObjectContext
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    let userDefaults = UserDefaults.standard
    var backgroundTask : UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    var thereIsBackgroundTask: Bool = false
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        thread = Thread(target:self, selector:#selector(runTheOperations), object:nil)
        nc.addObserver(self, selector:#selector(nextToBeCalled(notification:)), name:NSNotification.Name(rawValue: FJkLOADUSERITMESCALLED), object: nil)
        privateDatabase = myContainer.privateCloudDatabase
        bkgrndTask = BkgrndTask.init(bkgrndTask: backgroundTask)
        bkgrndTask?.operation = "LoadUserItems"
    }
    
    @objc func nextToBeCalled(notification:Notification) -> Void {
        if  let userInfo = notification.userInfo {
            let ckRecordType = userInfo["ckRecordType"] as? CKRecordsToLoad
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            switch ckRecordType {
            case .fJkCKRFireJournalUser?:
                print("User downloaded")
            case .fJkCKRIncident?:
                print("nothing here")
            case .fJkCKRJournal?:
                print("nothing here")
            case .fJkCKRForms?:
                print("nothing here")
            case .fJkCKRFormsTOC?:
                print("nothing here")
            case .fJkCKRICS214Form?:
                print("nothing here")
            case .fJkCKRARCrossForm?:
                print("nothing here")
            case .fJkCKRUserAttendees?:
                print("nothing here")
            case .fJkCKRUserCrews?:
                print("nothing here")
            case .fJkCKRUserResourcesGroups?:
                print("nothing here")
            case .fJkCKRUserTime?:
                print("all finished loading the plists")
                nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkLOADUSERITMESCALLED), object: nil)
            default:
                print("nothing here")
            }
        }
    }
    
    @objc func runTheOperations() {
        bkgrndTask?.registerBackgroundTask()
        thereIsBackgroundTask = true
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
        let reach = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
        print("this is the reach boolean \(reach)")
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            let fjuLoader = FireJournalUserLoader.init(context, database: privateDatabase)
            pendingOperations.nfirsIncidentTypeQueue.addOperation(fjuLoader)
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
        if thereIsBackgroundTask {
            bkgrndTask?.endBackgroundTask()
            thereIsBackgroundTask = false
        }
    }
    
}
