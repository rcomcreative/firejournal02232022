//
//  ICS214Personnel+CustomAdditions.swift
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

extension ICS214Personnel {
    
    func newICS214PersonnelToTheCloud(ckRecordID: CKRecord.ID)->CKRecord {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
        let dateFormatted = dateFormatter.string(from:Date())
        let name = "ICS214Personnel \(dateFormatted)"
        let fjICS214PersonnelRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjICS214PersonnelRID = CKRecord.ID(recordName: name, zoneID: fjICS214PersonnelRZ.zoneID)
        let fjICS214PersonnelR = CKRecord.init(recordType: "ICS214Personnel", recordID: fjICS214PersonnelRID)
//        let fjICS214PersonnelRef = CKRecord.Reference(recordID: ckRecordID, action: .deleteSelf)
        
        fjICS214PersonnelR["ics214Guid"] = self.ics214Guid ?? ""
        fjICS214PersonnelR["ics214PersonelGuid"] = self.ics214PersonelGuid ?? ""
        fjICS214PersonnelR["userAttendeeGuid"] = self.userAttendeeGuid
        if self.userAttendeeReference != nil {
            fjICS214PersonnelR["userAttendeeReference"] = self.userAttendeeReference as! CKRecord.Reference
        }
//        fjICS214PersonnelR["ics214FormReference"] = fjICS214PersonnelRef as CKRecordValue
        fjICS214PersonnelR["theEntity"] = "ICS214Personnel"
        
        return fjICS214PersonnelR
    }
    
    func modifyICS214PersonnelForCloud(ckRecord:CKRecord)->CKRecord {
        let fjICS214PersonnelR = ckRecord
        
        fjICS214PersonnelR["ics214Guid"] = self.ics214Guid ?? ""
        fjICS214PersonnelR["ics214PersonelGuid"] = self.ics214PersonelGuid ?? ""
//            fjICS214PersonnelR["ics214Reference"] = self.ics214Reference as! CKRecord.Reference
        fjICS214PersonnelR["userAttendeeGuid"] = self.userAttendeeGuid
//            fjICS214PersonnelR["userAttendeeReference"] = self.userAttendeeReference as! String
        
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214PersonnelR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.ics214PersonnelCKR = data as NSObject
        saveToCD()
        
        return fjICS214PersonnelR
    }
    
    func updateICS214PersonnelFromTheCloud(ckRecord: CKRecord) {
        
        let fjICS214PersonnelR = ckRecord
        
        self.ics214Guid = fjICS214PersonnelR["ics214Guid"] ?? ""
        self.ics214PersonelGuid = fjICS214PersonnelR["ics214PersonelGuid"] ?? ""
//        if let ics214Ref:CKRecord.Reference = fjICS214PersonnelR["ics214Reference"] {
//            self.ics214Reference = ics214Ref as NSObject
//        }
        self.userAttendeeGuid = fjICS214PersonnelR["userAttendeeGuid"] ?? ""
//        if let attendeeRef:String = fjICS214PersonnelR["userAttendeeReference"] {
//            self.userAttendeeReference = attendeeRef as NSObject
//        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214PersonnelR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.ics214PersonnelCKR = data as NSObject
        
//        saveToCD()
    }
    
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "ICS214Personnel+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
}
