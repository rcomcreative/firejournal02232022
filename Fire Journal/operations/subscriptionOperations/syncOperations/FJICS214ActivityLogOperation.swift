//
//  FJICS214ActivityLogOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/7/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FJICS214ActivityLogOperation: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214ALogA = [ICS214ActivityLog]()
    var fjICS214ALog:ICS214ActivityLog!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var fetchedICS214s = [ICS214Form]()
    var ics214ActivityLogGuidA = [String]()
    var ics214Form: ICS214Form!
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJICS214ActivityLogOperation:"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        fetchedICS214s = getAllTheForms()
        
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
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214ActivityLog" )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["ics214ActivityGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newICS214ALogFromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["ics214ActivityGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newICS214ALogFromCloud(record: record)
                } else {
                    fjICS214ALog.updateICS214ALogFromTheCloud(ckRecord: record)
                }
                saveALToCD()
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveALToCD() {
        do {
        try bkgrdContext.save()
        DispatchQueue.main.async {
            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJICS214 ACTIVITY LOG Operation here"])
        }
       } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "FJICS214ActivityLogOperation saveToCD() Unresolved error \(nserror)"
                print(errorMessage)
                
            }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJICS214 ACTIVITY LOG Operation here"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjICS214Personnel])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "FJICS214ActivityLogOperation saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjICS214Personnel])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            
        }
    }
    
    private func getAllTheForms()->[ICS214Form] {
        var fetchedForm = [ICS214Form]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        do {
           fetchedForm  = try context.fetch(fetchRequest) as! [ICS214Form]
        } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
        }
        return fetchedForm
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    
    private func theCount(guid: String)->Int {
        let attribute = "ics214ActivityGuid"
        let entity = "ICS214ActivityLog"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjICS214ALogA = try bkgrdContext.fetch(fetchRequest) as! [ICS214ActivityLog]
            if !fjICS214ALogA.isEmpty {
                fjICS214ALog = fjICS214ALogA.last!
            }
            return count
        }  catch let error as NSError {
            let errorMessage = "FJICS214ActivityLogOperation fetchRequest \(fetchRequest) for error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
            return 0
        }
    }
    
    private func newICS214ALogFromCloud(record: CKRecord)->Void  {
        
        let fjICS214ALogR = record
        
        if let guid:String = fjICS214ALogR["ics214Guid"] {
            ics214Form = getTheICS214(guid: guid)
        }
        
        if ics214Form != nil {
        if let _ = ics214Form.ics214Guid {
            let fjuICS214ALog = ICS214ActivityLog.init(entity: NSEntityDescription.entity(forEntityName: "ICS214ActivityLog", in: bkgrdContext)!, insertInto: bkgrdContext)
            if let modDate:Date = fjICS214ALogR["ics214AcivityModDate"] {
                fjuICS214ALog.ics214AcivityModDate = modDate
            }
            fjuICS214ALog.ics214ActivityBackedUp = fjICS214ALogR["ics214ActivityBackedUp"] ?? false
            fjuICS214ALog.ics214ActivityChanged = fjICS214ALogR["ics214ActivityChanged"] ?? false
            if let creation:Date = fjICS214ALogR["ics214ActivityCreationDate"] {
                fjuICS214ALog.ics214ActivityCreationDate = creation
            }
            if let date:Date = fjICS214ALogR["ics214ActivityDate"] {
                fjuICS214ALog.ics214ActivityDate = date
            }
            fjuICS214ALog.ics214ActivityGuid = fjICS214ALogR["ics214ActivityGuid"] ?? ""
            fjuICS214ALog.ics214ActivityLog = fjICS214ALogR["ics214ActivityLog"] ?? ""
            fjuICS214ALog.ics214ActivityStringDate = fjICS214ALogR["ics214ActivityStringDate"] ?? ""
            fjuICS214ALog.ics214Guid = fjICS214ALogR["ics214Guid"]
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            fjICS214ALogR.encodeSystemFields(with: coder)
            let data = coder.encodedData
            fjuICS214ALog.ics214ActivityCKR = data as NSObject
            fjuICS214ALog.addToIcs214ActivityInfo(ics214Form)
            saveALToCD()
        }
        }
    }
    
    private func getTheICS214(guid: String)->ICS214Form {
        var ics214:ICS214Form = ICS214Form()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate = NSPredicate(format: "%K == %@", "ics214Guid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
            if fetched.isEmpty {} else {
                ics214 = fetched.last!
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
        return ics214
    }
    
}
