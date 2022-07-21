//
//  SingleIncidentBuildFromCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/8/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleIncidentBuildFromCloudOperation: FJOperation {

    
    lazy var incidentProvider: IncidentProvider = {
        let provider = IncidentProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theIncidentContext: NSManagedObjectContext!
    
    var ckRecord: CKRecord
    var theIncident: Incident!
    var theUserTimeID: NSManagedObjectID
    var theUserTime: UserTime!
    let nc = NotificationCenter.default
    var thread:Thread!
    var context: NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    
    init( _ ckRecord: CKRecord,_ userTimeID: NSManagedObjectID,_ context: NSManagedObjectContext) {
        self.ckRecord = ckRecord
        self.theUserTimeID = userTimeID
        self.context = context
        super.init()
        self.theIncidentContext = incidentProvider.persistentContainer.newBackgroundContext()
    }
    
    
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "SingleIncidentBuildFromCloudOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.theIncidentContext)
        executing(true)
        
        theUserTime = self.theIncidentContext.object(with: theUserTimeID) as? UserTime
        buildNewIncidentFromCloud(record: self.ckRecord) {
            if self.theIncident != nil {
                self.theUserTime.addToIncident(self.theIncident)
                self.saveToCD()
                DispatchQueue.main.async {
                    print("JournalSyncFromCloudOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    print("JournalSyncFromCloudOperation has run and now if finished")
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
    
    func buildNewIncidentFromCloud(record: CKRecord, completionHandler: (() -> Void)? = nil) {
        theIncident = Incident(context: self.theIncidentContext)
        theIncident.singleIncidentFromTheCloud(ckRecord: record, dateFormatter: dateFormatter) {
            completionHandler?()
        }
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
            try theIncidentContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theIncidentContext,userInfo:["info":"SingleIncidentBuildFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleIncidentBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
}
