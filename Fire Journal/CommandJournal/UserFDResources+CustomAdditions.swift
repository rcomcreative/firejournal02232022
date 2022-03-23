//
//  UserFDResources+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/26/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

/**
 This group of functions extended UserFDResources
 * newMyFDResourcesForCloud()->CKRecord {} Creates new CKRecord
 * updateMyFDResourcesFromCloud(ckRecord: CKRecord) {} Updates entity from Cloud either from other device of FJCloud
 • modifyMyFDResourcesForCloud(ckRecord: CKRecord)->CKRecord {} Modifies CKRecord that may have been changed sends to cloud
 */
extension UserFDResources {
    
    func newMyFDResourcesForCloud()->CKRecord {
        var recordName: String = ""
        if let name = self.fdResourceGuid {
            recordName = name
        } else {
            var iGuidDate: GuidFormatter
            if let date = self.fdResourceCreationDate {
                iGuidDate = GuidFormatter.init(date:date)
            } else {
                iGuidDate = GuidFormatter.init(date:Date())
            }
            let iGuid:String = iGuidDate.formatGuid()
            self.fdResourceGuid = "91."+iGuid
            recordName = "91."+iGuid
        }
    
        let fdResourceRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fdResourceRID = CKRecord.ID(recordName: recordName, zoneID: fdResourceRZ.zoneID)
        let fdResourceR = CKRecord.init(recordType: "UserFDResources", recordID: fdResourceRID)
//        let fdResourceRef = CKRecord.Reference(recordID: fdResourceRID, action: .deleteSelf)
        
        fdResourceR["theEntity"] = "UserFDResource"
        fdResourceR["customResource"] = self.customResource
        fdResourceR["fdResource"] = self.fdResource
        fdResourceR["fdResourceApparatus"] = self.fdResourceApparatus
        fdResourceR["fdResourceBackup"] = self.fdResourceBackup
        fdResourceR["fdResourceCreationDate"] = self.fdResourceCreationDate
        fdResourceR["fdResourceDescription"] = self.fdResourceDescription
        fdResourceR["fdResourceGuid"] = self.fdResourceGuid
        fdResourceR["fdResourceID"] = self.fdResourceID
        fdResourceR["fdResourceImageName"] = self.fdResourceImageName
        fdResourceR["fdResourceModDate"] = self.fdResourceModDate
        fdResourceR["fdResourcesDetails"] = self.fdResourcesDetails
        fdResourceR["fdResourcesPersonnelCount"] = self.fdResourcesPersonnelCount
        fdResourceR["fdManufacturer"] = self.fdManufacturer
        fdResourceR["fdShopNumber"] = self.fdShopNumber
        fdResourceR["fdYear"] = self.fdYear
        fdResourceR["fdResourcesSpecialties"] = self.fdResourcesSpecialties
        fdResourceR["fdResourceType"] = self.fdResourceType
//        if self.userReference != nil {
//            fdResourceR["userReference"] = self.userReference as! CKRecord.Reference
//            self.fdResourceReference = fdResourceRef
//        }
        saveToCD()
        
        return fdResourceR
    }
    
    func updateMyFDResourcesFromCloud(ckRecord: CKRecord) {
        let fdResourceR = ckRecord
        self.customResource = fdResourceR["customResource"] ?? false
        self.fdResource = fdResourceR["fdResource"]
        self.fdResourceApparatus = fdResourceR["fdResourceApparatus"]
        self.fdResourceBackup = fdResourceR["fdResourceBackup"] ?? false
        self.fdResourceCreationDate = fdResourceR["fdResourceCreationDate"]
        self.fdResourceDescription = fdResourceR["fdResourceDescription"]
        self.fdResourceGuid = fdResourceR["fdResourceGuid"]
        self.fdResourceID = fdResourceR["fdResourceID"]
        self.fdResourceImageName = fdResourceR["fdResourceImageName"]
        self.fdResourceModDate = fdResourceR["fdResourceModDate"]
        self.fdResourcesDetails = fdResourceR["fdResourcesDetails"] ?? false
        self.fdResourcesSpecialties = fdResourceR["fdResourcesSpecialties"]
        self.fdManufacturer = fdResourceR["fdManufacturer"]
        self.fdShopNumber = fdResourceR["fdShopNumber"]
        self.fdYear = fdResourceR["fdYear"]
        self.fdResourceType = fdResourceR["fdResourceType"] ?? 0001
//        self.userReference = fdResourceR["userReference"] as? NSObject
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fdResourceR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fdResourceCKR = data as NSObject
        saveToCD()
    }
    
    func modifyMyFDResourcesForCloud(ckRecord: CKRecord)->CKRecord {
        let fdResourceR = ckRecord
        fdResourceR["customResource"] = self.customResource
        fdResourceR["fdResource"] = self.fdResource
        fdResourceR["fdResourceApparatus"] = self.fdResourceApparatus
        fdResourceR["fdResourceBackup"] = self.fdResourceBackup
        fdResourceR["fdResourceCreationDate"] = self.fdResourceCreationDate
        fdResourceR["fdResourceDescription"] = self.fdResourceDescription
        fdResourceR["fdResourceGuid"] = self.fdResourceGuid
        fdResourceR["fdResourceID"] = self.fdResourceID
        fdResourceR["fdResourceImageName"] = self.fdResourceImageName
        fdResourceR["fdResourceModDate"] = self.fdResourceModDate
        fdResourceR["fdResourcesDetails"] = self.fdResourcesDetails
        fdResourceR["fdResourcesPersonnelCount"] = self.fdResourcesPersonnelCount
        fdResourceR["fdResourcesSpecialties"] = self.fdResourcesSpecialties
        fdResourceR["fdResourceType"] = self.fdResourceType
        fdResourceR["fdManufacturer"] = self.fdManufacturer
        fdResourceR["fdShopNumber"] = self.fdShopNumber
        fdResourceR["fdYear"] = self.fdYear
        return fdResourceR
    }
    
    fileprivate func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            print("UserFDResources+CustomAdditions.swift we have saved from the cloud")
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "UserFDResources+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
}
