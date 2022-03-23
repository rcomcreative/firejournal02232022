//
//  FJICS214FormOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import Foundation
import UIKit
import CoreData
import CloudKit


class FJICS214Loader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjICS214FormA = [ICS214Form]()
    var fjICS214:ICS214Form!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJICS214Loader"
        
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
            finish(true)
            return
        }
        
    }
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
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
            if let guid:String = record["ics214Guid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newICS214FromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["ics214Guid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newICS214FromCloud(record: record)
                } else {
                    fjICS214.updateICS214FromTheCloud(ckRecord: record)
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
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJICS214 form Operation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                        object: nil,
                        userInfo: ["recordEntity":TheEntities.fjArcForm])
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "FJICS214FormOperation saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func theCount(guid: String)->Int {
        let attribute = "ics214Guid"
        let entity = "ICS214Form"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjICS214FormA = try context.fetch(fetchRequest) as! [ICS214Form]
            if !fjICS214FormA.isEmpty {
                fjICS214 = fjICS214FormA.last!
            }
            return count
        } catch let error as NSError {
            print("FJICS214Loader Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func newICS214FromCloud(record: CKRecord)->Void  {
        let fjICS214Record = record
        
        let fjuICS214 = ICS214Form.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Form", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjuICS214.ics214Count = fjICS214Record["ics214Count"] ?? 0
        
        // MARK: -BOOLEANS
        
        fjuICS214.ics214BackedUp = true
        
        if fjICS214Record["ics214Completed"] ?? false {
            fjuICS214.ics214Completed = true
        } else {
            fjuICS214.ics214Completed = false
        }
        
        if fjICS214Record["ics214EffortMaster"] ?? false {
            fjuICS214.ics214EffortMaster = true
        } else {
            fjuICS214.ics214EffortMaster = false
        }
        
        if fjICS214Record["ics214SignatureAdded"] ?? false {
            fjuICS214.ics214SignatureAdded = true
        } else {
            fjuICS214.ics214SignatureAdded = false
        }
        
        if fjICS214Record["ics214Updated"]  ?? false{
            fjuICS214.ics214Updated = true
        } else {
            fjuICS214.ics214Updated = false
        }
        
        // MARK: -Dates
        if let comp:Date = fjICS214Record["ics214CompletionDate"] {
            fjuICS214.ics214CompletionDate = comp
        }
        if let from:Date = fjICS214Record["ics214FromTime"] {
            fjuICS214.ics214FromTime = from
        }
        if let modDate:Date = fjICS214Record["ics214ModDate"] {
            fjuICS214.ics214ModDate = modDate
        }
        if let sigDate:Date = fjICS214Record["ics214SignatureDate"] {
            fjuICS214.ics214SignatureDate = sigDate
        }
        if let toTime:Date = fjICS214Record["ics214ToTime"] {
            fjuICS214.ics214ToTime = toTime
        }
        if let lat: String = fjICS214Record["ics214Latitude"] {
            fjuICS214.ics214Latitude = lat
        }
        if let long: String = fjICS214Record["ics214Longitude"] {
            fjuICS214.ics214Longitude = long
        }
        // MARK: -Asset
        if fjuICS214.ics214SignatureAdded {
            if fjICS214Record["ics214Signature"] != nil {
                   fjuICS214.ics214Signature = imageDataFromCloudKit(asset: fjICS214Record["ics214Signature"]!)
            }
        }
        //fjuICS214.ics214Signature = fjICS214Record["ics214Signature
        
        // MARK: -Strings
        if let effort:String = fjICS214Record["ics214Effort"] {
            fjuICS214.ics214Effort = effort
        }
        if let guid:String = fjICS214Record["ics214Guid"] {
            fjuICS214.ics214Guid = guid
        }
        if let position:String = fjICS214Record["ics214ICSPosition"] {
            fjuICS214.ics214ICSPosition = position
        }
        if let incName:String = fjICS214Record["ics214IncidentName"] {
            fjuICS214.ics214IncidentName = incName
        }
        if let incNum:String = fjICS214Record["ics214LocalIncidentNumber"] {
            fjuICS214.ics214LocalIncidentNumber = incNum
        }
        if let masterGuid:String = fjICS214Record["ics214MasterGuid"] {
            fjuICS214.ics214MasterGuid = masterGuid
        }
        if let positionType:String = fjICS214Record["ics214PositionType"] {
            fjuICS214.ics214PositionType = positionType
        }
        if let teamName:String = fjICS214Record["ics214TeamName"] {
            fjuICS214.ics214TeamName = teamName
        }
        if let userName:String = fjICS214Record["ics214UserName"] {
            fjuICS214.ics214UserName = userName
        }
        if let homeAgency:String = fjICS214Record["ics241HomeAgency"] {
            fjuICS214.ics241HomeAgency = homeAgency
        }
        if let preparedPosition:String = fjICS214Record["icsPreparedPosition"] {
            fjuICS214.icsPreparedPosition = preparedPosition
        }
        if let preparedName:String = fjICS214Record["icsPreparfedName"] {
            fjuICS214.icsPreparfedName = preparedName
        }
        if let incGuid:String = fjICS214Record["incidentGuid"] {
            fjuICS214.incidentGuid = incGuid
        }
        if let journalGuid:String = fjICS214Record["journalGuid"] {
            fjuICS214.journalGuid = journalGuid
        }
        
        // MARK: -Location
        /// ics214Location archived with SecureCoding
        if fjICS214Record["ics214Location"] != nil {
            let location = fjICS214Record["ics214Location"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                fjuICS214.ics214LocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
//        fjuICS214.ics214CKReference = fjICS214Record["fjICS214Ref"] as? NSObject
        
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214Record.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuICS214.ics214CKR = data as NSObject
        
        saveToCD()
    }
    
    func imageDataFromCloudKit(asset: CKAsset) -> Data {
           var data: Data!
           do {
               data = try Data(contentsOf: asset.fileURL!)
               return data
           } catch {
               print("error in return image f")
           }
           return data
       }
    
}
