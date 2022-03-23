//
//  UpdateShiftDashbaordData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/27/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct UpdateShiftDashbaordData {
    var shiftDateTime: Date
    var resources = [UserFDResources]()
    var shiftIconName: String = "ICONS_updateShift"
    var shiftStatusName: String!
    var shiftUpdateDate: String!
    var shiftUpdateTime: String!
    var shiftPlatoonName: String!
    var shiftFireStationNumber: String!
    
    init(theDate: Date) {
        self.shiftDateTime = theDate
    }
    
}
