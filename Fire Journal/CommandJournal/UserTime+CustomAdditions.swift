//
//  UserTime+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/12/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension UserTime {
    
    func newUserTimeToTheCloud()->CKRecord {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
        let dateFormatted = dateFormatter.string(from: self.userStartShiftTime ?? Date())
        let name = "UserTime \(dateFormatted)"
        let fjuserTimeRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjuserTimeRID = CKRecord.ID(recordName: name, zoneID: fjuserTimeRZ.zoneID)
        let fjUserTimeRecord = CKRecord.init(recordType: "UserTime", recordID: fjuserTimeRID)
        _ = CKRecord.Reference(recordID: fjuserTimeRID, action: .deleteSelf)
        fjUserTimeRecord["endShiftDiscussion"] = self.endShiftDiscussion ?? ""
        fjUserTimeRecord["endShiftSupervisor"] = self.endShiftSupervisor ?? ""
        fjUserTimeRecord["endShiftStatus"] = self.endShiftStatus
        fjUserTimeRecord["enShiftRelievedBy"] = self.enShiftRelievedBy ?? ""
        fjUserTimeRecord["entryState"] = self.entryState
        fjUserTimeRecord["startShiftApparatus"] = self.startShiftApparatus ?? ""
        fjUserTimeRecord["startShiftAssignment"] = self.startShiftAssignment ?? ""
        fjUserTimeRecord["startShiftCrew"] = self.startShiftCrew ?? ""
        fjUserTimeRecord["startShiftDiscussion"] = self.startShiftDiscussion ?? ""
        fjUserTimeRecord["startShiftFireStation"] = self.startShiftFireStation ?? ""
        fjUserTimeRecord["startShiftPlatoon"] = self.startShiftPlatoon ?? ""
        fjUserTimeRecord["startShiftRelieving"] = self.startShiftRelieving ?? ""
        fjUserTimeRecord["startShiftResources"] = self.startShiftResources ?? ""
        fjUserTimeRecord["startShiftSupervisor"] = self.startShiftSupervisor ?? ""
        fjUserTimeRecord["startShiftStatus"] = self.startShiftStatus
        fjUserTimeRecord["updateShiftDiscussion"] = self.updateShiftDiscussion ?? ""
        fjUserTimeRecord["updateShiftFireStation"] = self.updateShiftFireStation ?? ""
        fjUserTimeRecord["updateShiftPlatoon"] = self.updateShiftPlatoon ?? ""
        fjUserTimeRecord["updateShiftRelievedBy"] = self.updateShiftRelievedBy ?? ""
        fjUserTimeRecord["updateShiftSupervisor"] = self.updateShiftSupervisor ?? ""
        fjUserTimeRecord["updateShiftStatus"] = self.updateShiftStatus
        if let endDate:Date = self.userEndShiftTime {
            fjUserTimeRecord["userEndShiftTime"] = endDate
        }
        if let startDate:Date = self.userStartShiftTime {
            fjUserTimeRecord["userStartShiftTime"] = startDate
        }
        fjUserTimeRecord["userTimeBackup"] = self.userTimeBackup
        fjUserTimeRecord["userTimeDayOfYear"] = self.userTimeDayOfYear ?? "1"
        fjUserTimeRecord["userTimeGuid"] = self.userTimeGuid ?? ""
        fjUserTimeRecord["userTimeYear"] = self.userTimeYear ?? ""
        if let updateDate:Date = self.userUpdateShiftTime {
            fjUserTimeRecord["userUpdateShiftTime"] = updateDate
        }
        fjUserTimeRecord["theEntity"] = "UserTime"
        
        return fjUserTimeRecord
    }
    
    func modifyUserTimeForCloud(ckRecord:CKRecord)->CKRecord {
        let fjUserTimeRecord = ckRecord
        fjUserTimeRecord["endShiftDiscussion"] = self.endShiftDiscussion
        fjUserTimeRecord["endShiftSupervisor"] = self.endShiftSupervisor
        fjUserTimeRecord["endShiftStatus"] = self.endShiftStatus
        fjUserTimeRecord["enShiftRelievedBy"] = self.enShiftRelievedBy
        fjUserTimeRecord["entryState"] = self.entryState
        fjUserTimeRecord["startShiftApparatus"] = self.startShiftApparatus
        fjUserTimeRecord["startShiftAssignment"] = self.startShiftAssignment
        fjUserTimeRecord["startShiftCrew"] = self.startShiftCrew
        fjUserTimeRecord["startShiftDiscussion"] = self.startShiftDiscussion
        fjUserTimeRecord["startShiftFireStation"] = self.startShiftFireStation
        fjUserTimeRecord["startShiftPlatoon"] = self.startShiftPlatoon
        fjUserTimeRecord["startShiftRelieving"] = self.startShiftRelieving
        fjUserTimeRecord["startShiftSupervisor"] = self.startShiftSupervisor
        fjUserTimeRecord["startShiftResources"] = self.startShiftResources
        fjUserTimeRecord["startShiftStatus"] = self.startShiftStatus
        fjUserTimeRecord["updateShiftDiscussion"] = self.updateShiftDiscussion
        fjUserTimeRecord["updateShiftFireStation"] = self.updateShiftFireStation
        fjUserTimeRecord["updateShiftPlatoon"] = self.updateShiftPlatoon
        fjUserTimeRecord["updateShiftRelievedBy"] = self.updateShiftRelievedBy
        fjUserTimeRecord["updateShiftSupervisor"] = self.updateShiftSupervisor ?? ""
        fjUserTimeRecord["updateShiftStatus"] = self.updateShiftStatus
        if let endDate:Date = self.userEndShiftTime {
            fjUserTimeRecord["userEndShiftTime"] = endDate
        }
        if let startDate:Date = self.userStartShiftTime {
            fjUserTimeRecord["userStartShiftTime"] = startDate
        }
        fjUserTimeRecord["userTimeBackup"] = self.userTimeBackup
        fjUserTimeRecord["userTimeDayOfYear"] = self.userTimeDayOfYear
        fjUserTimeRecord["userTimeGuid"] = self.userTimeGuid
        fjUserTimeRecord["userTimeYear"] = self.userTimeYear
        if let updateDate:Date = self.userUpdateShiftTime {
            fjUserTimeRecord["userUpdateShiftTime"] = updateDate
        }
        fjUserTimeRecord["theEntity"] = "UserTime"
        
        return fjUserTimeRecord
    }
    
    func updateUserTimeFromTheCloud(ckRecord: CKRecord) {
        let fjUserTimeRecord = ckRecord
        self.endShiftDiscussion = fjUserTimeRecord["endShiftDiscussion"] ?? ""
        self.endShiftSupervisor = fjUserTimeRecord["endShiftSupervisor"] ?? ""
        self.endShiftStatus = fjUserTimeRecord["endShiftStatus"] ?? false
        self.enShiftRelievedBy = fjUserTimeRecord["enShiftRelievedBy"] ?? ""
        self.entryState = fjUserTimeRecord["entryState"] ?? 0
        self.startShiftApparatus = fjUserTimeRecord["startShiftApparatus"] ?? ""
        self.startShiftAssignment = fjUserTimeRecord["startShiftAssignment"] ?? ""
        self.startShiftCrew = fjUserTimeRecord["startShiftCrew"] ?? ""
        self.startShiftDiscussion = fjUserTimeRecord["startShiftDiscussion"] ?? ""
        self.startShiftFireStation = fjUserTimeRecord["startShiftFireStation"] ?? ""
        self.startShiftPlatoon = fjUserTimeRecord["startShiftPlatoon"] ?? ""
        self.startShiftRelieving = fjUserTimeRecord["startShiftRelieving"] ?? ""
        self.startShiftSupervisor = fjUserTimeRecord["startShiftSupervisor"] ?? ""
        self.startShiftResources = fjUserTimeRecord["startShiftResource"] ?? ""
        self.startShiftStatus = fjUserTimeRecord["startShiftStatus"] ?? false
        self.updateShiftDiscussion = fjUserTimeRecord["updateShiftDiscussion"] ?? ""
        self.updateShiftFireStation = fjUserTimeRecord["updateShiftFireStation"] ?? ""
        self.updateShiftPlatoon = fjUserTimeRecord["updateShiftPlatoon"] ?? ""
        self.updateShiftRelievedBy = fjUserTimeRecord["updateShiftRelievedBy"] ?? ""
        self.updateShiftSupervisor = fjUserTimeRecord["updateShiftSupervisor"] ?? ""
        self.updateShiftStatus = fjUserTimeRecord["updateShiftStatus"] ?? false
        if let endShiftDate:Date = fjUserTimeRecord["userEndShiftTime"] {
            self.userEndShiftTime = endShiftDate
        }
        if let startShiftTime:Date = fjUserTimeRecord["userStartShiftTime"] {
            self.userStartShiftTime = startShiftTime
        }
        self.userTimeBackup = fjUserTimeRecord["userTimeBackup"] ?? false
        self.userTimeDayOfYear = fjUserTimeRecord["userTimeDayOfYear"] ?? ""
        self.userTimeGuid = fjUserTimeRecord["userTimeGuid"] ?? ""
        self.userTimeYear = fjUserTimeRecord["userTimeYear"] ?? ""
        if let updateDate:Date = fjUserTimeRecord["userUpdateShiftTime"] {
            self.userUpdateShiftTime = updateDate
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjUserTimeRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjUserTimeCKR = data as NSObject
        saveToCD()
    }
    
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
        } catch let error as NSError {
            let nserror = error
            let error = "The ICS214ActivityLog+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
}
