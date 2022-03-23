//
//  ICS214ActivityLogBackedUpOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class ICS214ActivityLogBackedUpOperation: FJOperation {
    
    //    MARK: -PROPERTIES-
    var context: NSManagedObjectContext!
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    
    var ics214ActivityLogA = [ICS214ActivityLog]()
    
    var ckRecordA = [CKRecord]()
    var ckRecord:CKRecord!
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    var thread:Thread!
    let dateFormatter = DateFormatter()
    
    init(_ context: NSManagedObjectContext, database: CKDatabase ) {
        self.context = context
        self.privateDatabase = database
        super.init()
    }
    
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
