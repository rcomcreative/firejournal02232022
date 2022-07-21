//
//  SingleICS214PersonnelOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/13/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleICS214PersonnelOperation: FJOperation {
    
    lazy var ics214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICDS214Context: NSManagedObjectContext!
    
    lazy var userAttendeesProvider: UserAttendeesProvider = {
        let provider = UserAttendeesProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserAttendeesContext: NSManagedObjectContext!
    
    var ckRecord: CKRecord!
    var theICS214: ICS214Form!
    var theICS214FormOID: NSManagedObjectID
    var theICS214PersonnelA = [ICS214Personnel]()
    var theUserTimeID: NSManagedObjectID
    var theUserTime: UserTime!
    let nc = NotificationCenter.default
    var thread:Thread!
    var context: NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    let ics214PersonnelSync = ICS214PersonalSyncOperation()
    let userAttendeesSync = UserAttendeeSyncOperation()
    
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var icsGuid: String = ""
    var theUserAttendeesGuidA = [String]()
    
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
            operation = "SingleICS214PersonnelBuildFromCloudOperation"
            
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
            getThePersonnelForICS214() {_ in
                if !self.theICS214PersonnelA.isEmpty {
                    for personnel in self.theICS214PersonnelA {
                        self.theICS214.addToIcs214PersonneDetail(personnel)
                    }
                    self.saveToCD()
                    self.theUserAttendeesContext = self.userAttendeesProvider.persistentContainer.newBackgroundContext()
                    for guid in  self.theUserAttendeesGuidA {
                        if let userAttendees = self.userAttendeesProvider.isUserAttendeePartOfCD(guid, self.theUserAttendeesContext) {
                            let attendee = userAttendees.last
                            print(attendee)
                        } else {
                            self.userAttendeesProvider.getUserAttendeesCKRecord(guid, self.userAttendeesSync, self.theUserAttendeesContext)
                        }
                    }
                    
                }
            }
        }
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    private func getThePersonnelForICS214(withCompletion completion: @escaping (String) -> Void) {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "ics214Guid == %@", icsGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        let sort = NSSortDescriptor(key: "ics214Guid", ascending: false)
        let query = CKQuery.init(recordType: "ICS214Personnel", predicate: predicateCan)
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
                        let theIcs214Personnel = ICS214Personnel(context: self.theICDS214Context)
                        buildThePersonnel(ckRecord, theIcs214Personnel)
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
    
    private func buildThePersonnel(_ ckRecord: CKRecord, _ theICS214Personnel: ICS214Personnel) {
        self.ckRecord = ckRecord
        if let guid = ckRecord["ics214Guid"] as? String {
            theICS214Personnel.ics214Guid = guid
        }
        if let uGuid = ckRecord["userAttendeeGuid"] as? String {
            theICS214Personnel.userAttendeeGuid = uGuid
            theUserAttendeesGuidA.append(uGuid)
        }
        if let pGuid = ckRecord["ics214PersonelGuid"] as? String {
            theICS214Personnel.ics214PersonelGuid = pGuid
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        theICS214Personnel.ics214PersonnelCKR = data as NSObject
        
        theICS214PersonnelA.append(theICS214Personnel)
        
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theICDS214Context,userInfo:["info":"SingleICS214PersonnelBuildFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleICS214PersonnelBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }

}
