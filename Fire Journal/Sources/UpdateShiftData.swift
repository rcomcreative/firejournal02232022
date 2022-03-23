//
//  UpdateShiftData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/29/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

struct UpdateShiftData {
    var upsAMReliefDefault = "Move Up"
    var upsAMReliefDefaultT: Bool = true
    var upsDateTime: Date = Date()
    var upsRelieving: String = ""
    var upsDiscussion: String = ""
    var upsPlatoonB: Bool = true
    var upsPlatoon: String = "Default"
    var upsPlatoonTF: String = ""
    var upsFireStationB: Bool = true
    var upsFireStation: String = "Default"
    var upsFireStationTF: String = ""
    var upsupdateShift: Bool = false
    var upsApparatusTF: String = ""
    var upsApparatusB: Bool = true
    var upsApparatus: String = "Default"
    var upsAssignmentTF: String = ""
    var upsAssignmentB: Bool = true
    var upsAssignment: String = "Default"
    var upsResourcesCombine: String = ""
    var upsResourcesB: Bool = true
    var upsResourcesTF: String = "Front Line"
    var upsResources: String = ""
    var upsResourcesName: String = ""
    var upsCrewCombine: String = ""
    var upsCrewB: Bool = true
    var upsCrews: String = "AM Relief"
    var upsSupervisor: String = ""
}

struct UpdateShift {
    var updateTime:String?
    init?(updateTime:String) {
        self.updateTime = updateTime
    }
}
