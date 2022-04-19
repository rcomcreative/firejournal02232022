//
//  FJUserFDResourcesSyncOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 9/2/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import CloudKit

class FJUserFDResourcesSyncOperation: FJOperation {
    
    let context: NSManagedObjectContext
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
    var firstRun: Bool = false
    var cloudCount = 0
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord],firstRun: Bool) {
        self.context = context
        self.ckRecordA = ckArray
        self.firstRun = firstRun
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJUserFDResourcesSyncOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
        executing(true)
        
        if firstRun {
            getAllUserFDResourcesFromCloud()
            fromCloudToCoreData {
                saveToCD()
            }
        } else {
            fetchedUserFDResource = getAllTheForms()
            
            let count = theCounter()
            
            if count == 0 {
                chooseNewWithGuid {
                    saveToCD()
                }
            } else {
                chooseNewOrUpdate {
                    saveToCD()
                }
            }
        }
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    //    MARK: -First Run-
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
            //            self.modifityCloudUserFDResources()
        }
        
        self.privateDatabase.add(queryOperation)
    }
    
    fileprivate func saveToCoreData() {
        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context ,userInfo:["info":"FJUserFDResourcesSyncOperation here"])
            }
        } catch let error as NSError {
            let nserror = error
            let errorMessage = "FJUserFDResourcesSyncOperation saveToCoreData() Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context ,userInfo:["info":"FJUserFDResourcesSyncOperation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjCrews])
                self.executing(false)
                self.finish(true)
                print("finished")
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            let errorMessage = "FJUserFDResourcesSyncOperation saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED), object: nil, userInfo: ["recordEntity":TheEntities.fjCrews])
                self.executing(false)
                self.finish(true)
                print("finished")
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["fdResourceGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newUserFDResourcesFromCloud(record: record)
                } else {
                    fjUserFDResources.updateMyFDResourcesFromCloud(ckRecord: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["fdResourceGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newUserFDResourcesFromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    func fromCloudToCoreData(withCompletion completion: () -> Void ) {
        for fdResourceR in ckRecordA {
            let resourceGuid: String = fdResourceR["fdResourceGuid"] ?? ""
            let count = theCounterOfSameness(guid: resourceGuid)
            if count == 0 {
                let ufdResouceCD = UserFDResources(context: self.context)
                let custom: Bool = fdResourceR["customResource"] ?? false
                ufdResouceCD.customResource = custom
                ufdResouceCD.fdResource = fdResourceR["fdResource"]
                ufdResouceCD.fdResourceApparatus = fdResourceR["fdResourceApparatus"]
                ufdResouceCD.fdResourceBackup = fdResourceR["fdResourceBackup"] ?? false
                ufdResouceCD.fdResourceCreationDate = fdResourceR["fdResourceCreationDate"]
                ufdResouceCD.fdResourceDescription = fdResourceR["fdResourceDescription"]
                ufdResouceCD.fdResourceGuid = fdResourceR["fdResourceGuid"]
                ufdResouceCD.fdResourceID = fdResourceR["fdResourceID"]
                if custom {
                     ufdResouceCD.fdResourceImageName = "Custom"
                } else {
                    ufdResouceCD.fdResourceImageName = fdResourceR["fdResourceImageName"]
                }
                ufdResouceCD.fdResourceModDate = fdResourceR["fdResourceModDate"]
                ufdResouceCD.fdResourcesDetails = fdResourceR["fdResourcesDetails"] ?? false
                ufdResouceCD.fdResourcesSpecialties = fdResourceR["fdResourcesSpecialties"]
                ufdResouceCD.fdResourceType = fdResourceR["fdResourceType"] ?? 0001
//                ufdResouceCD.userReference = fdResourceR["userReference"] as? NSObject
                ufdResouceCD.fdManufacturer = fdResourceR["fdManufacturer"]
                ufdResouceCD.fdShopNumber = fdResourceR["fdShopNumber"]
                ufdResouceCD.fdYear = fdResourceR["fdYear"]
//                if let customResource: String = fdResourceR["fdResourceImageName"] {
                    if custom {
                        let userResources  = UserResources(context: self.context)
                        userResources.defaultResource = false
                        userResources.fdResource = true
                        userResources.resource = fdResourceR["fdResource"]
                        userResources.resourceBackUp = true
                        userResources.resourceCustom = true
                        userResources.resourceModificationDate = fdResourceR["fdResourceModDate"]
                        userResources.resourceGuid = fdResourceR["fdResourceGuid"]
                    }
//                }
                saveToCoreData()
            }
        }
        completion()
    }
    
    func newUserFDResourcesFromCloud(record: CKRecord)->Void  {
        let fdResourceR = record
        
        let ufdResouceCD = UserFDResources(context: self.context)
        let custom: Bool = fdResourceR["customResource"] ?? false
        ufdResouceCD.customResource = custom
        ufdResouceCD.fdResource = fdResourceR["fdResource"]
        ufdResouceCD.fdResourceApparatus = fdResourceR["fdResourceApparatus"]
        ufdResouceCD.fdResourceBackup = fdResourceR["fdResourceBackup"] ?? false
        ufdResouceCD.fdResourceCreationDate = fdResourceR["fdResourceCreationDate"]
        ufdResouceCD.fdResourceDescription = fdResourceR["fdResourceDescription"]
        ufdResouceCD.fdResourceGuid = fdResourceR["fdResourceGuid"]
        ufdResouceCD.fdResourceID = fdResourceR["fdResourceID"]
        ufdResouceCD.fdResourceImageName = fdResourceR["fdResourceImageName"]
        ufdResouceCD.fdResourceModDate = fdResourceR["fdResourceModDate"]
        ufdResouceCD.fdResourcesDetails = fdResourceR["fdResourcesDetails"] ?? false
        ufdResouceCD.fdResourcesSpecialties = fdResourceR["fdResourcesSpecialties"]
        ufdResouceCD.fdResourceType = fdResourceR["fdResourceType"] ?? 0001
//        ufdResouceCD.userReference = fdResourceR["userReference"] as? NSObject
        ufdResouceCD.fdManufacturer = fdResourceR["fdManufacturer"]
        ufdResouceCD.fdShopNumber = fdResourceR["fdShopNumber"]
        ufdResouceCD.fdYear = fdResourceR["fdYear"]
            if custom {
                let userResources  = UserResources(context: self.context)
                userResources.defaultResource = false
                userResources.fdResource = true
                userResources.resource = fdResourceR["fdResource"]
                userResources.resourceBackUp = true
                userResources.resourceCustom = true
                userResources.resourceModificationDate = fdResourceR["fdResourceModDate"]
                userResources.resourceGuid = fdResourceR["fdResourceGuid"]
            }
        
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources" )
        do {
            let count = try self.context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func getAllTheForms()->[UserFDResources] {
        var fetchedForm = [UserFDResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources" )
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        do {
            fetchedForm  = try self.context.fetch(fetchRequest) as! [UserFDResources]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return fetchedForm
    }
    
    private func theCounterOfSameness(guid: String)->Int {
        let entity = "UserFDResources"
        let attribute = "fdResourceGuid"
        var count = 0
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            count = try self.context.count(for:fetchRequest)
            return count
        }  catch let error as NSError {
            let errorMessage = "FJUserFDResourcesSyncOperation fetchRequest \(fetchRequest) for error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
            return 0
        }
    }
    
    private func theCount(guid: String)->Int {
        let attribute = "fdResourceGuid"
        let entity = "UserFDResources"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try self.context.count(for:fetchRequest)
            userFDResourcesA = try self.context.fetch(fetchRequest) as! [UserFDResources]
            if !userFDResourcesA.isEmpty {
                fjUserFDResources = userFDResourcesA.last!
            }
            return count
        }  catch let error as NSError {
            let errorMessage = "FJUserFDResourcesSyncOperation fetchRequest \(fetchRequest) for error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
            return 0
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
