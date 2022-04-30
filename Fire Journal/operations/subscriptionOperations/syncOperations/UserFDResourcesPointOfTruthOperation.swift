//
//  UserFDResourcesPointOfTruthOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 9/10/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import CloudKit

class UserFDResourcesPointOfTruthOperation: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var userFDResourcesA = [UserFDResources]()
    var fjUserFDResources:UserFDResources!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var fetchedUserFDResource = [UserFDResources]()
    var fetchedUserResources = [UserResources]()
    var cdCount = 0
    var cloudCount = 0
    var theResources =  [String]()
    var customResource: Bool = false
    var theResourceName: String = ""
    let userDefaults = UserDefaults.standard
    var resources = [String]()
    var firstRun: Bool = false
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            self.executing(false)
            self.operation = "UserFDResourcesPointOfTruthOperation"
            self.finish(true)
            return
        }
        print("starting up UserFDResourcesPointOfTruthOperation")
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        cleanDataTable()
        
        guard isCancelled == false else {
            self.executing(false)
            self.operation = "UserFDResourcesPointOfTruthOperation"
            self.finish(true)
            return
        }
        
    }
    
    func fetchTheUserResources()->Array<UserResources> {
        print("starting up UserFDResourcesPointOfTruthOperation fetchTheUserResources")
        var userResourcesArray = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        //
        //        do {
        //            userResourcesArray = (try bkgrdContext.fetch(fetchRequest) as? [UserResources])!
        //            print("here is the userResourcesArray.count  \(userResourcesArray.count)")
        //        } catch {
        //
//        //        }
//        print(fetchRequest)
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [UserResources]
            if !fetched.isEmpty {
                userResourcesArray = fetched
            }
        } catch let error as NSError {
            print("UserFDResourcesPointOfTruthOperation Line91 Fetch Error: \(error.localizedDescription)")
        }
        return userResourcesArray
    }
    
    func cleanTheUserResources()->Array<UserResources> {
        print("starting up UserFDResourcesPointOfTruthOperation cleanTheUserResources")
        let userResourceArray = fetchTheUserResources()
        for resource in userResourceArray {
            let r = resource.resource
            if r != "" {
                resources.append(r!)
            }
        }
        resources = resources.map { $0.uppercased() }
        var resourceSet = Array(Set(resources))
        resourceSet = resourceSet.sorted{ $0 < $1 }
        var array = [UserResources]()
        var sArray = [String]()
        for resource in resourceSet {
            let result = userResourceArray.filter { $0.resource == resource }
            if result.count > 1 {
                for r in result {
                    array.append(r)
                    sArray.append(r.resource!)
                }
            }
        }
        let resourceS = Array(Set(sArray))
        var userResourcesToDelete = [UserResources]()
        for r in resourceS {
            let result = array.filter { $0.resource == r }
            let resource1 = result.first
            let resultSet = result.filter { $0 != resource1 }
            userResourcesToDelete.append(contentsOf: resultSet)
            print("here is the resultSet \(resultSet.count)")
        }
        print("here is the result.count \(array.count)")
        return userResourcesToDelete
    }
    
    func cleanDataTable() {
        print("starting up UserFDResourcesPointOfTruthOperation cleanDataTable")
        let data = cleanTheUserResources()
        var idsArray = [NSManagedObjectID]()
        if data.count > 0 {
            for d in data {
                let id = d.objectID
                idsArray.append(id)
            }
            let deleteRequest = NSBatchDeleteRequest(objectIDs: idsArray)
            do{
                try bkgrdContext.execute(deleteRequest)
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"UserFDResourcesPointOfTruthOperation here"])
                }
                self.getAllUserResources()
                self.getAllUserFDResourcesFromCD()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class UserFDResourcesPointOfTruthOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                print(errorMessage)
            }
        } else {
            self.getAllUserResources()
            self.getAllUserFDResourcesFromCD()
        }
    }
    
    func cdFilterCloud() {
        print("starting up UserFDResourcesPointOfTruthOperation cdFilterCloud")
        for ckr in ckRecordA {
            var ckFDResource: String  = ckr["fdResource"] ?? ""
            ckFDResource = ckFDResource.uppercased()
            let ckFDResourceGuid: String = ckr["fdResourceGuid"] ?? ""
            let ckFDModDate: Date = ckr["fdResourceModDate"] ?? Date()
            let ckFDCreateDate: Date = ckr["fdResourceCreationDate"] ?? Date()
            let customImage: String = ckr["fdResourceImageName"] ?? ""
            if customImage == "Custom" {
                let result = fetchedUserResources.filter { $0.resource == ckFDResource }
                if result.isEmpty {
                    let resource = UserResourcesList.init(display: 0, type: ckFDResource, date: ckFDCreateDate)
                    let userResource = UserResources.init(entity:NSEntityDescription.entity(forEntityName: "UserResources", in: bkgrdContext)!, insertInto: bkgrdContext)
                    
                    userResource.displayOrder = Int64(resource.displayOrder)
                    userResource.entryState = resource.entryState.rawValue
                    userResource.defaultResource = resource.defaultResource
                    userResource.resource = ckFDResource
                    userResource.resourceModificationDate = ckFDModDate
                    userResource.resourceGuid = ckFDResourceGuid
                    userResource.resourceCustom = true
                    userResource.resourceBackUp = true
                    
                    saveToCD()
                }
            }
        }
        
    }
    
    func deleteTheCoreDataUserFDResources(arrayOfIds: [NSManagedObjectID]) {
        print("starting up UserFDResourcesPointOfTruthOperation deleteTheCoreDataUserFDResources")
        let deleteRequest = NSBatchDeleteRequest(objectIDs: arrayOfIds)
        do{
            try bkgrdContext.execute(deleteRequest)
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"UserFDResourcesPointOfTruthOperation here"])
            }
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class UserFDResourcesPointOfTruthOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        processTheCKRecords()
    }
    
    func modifityCloudUserFDResources() {
        print("starting up UserFDResourcesPointOfTruthOperation modifityCloudUserFDResources")
        cdFilterCloud()
        var idsArray = [NSManagedObjectID]()
        if !userFDResourcesA.isEmpty {
            for resource in userFDResourcesA {
                idsArray.append(resource.objectID)
            }
        }
        if !idsArray.isEmpty {
            deleteTheCoreDataUserFDResources(arrayOfIds:idsArray)
        }
    }
    
    func processTheCKRecords() {
        print("starting up UserFDResourcesPointOfTruthOperation processTheCKRecords")
        for ck in ckRecordA {
            let userFDResourceCD = UserFDResources.init(entity: NSEntityDescription.entity(forEntityName: "UserFDResources", in: bkgrdContext)!, insertInto: bkgrdContext)
            userFDResourceCD.updateMyFDResourcesFromCloud(ckRecord: ck)
            print(userFDResourceCD)
            
        }
        moveToCloud()
    }
    
    func moveToCloud() {
        print("starting up UserFDResourcesPointOfTruthOperation moveToCloud")
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: ckRecordA, recordIDsToDelete: nil)
        modifyCKOperation.savePolicy = .allKeys
        modifyCKOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                print("Error modify Incident record to private database \(error.localizedDescription)")
            }
            print(record)
        }
        modifyCKOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
            if let error = error {
                print("Error modify Incident record to private database \(error.localizedDescription)")
                self.executing(false)
                self.operation = "UserFDResourcesPointOfTruthOperation"
                self.finish(true)
            }
            print(savedRecords ?? "no saved records")
            DispatchQueue.main.async {
                self.userDefaults.set(true, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
                self.executing(false)
                self.operation = "UserFDResourcesPointOfTruthOperation"
                self.finish(true)
                self.nc.post(name:Notification.Name(rawValue:FJkRELOADTHEDASHBOARD),
                             object: nil,
                             userInfo: ["recordEntity":""])
                //                    self.endBackgroundTask()
                
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        privateDatabase.add(modifyCKOperation)
    }
    
    
    func saveToCD() {
        print("starting up UserFDResourcesPointOfTruthOperation saveToCD")
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"UserFDResourcesPointOfTruthOperation here"])
            }
        } catch let error as NSError {
            let nserror = error
            let errorMessage = "UserFDResourcesPointOfTruthOperation saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    
    
    func getFDResourceImageName(resource: String) {
        print("starting up UserFDResourcesPointOfTruthOperation getFDResourceImageName")
        theResources = theFDResources.allCases.map{ $0.rawValue }
        let result = theResources.filter { $0 == resource}
        if result.isEmpty {
            customResource = true
            theResourceName = "Custom"
        } else {
            customResource = false
            theResourceName = resource
        }
    }
    
    func getAllUserFDResourcesFromCloud() {
        print("starting up UserFDResourcesPointOfTruthOperation getAllUserFDResourcesFromCloud")
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "fdResourceGuid != %@","")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        let query = CKQuery(recordType: "UserFDResources", predicate: predicateCan)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = { record in
            self.ckRecordA.append(record)
        }
        queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            if let error = error {
                print("Error modify Incident record to private database \(error.localizedDescription)")
            }
            self.cloudCount = self.ckRecordA.count
            self.modifityCloudUserFDResources()
        }
        
        self.privateDatabase.add(queryOperation)
    }
    
    func getAllUserFDResourcesFromCD() {
        print("starting up UserFDResourcesPointOfTruthOperation getAllUserFDResourcesFromCD")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","fdResourceGuid","")
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchedResources = try bkgrdContext.fetch(fetchRequest) as! [UserFDResources]
            
            if fetchedResources.count != 0 {
                for resource in fetchedResources {
                    if resource.fdResource != "" {
                        let fdResource = resource.fdResource!
                        resource.fdResource = fdResource.uppercased()
                        saveToCD()
                    }
                    userFDResourcesA.append(resource)
                }
                self.cdCount =  self.userFDResourcesA.count
            }
            getAllUserFDResourcesFromCloud()
            
        } catch {
            let nserror = error as NSError
            print("TheUserFDResourcesPointOfTruthOperation context \(nserror.localizedDescription) \(nserror.userInfo)")
            self.executing(false)
            self.operation = "UserFDResourcesPointOfTruthOperation"
            self.finish(true)
        }
    }
    
    func getAllUserResources() {
        print("starting up UserFDResourcesPointOfTruthOperation getalluserResources")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources")
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","resourceGuid","")
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        do {
            let fetchedResources = try bkgrdContext.fetch(fetchRequest) as! [UserResources]
            
            if fetchedResources.count != 0 {
                for resource in fetchedResources {
                    if resource.resource != "" {
                        let uResource = resource.resource!
                        resource.resource = uResource.uppercased()
                    }
                    fetchedUserResources.append(resource)
                    saveToCD()
                }
            }
            
        } catch {
            let nserror = error as NSError
            print("TheUserFDResourcesPointOfTruthOperation context \(nserror.localizedDescription) \(nserror.userInfo)")
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
}
