//
//  SinglePrrojectBuildFromCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/8/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleProjectBuildFromCloudOperation: FJOperation {
    
    lazy var projectProvider: ProjectProvider = {
        let provider = ProjectProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theProjectContext: NSManagedObjectContext!
    
    var ckRecord: CKRecord
    var theProject: PromotionJournal!
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
        self.theProjectContext = projectProvider.persistentContainer.newBackgroundContext()
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
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.theProjectContext)
        executing(true)
        
        theUserTime = self.theProjectContext.object(with: theUserTimeID) as? UserTime
        buildNewProjectFromCloud(record: self.ckRecord) {
            if self.theProject != nil {
                self.theUserTime.addToPromotion(self.theProject)
                self.saveToCD()
                DispatchQueue.main.async {
                    print("SingleProjectBuildFromCloudOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    print("SingleProjectBuildFromCloudOperation has run and now if finished")
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
    
    func buildNewProjectFromCloud(record: CKRecord, completionHandler: (() -> Void)? = nil) {
        theProject = PromotionJournal(context: self.theProjectContext)
        projectProvider.singleProjectFromTheCloud(ckRecord: record, dateFormatter: dateFormatter, theProject, self.theProjectContext) {
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
            try self.theProjectContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theProjectContext,userInfo:["info":"SingleProjectBuildFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleProjectBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }

}
