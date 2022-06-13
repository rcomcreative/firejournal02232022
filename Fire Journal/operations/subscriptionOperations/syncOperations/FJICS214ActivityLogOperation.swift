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
    var fjICS214ALog: ICS214ActivityLog!
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
    
    deinit {
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
    }
    
    override func main() {
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector: #selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
        executing(true)
        
        let count = theCounter()
        getAllTheForms()
        
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
            let count = try bkgrdContext.count(for:fetchRequest)
            fjICS214ALogA = try bkgrdContext.fetch(fetchRequest) as! [ICS214ActivityLog]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func getAllTheForms() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        do {
            fetchedICS214s  = try bkgrdContext.fetch(fetchRequest) as! [ICS214Form]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            newICS214ALogFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["ics214ActivityGuid"] as? String {
                let result = fjICS214ALogA.filter { $0.ics214ActivityGuid == guid }
                if result.isEmpty {
                    newICS214ALogFromCloud(record: record)
                } else {
                    fjICS214ALog = result.last
                    updateICS214ActivityLogFromCloud(fjICS214ALogR: record, fjuICS214ALog: fjICS214ALog )
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
        
            do {
                try self.bkgrdContext.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJICS214 ACTIVITY LOG Operation here"])
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
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    private func newICS214ALogFromCloud(record: CKRecord)->Void  {
        
        let fjICS214ALogR = record
        
        let fjuICS214ALog = ICS214ActivityLog(context: bkgrdContext)
        if let modDate = fjICS214ALogR["ics214AcivityModDate"] as? Date {
            fjuICS214ALog.ics214AcivityModDate = modDate
        }
        if let ics214ActivityBackedUp = fjICS214ALogR["ics214ActivityBackedUp"] as? Bool {
        fjuICS214ALog.ics214ActivityBackedUp = ics214ActivityBackedUp
        }
        if let ics214ActivityChanged = fjICS214ALogR["ics214ActivityChanged"] as? Bool {
        fjuICS214ALog.ics214ActivityChanged = ics214ActivityChanged
        }
        if let creation = fjICS214ALogR["ics214ActivityCreationDate"] as? Date {
            fjuICS214ALog.ics214ActivityCreationDate = creation
        }
        if let date = fjICS214ALogR["ics214ActivityDate"] as? Date {
            fjuICS214ALog.ics214ActivityDate = date
        }
        if let ics214ActivityGuid = fjICS214ALogR["ics214ActivityGuid"] as? String {
        fjuICS214ALog.ics214ActivityGuid = ics214ActivityGuid
        }
        if let ics214ActivityLog = fjICS214ALogR["ics214ActivityLog"] as? String {
        fjuICS214ALog.ics214ActivityLog = ics214ActivityLog
        }
        if let ics214ActivityStringDate = fjICS214ALogR["ics214ActivityStringDate"] as? String {
        fjuICS214ALog.ics214ActivityStringDate = ics214ActivityStringDate
        }
        if let ics214Guid = fjICS214ALogR["ics214Guid"] as? String {
        fjuICS214ALog.ics214Guid = ics214Guid
            let result = fetchedICS214s.filter { $0.ics214Guid == ics214Guid }
            if !result.isEmpty {
                let ics214Form = result.last
                ics214Form?.addToIcs214ActivityDetail(fjuICS214ALog)
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214ALogR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuICS214ALog.ics214ActivityCKR = data as NSObject
        if ics214Form != nil {
            fjuICS214ALog.addToIcs214ActivityInfo(ics214Form)
        }
        
    }
    
    func updateICS214ActivityLogFromCloud(fjICS214ALogR: CKRecord, fjuICS214ALog: ICS214ActivityLog) {
        
        if let modDate = fjICS214ALogR["ics214AcivityModDate"] as? Date {
            fjuICS214ALog.ics214AcivityModDate = modDate
        }
        if let ics214ActivityBackedUp = fjICS214ALogR["ics214ActivityBackedUp"] as? Bool {
        fjuICS214ALog.ics214ActivityBackedUp = ics214ActivityBackedUp
        }
        if let ics214ActivityChanged = fjICS214ALogR["ics214ActivityChanged"] as? Bool {
        fjuICS214ALog.ics214ActivityChanged = ics214ActivityChanged
        }
        if let creation = fjICS214ALogR["ics214ActivityCreationDate"] as? Date {
            fjuICS214ALog.ics214ActivityCreationDate = creation
        }
        if let date = fjICS214ALogR["ics214ActivityDate"] as? Date {
            fjuICS214ALog.ics214ActivityDate = date
        }
        if let ics214ActivityGuid = fjICS214ALogR["ics214ActivityGuid"] as? String {
        fjuICS214ALog.ics214ActivityGuid = ics214ActivityGuid
        }
        if let ics214ActivityLog = fjICS214ALogR["ics214ActivityLog"] as? String {
        fjuICS214ALog.ics214ActivityLog = ics214ActivityLog
        }
        if let ics214ActivityStringDate = fjICS214ALogR["ics214ActivityStringDate"] as? String {
        fjuICS214ALog.ics214ActivityStringDate = ics214ActivityStringDate
        }
        if let ics214Guid = fjICS214ALogR["ics214Guid"] as? String {
        fjuICS214ALog.ics214Guid = ics214Guid
            let result = fetchedICS214s.filter { $0.ics214Guid == ics214Guid }
            if !result.isEmpty {
                let ics214Form = result.last
                ics214Form?.addToIcs214ActivityDetail(fjuICS214ALog)
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214ALogR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuICS214ALog.ics214ActivityCKR = data as NSObject
        if ics214Form != nil {
            fjuICS214ALog.addToIcs214ActivityInfo(ics214Form)
        }
        
    }
    
    
}
