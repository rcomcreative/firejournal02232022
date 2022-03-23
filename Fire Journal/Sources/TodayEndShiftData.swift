//
//  TodayEndShiftData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/27/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct TodayEndShiftData {
    var shiftDateTime: Date
    var shiftIconName: String = "ICONS_endShift"
    var shiftStatusName: String!
    var shiftEndDate: String!
    var shiftEndTime: String!
    var shiftIncidentCout: String!
    
    init(theDate: Date) {
        self.shiftDateTime = theDate
    }
}
