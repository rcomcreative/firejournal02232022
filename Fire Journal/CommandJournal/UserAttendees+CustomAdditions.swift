//
//  UserAttendees+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/22/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

extension UserAttendees {
    
    func newUserAttendeesToTheCloud()->CKRecord {
        
        var recordName: String = ""
       if let name = self.attendeeGuid {
           recordName = name
       }
        if recordName == "" {
           let theDate = self.attendeeModDate ?? Date()
           let groupDate = GuidFormatter.init(date:theDate)
           let grGuid:String = groupDate.formatGuid()
           self.attendeeGuid = "79."+grGuid
            if let guid = self.attendeeGuid {
                recordName = guid
            }
       }
        
        let fjUserAttendeesRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjUserAttendeesRID = CKRecord.ID(recordName: recordName, zoneID: fjUserAttendeesRZ.zoneID)
        let fjUserAttendeesRecord = CKRecord.init(recordType: "UserAttendee", recordID: fjUserAttendeesRID)
        
        fjUserAttendeesRecord["attendeeGuid"] = self.attendeeGuid
        fjUserAttendeesRecord["theEntity"] = "UserAttendees"
        fjUserAttendeesRecord["attendee"] = self.attendee
        fjUserAttendeesRecord["attendeeEmail"] = self.attendeeEmail
        fjUserAttendeesRecord["attendeePhone"] = self.attendeePhone
        fjUserAttendeesRecord["attendeeHomeAgency"] = self.attendeeHomeAgency
        fjUserAttendeesRecord["attendeeICSPosition"] = self.attendeeICSPosition
        fjUserAttendeesRecord["attendeeApparatus"] = self.attendeeApparatus
        fjUserAttendeesRecord["attendeeAssignment"] = self.attendeeAssignment
        if (self.attendeeBackUp != nil) {
            fjUserAttendeesRecord["attendeeBackUp"] = true
        } else {
            fjUserAttendeesRecord["attendeeBackUp"] = false
        }
        fjUserAttendeesRecord["attendeeModDate"] = self.attendeeModDate
        
        return fjUserAttendeesRecord
    }
    
    func modifyUserAttendeesFormForCloud(ckRecord:CKRecord)->CKRecord {
        let fjUserAttendeesRecord = ckRecord
        
        fjUserAttendeesRecord["attendeeGuid"] = self.attendeeGuid
        fjUserAttendeesRecord["theEntity"] = "UserAttendees"
        fjUserAttendeesRecord["attendee"] = self.attendee
        fjUserAttendeesRecord["attendeeEmail"] = self.attendeeEmail
        fjUserAttendeesRecord["attendeePhone"] = self.attendeePhone
        fjUserAttendeesRecord["attendeeHomeAgency"] = self.attendeeHomeAgency
        fjUserAttendeesRecord["attendeeICSPosition"] = self.attendeeICSPosition
        fjUserAttendeesRecord["attendeeApparatus"] = self.attendeeApparatus
        fjUserAttendeesRecord["attendeeAssignment"] = self.attendeeAssignment
        if (self.attendeeBackUp != nil) {
            fjUserAttendeesRecord["attendeeBackUp"] = true
        } else {
            fjUserAttendeesRecord["attendeeBackUp"] = false
        }
        fjUserAttendeesRecord["attendeeModDate"] = self.attendeeModDate
        
        return fjUserAttendeesRecord
    }
    
    
    
    func updateUserAttendeesFromTheCloud(ckRecord: CKRecord) {
        let fjUserAttendeesRecord = ckRecord
        
        self.attendeeGuid = fjUserAttendeesRecord["attendeeGuid"] ?? ""
        self.attendee = fjUserAttendeesRecord["attendee"] ?? ""
        self.attendeeEmail = fjUserAttendeesRecord["attendeeEmail"] ?? ""
        self.attendeePhone = fjUserAttendeesRecord["attendeePhone"] ?? ""
        self.attendeeHomeAgency = fjUserAttendeesRecord["attendeeHomeAgency"] ?? ""
        self.attendeeICSPosition = fjUserAttendeesRecord["attendeeICSPosition"] ?? ""
        self.attendeeBackUp = true
        
        self.attendeeApparatus = fjUserAttendeesRecord["attendeeApparatus"] ?? ""
        self.attendeeAssignment = fjUserAttendeesRecord["attendeeAssignment"] ?? ""
        self.attendeeModDate = fjUserAttendeesRecord["attendeeModDate"] ?? Date()
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserAttendeesRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjUserAttendeeCKR = data as NSObject
        
        saveToCD()
    }
    
    fileprivate func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            print("UserAttendees+CustomAdditions.swift we have saved from the cloud")
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "UserAttendees+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
        
        
}
