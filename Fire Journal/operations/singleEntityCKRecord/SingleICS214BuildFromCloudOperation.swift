//
//  SingleICS214BuildFromCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/8/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleICS214BuildFromCloudOperation: FJOperation {
    
    lazy var ics214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICDS214Context: NSManagedObjectContext!
    
    var ckRecord: CKRecord
    var theICS214: ICS214Form!
    var theUserTimeID: NSManagedObjectID
    var theUserTime: UserTime!
    let nc = NotificationCenter.default
    var thread:Thread!
    var context: NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    let ics214ActivityLogSync = ICS214ActivityLogSyncOperation()
    let ics214PersonnelSync = ICS214PersonalSyncOperation()
    
    init( _ ckRecord: CKRecord,_ userTimeID: NSManagedObjectID,_ context: NSManagedObjectContext) {
        self.ckRecord = ckRecord
        self.theUserTimeID = userTimeID
        self.context = context
        super.init()
        self.theICDS214Context = ics214Provider.persistentContainer.newBackgroundContext()
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
            operation = "SingleICS214BuildFromCloudOperation"
            
            guard isCancelled == false else {
                executing(false)
                finish(true)
                return
            }
            
            thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
            nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.theICDS214Context)
            executing(true)
        
        theUserTime = self.theICDS214Context.object(with: theUserTimeID) as? UserTime
        buildNewICS214FromCloud(record: self.ckRecord) {
            if self.theICS214 != nil {
                self.theUserTime.addToIcs214(self.theICS214)
                self.saveToCD()
                let ics214OID = self.theICS214.objectID
                DispatchQueue.main.async {
                    self.getICS214ActivityLogsAssociatedWithICS214(self.theUserTimeID, ics214OID, self.theICDS214Context)
                }
                DispatchQueue.main.async {
                    self.getICS214ActivityLogsAssociatedWithICS214(self.theUserTimeID, ics214OID, self.theICDS214Context)
                }
                DispatchQueue.main.async {
                    print("SingleICS214BuildFromCloudOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    print("SingleICS214BuildFromCloudOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    func buildNewICS214FromCloud(record: CKRecord, completionHandler: (() -> Void)? = nil) {
        theICS214 = ICS214Form(context: self.theICDS214Context)
        ics214Provider.singleICSFromTheCloud(ckRecord: record, dateFormatter: dateFormatter, theICS214, self.theICDS214Context) {
            completionHandler?()
        }
    }
    
    func getICS214ActivityLogsAssociatedWithICS214(_ userTimeOID: NSManagedObjectID, _ ics214OID: NSManagedObjectID, _ context: NSManagedObjectContext) {
        ics214ActivityLogSync.ics214ActivityLogSyncQueue.isSuspended = true
        let operation = SingleICS214ActivityLogOperation(userTimeOID, ics214OID, context)
        ics214ActivityLogSync.ics214ActivityLogSyncQueue.addOperation(operation)
        ics214ActivityLogSync.ics214ActivityLogSyncQueue.isSuspended = false
    }
    
    func getICS214PersonnelAssociatedWithICS214(_ userTimeOID: NSManagedObjectID, _ ics214OID: NSManagedObjectID, _ context: NSManagedObjectContext) {
        ics214PersonnelSync.ics214PersonalSyncQueue.isSuspended = true
        let operation = SingleICS214PersonnelOperation(userTimeOID, ics214OID, context)
        ics214PersonnelSync.ics214PersonalSyncQueue.addOperation(operation)
        ics214PersonnelSync.ics214PersonalSyncQueue.isSuspended = false
    }
    
    
        // MARK: -
        // MARK: Notification Handling
        @objc func managedObjectContextDidSave(notification: Notification) {
            DispatchQueue.main.async {
                self.context.mergeChanges(fromContextDidSave: notification)
            }
        }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try self.theICDS214Context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theICDS214Context,userInfo:["info":"SingleICS214BuildFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleICS214BuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }

}
