//
//  LocalPartners+Extensions.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/16/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

extension LocalPartners {
    
    /// Create guid for local partners
    /// - Parameters:
    ///   - date: Date()
    ///   - dateFormatter: forms dateformatter
    /// - Returns: formatted guid for the new local partners
    func guidForLocalPartners(_ date: Date, dateFormatter: DateFormatter)->String {
        let resourceDate = date
        self.localPartnerCreationDate = resourceDate
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "43."+uuidA
        return uuidA1
    }
    
    //    MARK: -New Local Partners to CloudKit-
    /// CKRecord from LocalPartner
    /// - Parameter dateFormatter: DateFormatter
    /// - Returns: return ckrecord of LocalPartners object
    func newLocalPartnersToCloudKit(dateFormatter: DateFormatter ) ->CKRecord {
        
        //        MARK: -Create CKRecord-
        var recordName: String = ""
        if let name = self.localPartnerGuid {
            recordName = name
        } else {
            if self.localPartnerCreationDate == nil {
                self.localPartnerCreationDate = Date()
            }
            let createDate = self.localPartnerCreationDate ?? Date()
            recordName = guidForLocalPartners( createDate, dateFormatter: dateFormatter)
            self.localPartnerGuid = recordName
        }
        let fjLocalPartnerRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjLocalPartnerRID = CKRecord.ID(recordName: recordName, zoneID: fjLocalPartnerRZ.zoneID)
        let fjLocalPartnerCKRecord = CKRecord.init(recordType: "LocalPartners", recordID: fjLocalPartnerRID)
        let _ = CKRecord.Reference(recordID: fjLocalPartnerRID, action: .deleteSelf)
        
        fjLocalPartnerCKRecord["theEntity"] = "LocalPartners"
        fjLocalPartnerCKRecord["localPartnerCount"] = self.localPartnerCount
        if let date = self.localPartnerCreationDate {
            fjLocalPartnerCKRecord["localPartnerCreationDate"] = date
        }
        if let guid = self.localPartnerGuid {
            fjLocalPartnerCKRecord["localPartnerGuid"] = guid
        }
        if let name = self.localPartnerName {
            fjLocalPartnerCKRecord["localPartnerName"] = name
        }
        
        return fjLocalPartnerCKRecord
    }
    
    /*
    have not included modify or update from cloud as localPartnerName is set to be unique single entries.
    */
    //    MARK: -LocalPartners modified by CloudKit-
    func modifyLocalPartnersFromCloud(ckRecord: CKRecord) {
        
        if ckRecord["localPartnerCount"] != nil {
            self.localPartnerCount = ckRecord["localPartnerCount"] as! Int64
        }
        if let date = ckRecord["localPartnerCreationDate"] as? Date {
            self.localPartnerCreationDate = date
        }
        if let guid = ckRecord["localPartnerGuid"] as? String {
            self.localPartnerGuid = guid
        }
        if let name = ckRecord["localPartnerName"] as? String {
            self.localPartnerName = name
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.localPartnerCKR = data as NSObject
        
        saveToCD()
    }
    
    //    MARK: -save to core data-
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"LocalPartners Saved"])
                print("journal we have saved to the cloud")
            }
        } catch {
            let nserror = error as NSError
            
            let error = "The LocalPartners+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
    
}
