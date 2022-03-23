//
//  StartShiftData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/25/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

struct StartShiftData {
    var ssAMReliefDefault: Bool = true
    var ssAMReliefDefaultT: String = "AM Relief"
    var ssDateTime: Date = Date()
    var ssRelieving: String = ""
    var ssDiscussion: String = ""
    var ssPlatoonB: Bool = true
    var ssPlatoon: String = "Default"
    var ssPlatoonTF: String = ""
    var ssFireStationB: Bool = true
    var ssFireStation: String = "Default"
    var ssFireStationTF: String = ""
    var ssAssignmentB: Bool = true
    var ssAssignment: String = "Default"
    var ssAssignmentTF: String = ""
    var ssApparatusB: Bool = true
    var ssApparatus: String = "Default"
    var ssApparatusTF: String = ""
    var ssResourcesB: Bool = true
    var ssResources: String = "Front Line"
    var ssResourcesTF: String = ""
    var ssResourcesName: String = ""
    var ssResourcesCombine: String = ""
    var ssResourcesGuid: String = ""
    var ssCrewB: Bool = true
    var ssCrews: String = "AM Relief"
    var ssCrewsTF: String = ""
    var ssCrewsName: String = ""
    var ssCrewCombine: String = ""
    var ssCrewGuid: String = ""
    var ssSupervisor: String = ""
}
extension StartShiftData : Equatable {}
func ==(lhs: StartShiftData, rhs: StartShiftData) -> Bool {
    return lhs.ssAMReliefDefault == rhs.ssAMReliefDefault && lhs.ssDateTime == rhs.ssDateTime && lhs.ssRelieving == rhs.ssRelieving && lhs.ssDiscussion == rhs.ssDiscussion && lhs.ssPlatoonB == rhs.ssPlatoonB  && lhs.ssPlatoon == rhs.ssPlatoon  && lhs.ssPlatoonTF == rhs.ssPlatoonTF  && lhs.ssFireStationB == rhs.ssFireStationB  && lhs.ssFireStation == rhs.ssFireStation  && lhs.ssFireStationTF == rhs.ssFireStationTF  && lhs.ssAssignmentB == rhs.ssAssignmentB  && lhs.ssAssignment == rhs.ssAssignment  && lhs.ssAssignmentTF == rhs.ssAssignmentTF  && lhs.ssApparatusB == rhs.ssApparatusB  && lhs.ssApparatus == rhs.ssApparatus  && lhs.ssApparatusTF == rhs.ssApparatusTF  && lhs.ssResourcesB == rhs.ssResourcesB  && lhs.ssResources == rhs.ssResources  && lhs.ssResourcesTF == rhs.ssResourcesTF  && lhs.ssCrewB == rhs.ssCrewB  && lhs.ssCrews == rhs.ssCrews  && lhs.ssCrewsTF == rhs.ssCrewsTF && lhs.ssSupervisor == rhs.ssSupervisor
}

struct StartShift {
    var startTime:String?
    init?(startTime:String) {
        self.startTime = startTime
    }
}

