//
//  NationalPartners+Extensions.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/16/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

extension NationalPartners {
    
    /// Create guid for new National Partner
    /// - Parameters:
    ///   - date: Date()
    ///   - dateFormatter: forms DateFormatter
    /// - Returns: returns formatted guid for new National Partner
    func guidForNationalPartners(_ date: Date, dateFormatter: DateFormatter)->String {
        let resourceDate = date
        self.partnerCreationDate = resourceDate
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "44."+uuidA
        return uuidA1
    }
    
    //    MARK: -Create New CKRecord for NationalPartners-
    func newNationalPartnerForTheCloud(dateFormatter: DateFormatter ) ->CKRecord {
        
        //        MARK: -Create CKRecord-
        var recordName: String = ""
        if let name = self.partnerGuid {
            recordName = name
        } else {
            if self.partnerCreationDate == nil {
                self.partnerCreationDate = Date()
            }
            let createDate = self.partnerCreationDate ?? Date()
            recordName = guidForNationalPartners( createDate, dateFormatter: dateFormatter)
            self.partnerGuid = recordName
        }
        let fjNationalPartnerRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjNationalPartnerRID = CKRecord.ID(recordName: recordName, zoneID: fjNationalPartnerRZ.zoneID)
        let fjNationalPartnerCKRecord = CKRecord.init(recordType: "LocalPartners", recordID: fjNationalPartnerRID)
        let _ = CKRecord.Reference(recordID: fjNationalPartnerRID, action: .deleteSelf)
        
        fjNationalPartnerCKRecord["theEntity"] = "NationalPartners"
        fjNationalPartnerCKRecord["partnerCount"] = self.partnerCount
        if let date = self.partnerCreationDate {
            fjNationalPartnerCKRecord["partnerCreationDate"] = date
        }
        if let guid = self.partnerGuid {
            fjNationalPartnerCKRecord["partnerGuid"] = guid
        }
        if let name = self.partnerName {
            fjNationalPartnerCKRecord["partnerName"] = name
        }
        
        return fjNationalPartnerCKRecord
    }
    /*
    have not included modify or update from cloud as partnerName is set to be unique single entries.
    */
    //    MARK: -NationalPartners modified by CloudKit-
    func modifyNationalPartnersFromCloud(ckRecord: CKRecord) {
        
        if ckRecord["partnerCount"] != nil {
            self.partnerCount = ckRecord["partnerCount"] as! Int64
        }
        if let date = ckRecord["partnerCreationDate"] as? Date {
            self.partnerCreationDate = date
        }
        if let guid = ckRecord["partnerGuid"] as? String {
            self.partnerGuid = guid
        }
        if let name = ckRecord["partnerName"] as? String {
            self.partnerName = name
        }
        
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.partnerCKR = data as NSObject
            
            saveToCD()
    }
    
    //    MARK: -save to core data-
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"NationalPartners Saved"])
                print("journal we have saved to the cloud")
            }
        } catch {
            let nserror = error as NSError
            
            let error = "The NationalPartners+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
    
}
