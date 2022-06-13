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
    var fjICS214Personnel: ICS214Personnel!
    var fjICS214Form: ICS214Form!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var fetchedICS214s = [ICS214Form]()
    var fetchedUserAttendees = [UserAttendees]()
    var forms = Set<ICS214Personnel>()
    var guids = Set<String>()
    var ics214Guid = ""
    
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
        getAllTheForms()

        
        
        
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
            let count = try bkgrdContext.count(for:fetchRequest)
            fjICS214PersonnelA = try bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
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
    
    private func getAllTheUserAttendees() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
        do {
            fetchedUserAttendees = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
                    newICS214PersonnelFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["ics214PersonelGuid"] as? String {
                let result = fjICS214PersonnelA.filter { $0.ics214PersonelGuid == guid }
                if result.isEmpty {
                    newICS214PersonnelFromCloud(record: record)
                } else {
                    fjICS214Personnel = result.last
                    updateICS214PersonelFromCloud(fjICS214PersonnalR: record, fjuICS214Personnel: fjICS214Personnel)
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJICS214 PERSONNEL Operation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjUserFDResource])
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "FJICS2114PersonnelOperation saveToCD() Unresolved error \(nserror)"
            print(errorMessage)

            DispatchQueue.main.async {
                
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjUserFDResource])
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
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
    
    private func deletefromCDPersonnelUpdate() {
        for personnel in fjICS214PersonnelA {
            self.bkgrdContext.delete(personnel)
            do {
                try self.bkgrdContext.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJICS214 PERSONNEL Operation here"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "FJICS2114PersonnelOperation delete Unresolved error \(nserror)"
                print(errorMessage)
                
            }
        }
    }
    
    private func newICS214PersonnelFromCloud(record: CKRecord)->Void  {
        
        let fjICS214PersonnalR = record
        
        let fjuICS214Personnel = ICS214Personnel(context: bkgrdContext)
        
        if let ics214PersonelGuid = fjICS214PersonnalR["ics214PersonelGuid"] as? String {
            fjuICS214Personnel.ics214PersonelGuid = ics214PersonelGuid
        }
        if let userAttendeeGuid = fjICS214PersonnalR["userAttendeeGuid"] as? String {
            fjuICS214Personnel.userAttendeeGuid = userAttendeeGuid
        }
        if let ics214Guid = fjICS214PersonnalR["ics214Guid"] as? String {
            fjuICS214Personnel.ics214Guid = ics214Guid
            let result = fetchedICS214s.filter { $0.ics214Guid == ics214Guid }
            if !result.isEmpty {
                let ics214Form = result.last
                ics214Form?.addToIcs214PersonneDetail(fjuICS214Personnel)
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214PersonnalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuICS214Personnel.ics214PersonnelCKR = data as NSObject
        
    }
    
    func updateICS214PersonelFromCloud( fjICS214PersonnalR: CKRecord, fjuICS214Personnel: ICS214Personnel) {
        
        if let ics214PersonelGuid = fjICS214PersonnalR["ics214PersonelGuid"] as? String {
            fjuICS214Personnel.ics214PersonelGuid = ics214PersonelGuid
        }
        if let userAttendeeGuid = fjICS214PersonnalR["userAttendeeGuid"] as? String {
            fjuICS214Personnel.userAttendeeGuid = userAttendeeGuid
        }
        if let ics214Guid = fjICS214PersonnalR["ics214Guid"] as? String {
            fjuICS214Personnel.ics214Guid = ics214Guid
            let result = fetchedICS214s.filter { $0.ics214Guid == ics214Guid }
            if !result.isEmpty {
                let ics214Form = result.last
                ics214Form?.addToIcs214PersonneDetail(fjuICS214Personnel)
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214PersonnalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuICS214Personnel.ics214PersonnelCKR = data as NSObject
        
    }
    
}
