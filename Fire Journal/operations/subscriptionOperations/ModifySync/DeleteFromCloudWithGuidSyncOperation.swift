//
//  DeleteFromCloudWithGuidSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/4/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class DeleteFromCloudWithGuidSyncOperation: FJOperation {
    
    //    MARK: -OPERATION PROPERTIES
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    var ckRData: Data!
    var theEntity: String = ""
    var theAttribute: String = ""
    var theGuid: String = ""
    var fetched:Array<Any>!
    var myType:MenuItems = MenuItems.journal
    
    
    //    MARK: -init of the deleteFromCloudSyncOperation
    init(_ context: NSManagedObjectContext, theGuid: String, theEntity: String, theAttribute: String) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.theEntity = theEntity
        self.theAttribute = theAttribute
        self.theGuid = theGuid
        if theEntity == "Journal" {
            self.myType = MenuItems.journal
        } else if theEntity == "Incident" {
            self.myType = MenuItems.incidents
        } else if theEntity == "ICS214" {
            self.myType = MenuItems.ics214
        } else if theEntity == "ARCrossForm" {
            self.myType = MenuItems.arcForm
        }
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "DeleteFromCloudWithGuidSyncOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        getTheObjectToDelete()
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.global().async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func getTheObjectToDelete() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: theEntity )
        let predicate = NSPredicate(format: "%K == %@", theAttribute, theGuid)
        let sectionSortDescriptor = NSSortDescriptor(key: theAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        switch myType {
        case .incidents:
            do {
                self.fetched = try bkgrdContext.fetch(fetchRequest) as! [Incident]
                if let incident = self.fetched.last {
                    bkgrdContext.delete(incident as! NSManagedObject)
                    do {
                        try bkgrdContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Delete From Cloud With Guid Sync Operation"])
                            
                        }
                        DispatchQueue.main.async {
                            print("DeleteFromCloudWithGuidSyncOperation Incident has run and now if finished")
                            self.executing(false)
                            self.finish(true)
                            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                        }
                    }   catch let error as NSError {
                        let nserror = error
                        
                        let errorMessage = "List SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
                        print(errorMessage)
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        print("DeleteFromCloudWithGuidSyncOperation Incident Nothing to delete here has run and now if finished")
                        self.executing(false)
                        self.finish(true)
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                }
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            }
        case .journal:
            do {
                self.fetched = try bkgrdContext.fetch(fetchRequest) as! [Journal]
                if let journal = self.fetched.last {
                    bkgrdContext.delete(journal as! NSManagedObject)
                    do {
                        try bkgrdContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Delete From Cloud With Guid Sync Operation"])
                        }
                        DispatchQueue.main.async {
                            print("DeleteFromCloudWithGuidSyncOperation Journal has run and now if finished")
                            self.executing(false)
                            self.finish(true)
                            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                        }
                    }   catch let error as NSError {
                        let nserror = error
                        
                        let errorMessage = "List SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
                        print(errorMessage)
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        print("DeleteFromCloudWithGuidSyncOperation Journal Nothing to delete here has run and now if finished")
                        self.executing(false)
                        self.finish(true)
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                }
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            }
        case .ics214:
            do {
                self.fetched = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
                if let ics214 = self.fetched.last {
                    bkgrdContext.delete(ics214 as! NSManagedObject)
                    do {
                        try bkgrdContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Delete From Cloud With Guid Sync Operation"])
                        }
                        DispatchQueue.main.async {
                            print("DeleteFromCloudWithGuidSyncOperation ICS214Form has run and now if finished")
                            self.executing(false)
                            self.finish(true)
                            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                        }
                    }   catch let error as NSError {
                        let nserror = error
                        
                        let errorMessage = "List SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
                        print(errorMessage)
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        print("DeleteFromCloudWithGuidSyncOperation ICS214Form Nothing to delete here has run and now if finished")
                        self.executing(false)
                        self.finish(true)
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                }
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            }
        case .arcForm:
            do {
                self.fetched = try bkgrdContext.fetch(fetchRequest) as! [ARCrossForm]
                if let arcForm = self.fetched.last {
                    bkgrdContext.delete(arcForm as! NSManagedObject)
                    do {
                        try bkgrdContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Delete From Cloud With Guid Sync Operation"])
                        }
                        DispatchQueue.main.async {
                            print("DeleteFromCloudWithGuidSyncOperation arcForm has run and now if finished")
                            self.executing(false)
                            self.finish(true)
                            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                        }
                    }   catch let error as NSError {
                        let nserror = error
                        
                        let errorMessage = "List SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
                        print(errorMessage)
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        print("DeleteFromCloudWithGuidSyncOperation arcForm Nothing to delete here has run and now if finished")
                        self.executing(false)
                        self.finish(true)
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                }
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            }
            
        default:
            DispatchQueue.main.async {
                print("DeleteFromCloudWithGuidSyncOperation dispatch Nothing to delete here has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
}
