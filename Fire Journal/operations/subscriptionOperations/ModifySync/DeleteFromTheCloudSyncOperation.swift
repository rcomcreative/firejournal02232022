//
//  DeleteFromTheCloudSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/4/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class DeleteFromTheCloudSyncOperation: FJOperation {
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
    var theDate: Date!
    var fetched:Array<Any>!
    
    
    //    MARK: -init of the deleteFromCloudSyncOperation
    init(_ context: NSManagedObjectContext, theDate: Date, theEntity: String, theAttribute: String) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        self.theEntity = theEntity
        self.theAttribute = theAttribute
        self.theDate = theDate
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
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
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func getTheObjectToDelete() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: theEntity )
        let predicate = NSPredicate(format: "%K == %@", theAttribute, theDate as NSDate)
        let sectionSortDescriptor = NSSortDescriptor(key: theAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        switch theEntity {
                case "Incident":
                    do {
                    self.fetched = try bkgrdContext.fetch(fetchRequest) as! [Incident]
                        if let incident = self.fetched.last {
                            bkgrdContext.delete(incident as! NSManagedObject)
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                                print("DeleteFromTheCloudSyncOperation Incident has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("DeleteFromTheCloudSyncOperation Incident Nothing to delete here has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        }
                    } catch let error as NSError {
                        print("\(error.localizedDescription)")
                    }
                case "Journal":
                    do {
                        self.fetched = try bkgrdContext.fetch(fetchRequest) as! [Journal]
                        if let journal = self.fetched.last {
                            bkgrdContext.delete(journal as! NSManagedObject)
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                                print("DeleteFromTheCloudSyncOperation Journal has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("DeleteFromTheCloudSyncOperation Journal Nothing to delete here has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        }
                    } catch let error as NSError {
                        print("\(error.localizedDescription)")
                    }
                case "ICS214Form":
                    do {
                        self.fetched = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
                        if let ics214 = self.fetched.last {
                            bkgrdContext.delete(ics214 as! NSManagedObject)
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                                print("DeleteFromTheCloudSyncOperation ICS214Form has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("DeleteFromTheCloudSyncOperation ICS214Form Nothing to delete here has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        }
                    } catch let error as NSError {
                        print("\(error.localizedDescription)")
                    }
                case "ARCrossForm":
                    do {
                        self.fetched = try bkgrdContext.fetch(fetchRequest) as! [ARCrossForm]
                        if let arcForm = self.fetched.last {
                            bkgrdContext.delete(arcForm as! NSManagedObject)
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"no big deal here"])
                                print("DeleteFromTheCloudSyncOperation arcForm has run and now if finished")
                                self.executing(false)
                                self.finish(true)
                                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("DeleteFromTheCloudSyncOperation arcForm Nothing to delete here has run and now if finished")
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
                        print("DeleteFromTheCloudSyncOperation dispatch Nothing to delete here has run and now if finished")
                        self.executing(false)
                        self.finish(true)
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
            }
    }

}
