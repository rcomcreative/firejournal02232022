//
//  TodayShiftData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/27/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

struct TodayShiftData {
    var shiftDateTime: Date
    var resources = [UserFDResources]()
    var shiftIconName: String = "ICONS_startShift"
    var shiftStatusName: String!
    var shiftStartDate: String!
    var shiftStartTime: String!
    var shiftPlatoonName: String!
    var shiftFireStationNumber: String!
    var shiftAssignment: String!
    var shiftAssignedAppartus: String!
    var shiftSupervisor: String!
    
    init(theDate: Date) {
        self.shiftDateTime = theDate
    }
}
