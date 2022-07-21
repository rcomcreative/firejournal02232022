    //
    //  ICS214Provider.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import CoreData
import CloudKit

class ICS214Provider: NSObject {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var theICS214: ICS214Form!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var theICS214R: CKRecord!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func singleICSFromTheCloud(ckRecord: CKRecord, dateFormatter: DateFormatter,_ ics214: ICS214Form, _ context: NSManagedObjectContext, completionHandler: (() -> Void)? = nil) {
        
        self.context = context
        self.theICS214R = ckRecord
        self.theICS214 = ics214
        
        self.theICS214.ics214Count = theICS214R["ics214Count"] ?? 0
        
        
            // MARK: -BOOLEANS
        
        self.theICS214.ics214BackedUp = true
        
        
        if let ics214Completed = theICS214R["ics214Completed"]as? Double {
            self.theICS214.ics214Completed  = Bool(truncating: ics214Completed as NSNumber)
        }
        
        if let ics214EffortMaster = theICS214R["ics214EffortMaster"]as? Double {
            self.theICS214.ics214EffortMaster  = Bool(truncating: ics214EffortMaster as NSNumber)
        }
        
        if let ics214SignatureAdded = theICS214R["ics214SignatureAdded"]as? Double {
            self.theICS214.ics214SignatureAdded  = Bool(truncating: ics214SignatureAdded as NSNumber)
        }
        
        if let ics214Updated = theICS214R["ics214Updated"]as? Double {
            self.theICS214.ics214Updated  = Bool(truncating: ics214Updated as NSNumber)
        }
        
        
            // MARK: -Dates
        if let comp = theICS214R["ics214CompletionDate"] as? Date {
            self.theICS214.ics214CompletionDate = comp
        }
        if let from = theICS214R["ics214FromTime"] as? Date {
            self.theICS214.ics214FromTime = from
        }
        if let modDate = theICS214R["ics214ModDate"] as? Date {
            self.theICS214.ics214ModDate = modDate
        }
        if let sigDate = theICS214R["ics214SignatureDate"] as? Date {
            self.theICS214.ics214SignatureDate = sigDate
        }
        if let toTime = theICS214R["ics214ToTime"] as? Date {
            self.theICS214.ics214ToTime = toTime
        }
        if let lat = theICS214R["ics214Latitude"] as? String {
            self.theICS214.ics214Latitude = lat
        }
        if let long = theICS214R["ics214Longitude"] as? String  {
            self.theICS214.ics214Longitude = long
        }
            // MARK: -Asset
        if self.theICS214.ics214SignatureAdded {
            if theICS214R["ics214Signature"] as? CKAsset != nil {
                self.theICS214.ics214Signature = imageDataFromCloudKit(asset: theICS214R["ics214Signature"]!)
            }
        }
            // MARK: -Strings
        if let effort = theICS214R["ics214Effort"] as? String  {
            self.theICS214.ics214Effort = effort
        }
        if let guid = theICS214R["ics214Guid"] as? String  {
            self.theICS214.ics214Guid = guid
        }
        if let position = theICS214R["ics214ICSPosition"] as? String  {
            self.theICS214.ics214ICSPosition = position
        }
        if let incName = theICS214R["ics214IncidentName"] as? String  {
            self.theICS214.ics214IncidentName = incName
        }
        if let incNum = theICS214R["ics214LocalIncidentNumber"] as? String  {
            self.theICS214.ics214LocalIncidentNumber = incNum
        }
        if let masterGuid = theICS214R["ics214MasterGuid"] as? String  {
            self.theICS214.ics214MasterGuid = masterGuid
        }
        if let positionType = theICS214R["ics214PositionType"]  as? String  {
            self.theICS214.ics214PositionType = positionType
        }
        if let teamName = theICS214R["ics214TeamName"] as? String  {
            self.theICS214.ics214TeamName = teamName
        }
        if let userName = theICS214R["ics214UserName"] as? String  {
            self.theICS214.ics214UserName = userName
        }
        if let homeAgency = theICS214R["ics241HomeAgency"] as? String  {
            self.theICS214.ics241HomeAgency = homeAgency
        }
        if let preparedPosition = theICS214R["icsPreparedPosition"] as? String  {
            self.theICS214.icsPreparedPosition = preparedPosition
        }
        if let preparedName = theICS214R["icsPreparfedName"] as? String  {
            self.theICS214.icsPreparfedName = preparedName
        }
        if let incGuid = theICS214R["incidentGuid"] as? String  {
            self.theICS214.incidentGuid = incGuid
        }
        if let journalGuid = theICS214R["journalGuid"] as? String  {
            self.theICS214.journalGuid = journalGuid
        }
        
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        theICS214R.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.theICS214.ics214CKR = data as NSObject
        
        saveTheSingleCD() {_ in
            completionHandler?()
        }
        
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
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        if self.context != nil {
            do {
                try self.context?.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Incident Saved"])
                    print("project we have saved to the cloud")
                }
                completion("Success")
            } catch {
                let nserror = error as NSError
                
                let error = "The ProjectProvider context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
                print(error)
                completion("Error")
            }
        }
    }
    
    
    
}
