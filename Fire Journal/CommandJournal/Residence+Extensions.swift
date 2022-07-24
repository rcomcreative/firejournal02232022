//
//  Residence+Extensions.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/16/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import Foundation
import CloudKit
import UIKit
import CoreData

extension Residence {
    
    /// Create the guid for the new residence
    /// - Parameters:
    ///   - date: Date()
    ///   - dateFormatter:form dateformatter
    /// - Returns: returns formatted guid for new residence type
    func guidForResidence(_ date: Date, dateFormatter: DateFormatter)->String {
        let residenceDate = date
        self.residenceCreationDate = residenceDate
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: residenceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "42."+uuidA
        return uuidA1
    }
    
    //    MARK: -NEW RESIDENCE FOR THE CLOUD-
    /// create ckrecord for new residence
    /// - Parameter dateFormatter: DateFormatter
    /// - Returns: build ckrecord for residence returned
    func newResidenceForTheCloud(dateFormatter: DateFormatter ) ->CKRecord {
        
        //        MARK: -Create CKRecord-
        var recordName: String = ""
        if let name = self.residenceGuid {
            recordName = name
        } else {
            if self.residenceCreationDate == nil {
                self.residenceCreationDate = Date()
            }
            let createDate = self.residenceCreationDate ?? Date()
            recordName = guidForResidence( createDate, dateFormatter: dateFormatter)
            self.residenceGuid = recordName
        }
        let fjResidenceRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjResidenceRID = CKRecord.ID(recordName: recordName, zoneID: fjResidenceRZ.zoneID)
        let residenceCKRecord = CKRecord.init(recordType: "Residence", recordID: fjResidenceRID)
        let _ = CKRecord.Reference(recordID: fjResidenceRID, action: .deleteSelf)
        
        residenceCKRecord["theEntity"] = "Residence"
        if let r = self.residence {
            residenceCKRecord["residence"] = r
        }
        residenceCKRecord["residenceCounted"] = self.residenceCount
        if let date = self.residenceCreationDate {
            residenceCKRecord["residenceCreationDate"] = date
        }
        if let guid = self.residenceGuid {
            residenceCKRecord["residenceGuid"] = guid
        }
        
        return residenceCKRecord
        
    }
    
/*
     have not included modify or update from cloud as residence is set to be unique single entries.
     */
    
    //    MARK: -Residence modified by CloudKit-
    func modifyResidenceFromCloud(ckRecord: CKRecord) {
        
        if let r = ckRecord["residence"] as? String {
            self.residence = r
        }
        if ckRecord["residenceCounted"] != nil {
            self.residenceCount = ckRecord["residenceCounted"] as! Int64
        }
        if let date = ckRecord["residenceCreationDate"] as? Date {
            self.residenceCreationDate = date
        }
        if let guid = ckRecord["residenceGuid"] as? String {
            self.residenceGuid = guid
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.residenceCKR = data as NSObject
        
        saveToCD()
    }
    
    //    MARK: -save to core data-
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"Residence Saved"])
                print("journal we have saved to the cloud")
            }
        } catch {
            let nserror = error as NSError
            
            let error = "The Residenc+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
    
}
