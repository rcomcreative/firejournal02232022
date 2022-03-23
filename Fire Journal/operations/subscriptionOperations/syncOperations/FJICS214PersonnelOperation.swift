//
//  FJICS214PersonnelOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/7/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FJICS214PersonnelOperation: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214PersonnelA = [ICS214Personnel]()
    var fjICS214Personnel:ICS214Personnel!
    var fjICS214Form:ICS214Form!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var fetchedICS214s = [ICS214Form]()
    var forms = Set<ICS214Personnel>()
    var guids = Set<String>()
    var ics214Guid = ""
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJICS214PersonnelOperation"
        
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
        fetchedICS214s = getAllTheForms()
        
        for record:CKRecord in ckRecordA {
            let guid = record["ics214Guid"] ?? ""
            guids.insert(guid as! String)
        }
        
        
        
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
            return
        }
        
    }
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
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
            if let guid:String = record["ics214PersonelGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newICS214PersonnelFromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for guid in guids {
            ics214Guid = guid
            _ = theCountICS214(guid:ics214Guid)
            deletefromCDPersonnelUpdate()
            for record in ckRecordA {
                let ics214G:String = record["ics214Guid"] ?? ""
                if ics214G == ics214Guid {
                    newICS214PersonnelFromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        let nc = NotificationCenter.default
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJICS214 PERSONNEL Operation here"])
            }
            DispatchQueue.main.async {
               
                nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjUserFDResource])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "FJICS2114PersonnelOperation saveToCD() Unresolved error \(nserror)"
            print(errorMessage)

            DispatchQueue.main.async {
                
                nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjUserFDResource])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
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
    
    private func deletefromCDPersonnelUpdate() {
        for personnel in fjICS214PersonnelA {
            bkgrdContext.delete(personnel)
            do {
                try bkgrdContext.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJICS214 PERSONNEL Operation here"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "FJICS2114PersonnelOperation delete Unresolved error \(nserror)"
                print(errorMessage)
                
            }
        }
    }
    
    private func theCountICS214(guid: String)->Int {
        let attribute = "ics214Guid"
        let entity = "ICS214Personnel"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjICS214PersonnelA = try bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
            return count
        }  catch let error as NSError {
            let errorMessage = "FJICS214PersonnelOperation fetchRequest \(fetchRequest) for error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
            return 0
        }
    }
    
    private func theCount(guid: String)->Int {
        let attribute = "ics214PersonelGuid"
        let entity = "ICS214Personnel"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjICS214PersonnelA = try bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
            if !fjICS214PersonnelA.isEmpty {
                fjICS214Personnel = fjICS214PersonnelA.last!
            }
            return count
        }  catch let error as NSError {
            let errorMessage = "FJICS214PersonnelOperation fetchRequest \(fetchRequest) for error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
            return 0
        }
    }
    
    private func getTheICS214(guid: String)->Int {
        var count = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate = NSPredicate(format: "%K == %@", "ics214Guid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
            if fetched.isEmpty {
                count = 0
            } else {
                count = count + 1
                fjICS214Form = fetched.last!
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
        return count
    }
    
    private func newICS214PersonnelFromCloud(record: CKRecord)->Void  {
        
        let fjICS214PersonnalR = record
        let guid:String = fjICS214PersonnalR["ics214Guid"] ?? ""
        
        
        let fjuICS214Personnel = ICS214Personnel.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Personnel", in: bkgrdContext)!, insertInto: bkgrdContext)
        
        fjuICS214Personnel.ics214Guid = fjICS214PersonnalR["ics214Guid"] ?? ""
        fjuICS214Personnel.ics214PersonelGuid = fjICS214PersonnalR["ics214PersonelGuid"] ?? ""
//        if let ics214Ref:CKRecord.Reference = fjICS214PersonnalR["ics214Reference"] {
//            fjuICS214Personnel.ics214Reference = ics214Ref as NSObject
//        }
        fjuICS214Personnel.userAttendeeGuid = fjICS214PersonnalR["userAttendeeGuid"] ?? ""
//        if let attendeeRef:String = fjICS214PersonnalR["userAttendeeReference"] {
//            fjuICS214Personnel.userAttendeeReference = attendeeRef as NSObject
//        }
        
        if guid != "" {
            let counter = getTheICS214(guid: guid)
            if counter > 0 {

                
                if fjICS214Form.ics214Guid != "" {
                    fjuICS214Personnel.addToIcs214PersonnelInfo(fjICS214Form)

                }
            }
            
        }
        
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214PersonnalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuICS214Personnel.ics214PersonnelCKR = data as NSObject
        
    }
}
