//
//  EndShiftData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/29/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

struct EndShiftData {
    var esAMReliefDefault = "AM Relief"
    var esAMReliefDefaultT: Bool = true
    var esDateTime: Date = Date()
    var esRelieving: String = ""
    var esDiscussion: String = ""
    var esPlatoonB: Bool = true
    var esPlatoon: String = "Default"
    var esPlatoonTF: String = ""
    var esFireStationB: Bool = true
    var esFireStation: String = "Default"
    var esFireStationTF: String = ""
    var esupdateShift: Bool = false
    var esApparatusTF: String = ""
    var esApparatusB: Bool = true
    var esApparatus: String = "Default"
    var esAssignmentTF: String = ""
    var esAssignmentB: Bool = true
    var esAssignment: String = "Default"
    var esResourcesCombine: String = ""
    var esResourcesB: Bool = true
    var esResourcesTF: String = "Front Line"
    var esResources: String = ""
    var esResourcesName: String = ""
    var esCrewCombine: String = ""
    var esCrewB: Bool = true
    var esCrews: String = "AM Relief"
}

struct EndShift {
    var endTime: String?
    init(endTime:String) {
        self.endTime = endTime
    }
}
