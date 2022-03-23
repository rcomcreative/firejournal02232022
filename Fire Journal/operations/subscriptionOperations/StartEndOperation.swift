//
//  StartEndOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/15/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class StartEnd {
    var sTendShiftDiscussion: String = ""
    var sTendShiftSupervisor: String = ""
    var sTendShiftStatus: Bool = false
    var sTenShiftRelievedBy: String = ""
    var sTentryState: Int64 = EntryState.new.rawValue
    var sTfjUserTimeCKR: NSObject? = nil
    var sTstartShiftApparatus: String = ""
    var sTstartShiftAssignment: String = ""
    var sTstartShiftCrew: String = ""
    var sTstartShiftDiscussion: String = ""
    var sTstartShiftFireStation: String = ""
    var sTstartShiftPlatoon: String = ""
    var sTstartShiftRelieving: String = ""
    var sTstartShiftResources: String = ""
    var sTstartShiftSupervisor: String = ""
    var sTstartShiftStatus: Bool = true
    var sTupdateShiftDiscussion: String = ""
    var sTupdateShiftFireStation: String = ""
    var sTupdateShiftPlatoon: String = ""
    var sTupdateShiftRelievedBy: String = ""
    var sTupdateShiftSupervisor: String = ""
    var sTupdateShiftStatus: Bool = false
    var sTuserEndShiftTime: Date? = Date()
    var sTuserStartShiftTime: Date? = Date()
    var sTuserTimeBackup: Bool = false
    var sTuserTimeDayOfYear: String = ""
    var sTuserTimeGuid: String = ""
    var sTuserTimeYear: String = ""
    var sTuserUpdateShiftTime: Date?
    
    init(date: Date) {
        self.sTuserStartShiftTime = date
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.sTuserTimeGuid = "78."+guid
    }
}

class StartEndOperation: FJOperation {

}
