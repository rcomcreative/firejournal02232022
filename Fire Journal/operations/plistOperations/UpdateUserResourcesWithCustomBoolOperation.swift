//
//  UpdateUserResourcesWithCustomBoolOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/19/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class UpdateUserResourcesWithCustomBoolOperation: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjUserA = [FireJournalUser]()
    var fjUser:FireJournalUser!
    var objectID:NSManagedObjectID? = nil
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var ckRecord:CKRecord!
    let userDefaults = UserDefaults.standard
    var resources = [String]()
    var displayOrders = [Int]()
    var fetchedResources = [UserResources]()
    
    var userResourcesFetched: Array<UserResources>!
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
         
         //        MARK: -FJOperation operation-
         operation = "UpdateUserResourcesWithCustomBoolOperation"
         
         guard isCancelled == false else {
             executing(false)
             finish(true)
             self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
             return
         }
        
        print("starting UpdateUserResourcesWithCustomBoolOperation")
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        let userResources = userDefaults.bool(forKey: FJkSETTINGSUSERRESOURCESCUSTOMCOMMITTED)
        
        if userResources {
            print("FJkSETTINGSUSERRESOURCESCUSTOMCOMMITTED has run and now is finished")
            
            self.executing(false)
            self.finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            self.nc.removeObserver(self,name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),object: nil)
        } else {
            updatingUserResourcesNotCustom()
            updateNilToCustomTrueUserResources()
        }
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                
               self.userDefaults.set(true, forKey: FJkSETTINGSUSERRESOURCESCUSTOMCOMMITTED)
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"UpdateUserResourcesWithCustomBoolOperation has run"])
            }
            DispatchQueue.main.async {
                print("UpdateUserResourcesWithCustomBoolOperation has run and now is finished")
                
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.nc.removeObserver(self,name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The UpdateUserResourcesWithCustomBoolOperation context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("UpdateUserResourcesWithCustomBoolOperation has run and now is finished")
                
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.nc.removeObserver(self,name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),object: nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func getAllResources()->Array<UserResources> {
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let predicate = NSPredicate(format: "%K != %@","resource","")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            userResourcesArray = (try context.fetch(fetchRequest) as? [UserResources])!
            print("here is the userResources \(userResourcesArray.count)")
        } catch {
        }
        
        return userResourcesArray
    }
    
    func filterTheCollectionWithArray()->Array<UserResources>{
        self.userResourcesFetched = getAllResources()
        var resourcesArray = [UserResources]()
        guard let path = Bundle.main.path(forResource: "Resources", ofType:"plist") else { return resourcesArray }
        let dict = NSDictionary(contentsOfFile:path)
        let resources = dict?["resource"] as! Array<String>
        let displayOrders = dict?["displayOrder"] as! Array<Int>
        
        
        
        if dict != nil {
            for (index, _ ) in displayOrders.enumerated() {
                let resource = resources[index]
                let result = self.userResourcesFetched.filter{ $0.resource == resource }
                if !result.isEmpty {
                    resourcesArray.append(result[0])
                }
            }
        }
        print("here are the resources \(resourcesArray.count) here are all the resources \(resourcesArray)")
        return resourcesArray
    }
    
    func fetchUserResourcesForCustomNotMarked()->Array<UserResources> {
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let predicate = NSPredicate(format: "%K = nil","resourceCustom")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        do {
            userResourcesArray = (try context.fetch(fetchRequest) as? [UserResources])!
            print("here is the userResources \(userResourcesArray.count)")
        } catch {
        }
        return userResourcesArray
    }
    
    
    func updateNilToCustomTrueUserResources() {
        let userResourceArray = fetchUserResourcesForCustomNotMarked()
        for resource in userResourceArray {
            resource.resourceCustom = true
        }
        saveToCD()
    }
    
    func updatingUserResourcesNotCustom() {
        let resourcesArray = filterTheCollectionWithArray()
        for resource in resourcesArray {
            let name = resource.resource
            var named = name!.uppercased()
            named = named.replacingOccurrences(of: " ", with: "")
            if named != "" {
                resource.resource = named
            }
            resource.resourceCustom = false
            do {
                try bkgrdContext.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"UpdateUserResourcesWithCustomBoolOperation merge"])
                }
            } catch {
                print("nothing happening here")
            }
        }
    }
    
}
