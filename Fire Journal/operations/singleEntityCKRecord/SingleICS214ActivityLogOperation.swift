    //
    //  SingleICS214ActivityLogOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/13/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleICS214ActivityLogOperation: FJOperation {
    
    lazy var ics214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICDS214Context: NSManagedObjectContext!
    
    var ckRecord: CKRecord!
    var theICS214: ICS214Form!
    var theICS214FormOID: NSManagedObjectID
    var theICS214ActivityLogA = [ICS214ActivityLog]()
    var theUserTimeID: NSManagedObjectID
    var theUserTime: UserTime!
    let nc = NotificationCenter.default
    var thread:Thread!
    var context: NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    let ics214SyncOperation = SingleICS214CDFromCloudOperation()
    
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var icsGuid: String = ""
    
    init(_ userTimeID: NSManagedObjectID, _ ics214FormOID: NSManagedObjectID,_ context: NSManagedObjectContext) {
        self.theUserTimeID = userTimeID
        self.context = context
        self.theICS214FormOID = ics214FormOID
        super.init()
        self.theICDS214Context = ics214Provider.persistentContainer.newBackgroundContext()
        self.privateDatabase = myContainer.privateCloudDatabase
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
        operation = "SingleICS214ActivityLogBuildFromCloudOperation"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.theICDS214Context)
        executing(true)
        
        theUserTime = self.theICDS214Context.object(with: theUserTimeID) as? UserTime
        theICS214 = self.theICDS214Context.object(with: theICS214FormOID) as? ICS214Form
        if let guid = theICS214.ics214Guid {
            icsGuid = guid
            getTheActivityLogsForICS214() {_ in
                if !self.theICS214ActivityLogA.isEmpty {
                    for activityLog in self.theICS214ActivityLogA {
                        self.theICS214.addToIcs214ActivityDetail(activityLog)
                    }
                    self.saveToCD()
                }
            }
        } else {
            DispatchQueue.main.async {
                print("SingleICS214ActivityLogOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    private func getTheActivityLogsForICS214(withCompletion completion: @escaping (String) -> Void) {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "ics214Guid == %@", icsGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        let sort = NSSortDescriptor(key: "ics214ActivityDate", ascending: false)
        let query = CKQuery.init(recordType: "ICS214ActivityLog", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        var ics214ActivityLogRA = [CKRecord]()
        operation.recordMatchedBlock = { recordid, result in
            switch result {
            case .success(let record):
                ics214ActivityLogRA .append(record)
            case .failure(let error):
                print("error on retrieving status \(error)")
            }
        }
        operation.queryResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                if !ics214ActivityLogRA.isEmpty {
                    for ckRecord in ics214ActivityLogRA {
                        let theIcs214ActivityLog = ICS214ActivityLog(context: self.theICDS214Context)
                        buildTheActivityLog(ckRecord, theIcs214ActivityLog)
                    }
                    completion("Success")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the status operation error \(error)")
                    completion("Error")
                }
            }
        }
        
        privateDatabase.add(operation)
        
    }
    
    private func buildTheActivityLog(_ ckRecord: CKRecord, _ theIcs214ActivityLog: ICS214ActivityLog) {
        self.ckRecord = ckRecord
        
        if let modDate = self.ckRecord["ics214AcivityModDate"] as? Date {
            theIcs214ActivityLog.ics214AcivityModDate = modDate
        }
        if let ics214ActivityBackedUp = self.ckRecord["ics214ActivityBackedUp"]as? Double {
            theIcs214ActivityLog.ics214ActivityBackedUp  = Bool(truncating: ics214ActivityBackedUp as NSNumber)
        }
        if let ics214ActivityChanged = self.ckRecord["ics214ActivityChanged"]as? Double {
            theIcs214ActivityLog.ics214ActivityChanged  = Bool(truncating: ics214ActivityChanged as NSNumber)
        }
        if let creation = self.ckRecord["ics214ActivityCreationDate"] as? Date {
            theIcs214ActivityLog.ics214ActivityCreationDate = creation
        }
        if let date = self.ckRecord["ics214ActivityDate"] as? Date {
            theIcs214ActivityLog.ics214ActivityDate = date
        }
        if let ics214ActivityGuid = self.ckRecord["ics214ActivityGuid"] as? String {
            theIcs214ActivityLog.ics214ActivityGuid = ics214ActivityGuid
        }
        if let ics214ActivityLog = self.ckRecord["ics214ActivityLog"] as? String {
            theIcs214ActivityLog.ics214ActivityLog = ics214ActivityLog
        }
        if let ics214ActivityStringDate = self.ckRecord["ics214ActivityStringDate"] as? String {
            theIcs214ActivityLog.ics214ActivityStringDate = ics214ActivityStringDate
        }
        if let ics214Guid = ckRecord["ics214Guid"] as? String {
            theIcs214ActivityLog.ics214Guid = ics214Guid
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        self.ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theIcs214ActivityLog.ics214ActivityCKR = data as NSObject
        theICS214ActivityLogA.append(theIcs214ActivityLog)
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
            try self.theICDS214Context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theICDS214Context,userInfo:["info":"SingleICS214ActivityLogBuildFromCloudOperation"])
            }
            DispatchQueue.main.async {
                print("SingleICS214ActivityLogBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleICS214ActivityLogBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
}
