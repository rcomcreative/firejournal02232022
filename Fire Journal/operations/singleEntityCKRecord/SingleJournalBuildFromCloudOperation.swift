//
//  SingleJournalBuildFromCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/8/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleJournalBuildFromCloudOperation: FJOperation {
    
    lazy var journalProvider: JournalProvider = {
        let provider = JournalProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theJournalContext: NSManagedObjectContext!
    
    var ckRecord: CKRecord
    var theJournal: Journal!
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
        self.theJournalContext = journalProvider.persistentContainer.newBackgroundContext()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "SingleJournalBuildFromCloudOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.theJournalContext)
        executing(true)
        
        theUserTime = self.theJournalContext.object(with: theUserTimeID) as? UserTime
        buildNewJournalFromCloud(record: self.ckRecord) {
            if self.theJournal != nil {
                self.theUserTime.addToJournal(self.theJournal)
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
    
    func buildNewJournalFromCloud(record: CKRecord, completionHandler: (() -> Void)? = nil) {
        theJournal = Journal(context: self.theJournalContext)
        theJournal.singleJournalFromTheCloud(ckRecord: record, dateFormatter: dateFormatter) {
            completionHandler?()
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try theJournalContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theJournalContext,userInfo:["info":"SingleJournalBuildFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleJournalBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    

}
