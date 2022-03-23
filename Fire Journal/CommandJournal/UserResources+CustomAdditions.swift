//
//  UserResources+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/22/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension UserResources {
    
    func newUserResourcesForCloud()->CKRecord {
        var recordName: String = ""
        if let name = self.resourceGuid {
            recordName = name
        } else {
            var iGuidDate: GuidFormatter
            if let date = self.resourceModificationDate {
                iGuidDate = GuidFormatter.init(date:date)
            } else {
                iGuidDate = GuidFormatter.init(date:Date())
            }
            let iGuid:String = iGuidDate.formatGuid()
            self.resourceGuid = "72."+iGuid
            recordName = "72."+iGuid
        }
        
        let userResourcesRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let userResourcesRID = CKRecord.ID(recordName: recordName, zoneID: userResourcesRZ.zoneID)
        let userResourcesR = CKRecord.init(recordType: "UserResources", recordID: userResourcesRID)
        
        userResourcesR["defaultResource"] = self.defaultResource
        userResourcesR["displayOrder"] = self.displayOrder
        userResourcesR["entryState"] = self.entryState
        userResourcesR["myFDResource"] = self.fdResource
        userResourcesR["resource"] = self.resource
        userResourcesR["resourceCustom"] = self.resourceCustom
        userResourcesR["resourceGuid"] = self.resourceGuid
        userResourcesR["resourceModificationDate"] = self.resourceModificationDate
        userResourcesR["theEntity"] = "UserResources"
        
        return userResourcesR
    }
}
