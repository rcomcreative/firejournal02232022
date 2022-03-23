//
//  ICS214ActivityLog+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/21/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension ICS214ActivityLog {
    func newICS214ActivityLogToTheCloud(ckRecordID: CKRecord.ID)->CKRecord {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
        let dateFormatted = dateFormatter.string(from:self.ics214ActivityCreationDate ?? Date())
        let name = "ICS214ActivityLog \(dateFormatted)"
        let fjICS214ALogRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjICS214ALogRID = CKRecord.ID(recordName: name, zoneID: fjICS214ALogRZ.zoneID)
        let fjICS214ALogR = CKRecord.init(recordType: "ICS214ActivityLog", recordID: fjICS214ALogRID)
        let fjICS214ALogRef = CKRecord.Reference(recordID: ckRecordID, action: .deleteSelf)
        if let modDate:Date = self.ics214AcivityModDate {
            fjICS214ALogR["ics214AcivityModDate"] = modDate
        }
        fjICS214ALogR["ics214FormReference"] = fjICS214ALogRef as CKRecordValue
        fjICS214ALogR["ics214ActivityBackedUp"] = self.ics214ActivityBackedUp
        fjICS214ALogR["ics214ActivityChanged"] = self.ics214ActivityChanged
        if let creation:Date = self.ics214ActivityCreationDate {
            fjICS214ALogR["ics214ActivityCreationDate"] = creation
        }
        if let date:Date = self.ics214ActivityDate {
            fjICS214ALogR["ics214ActivityDate"] = date
        }
        fjICS214ALogR["ics214ActivityGuid"] = self.ics214ActivityGuid
        fjICS214ALogR["ics214ActivityLog"] = self.ics214ActivityLog
        fjICS214ALogR["ics214ActivityStringDate"] = self.ics214ActivityStringDate
        fjICS214ALogR["ics214Guid"] = self.ics214Guid
        fjICS214ALogR["theEntity"] = "ICS214ActivityLog"
            
        return fjICS214ALogR
    }
    
    func modifyICS214ALogForCloud(ckRecord:CKRecord)->CKRecord {
        let fjICS214ALogR = ckRecord
        if let modDate:Date = self.ics214AcivityModDate {
            fjICS214ALogR["ics214AcivityModDate"] = modDate
        }
        fjICS214ALogR["ics214ActivityBackedUp"] = self.ics214ActivityBackedUp
        fjICS214ALogR["ics214ActivityChanged"] = self.ics214ActivityChanged
        if let creation:Date = self.ics214ActivityCreationDate {
            fjICS214ALogR["ics214ActivityCreationDate"] = creation
        }
        if let date:Date = self.ics214ActivityDate {
            fjICS214ALogR["ics214ActivityDate"] = date
        }
        fjICS214ALogR["ics214ActivityGuid"] = self.ics214ActivityGuid
        fjICS214ALogR["ics214ActivityLog"] = self.ics214ActivityLog
        fjICS214ALogR["ics214ActivityStringDate"] = self.ics214ActivityStringDate
        fjICS214ALogR["ics214Guid"] = self.ics214Guid
        fjICS214ALogR["theEntity"] = "ICS214ActivityLog"
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214ALogR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.ics214ActivityCKR = data as NSObject
        saveToCD()
        return fjICS214ALogR
    }
    
    func updateICS214ALogFromTheCloud(ckRecord: CKRecord) {
        let fjICS214ALogR = ckRecord
        if let modDate:Date = fjICS214ALogR["ics214AcivityModDate"] {
            self.ics214AcivityModDate = modDate
        }
        self.ics214ActivityBackedUp = fjICS214ALogR["ics214ActivityBackedUp"] ?? false
        self.ics214ActivityChanged = fjICS214ALogR["ics214ActivityChanged"] ?? false
        if let creation:Date = fjICS214ALogR["ics214ActivityCreationDate"] {
            self.ics214ActivityCreationDate = creation
        }
        if let date:Date = fjICS214ALogR["ics214ActivityDate"] {
            self.ics214ActivityDate = date
        }
        self.ics214ActivityGuid = fjICS214ALogR["ics214ActivityGuid"] ?? ""
        self.ics214ActivityLog = fjICS214ALogR["ics214ActivityLog"] ?? ""
        self.ics214ActivityStringDate = fjICS214ALogR["ics214ActivityStringDate"] ?? ""
        self.ics214Guid = fjICS214ALogR["ICS214Guid"] ?? ""
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214ALogR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.ics214ActivityCKR = data as NSObject
        
//        saveToCD()
    }
    
    
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
        } catch {
            let nserror = error as NSError
            let error = "The ICS214ActivityLog+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
}
