//
//  ShiftIncidentTotals.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/1/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation

struct ShiftIncidentTotals: Equatable, Comparable {
    
    var shiftDate: Date
    var shiftDated: String?
    var fire: Int
    var ems: Int
    var rescue: Int
    var incidents: Int
    let calendar = Calendar.init(identifier: .gregorian)
    let identifier = UUID()
    
    init(theShiftDate: Date, incidents: Int, theFire: Int, theEMS: Int, theRescue: Int ) {
        self.shiftDate = theShiftDate
        self.incidents = incidents
        self.fire = theFire
        self.ems = theEMS
        self.rescue = theRescue
        buildTheDateString(self.shiftDate)
    }
    
    mutating func buildTheDateString(_ theDate: Date) {
        let theComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: theDate)
        let m = theComponents.month!
        let y = theComponents.year!
        let d = theComponents.day!
        let h = theComponents.hour!
        let min = theComponents.minute!
        
        let month = m < 10 ? "0\(m)" : String(m)
        let day = d < 10 ? "0\(d)" : String(d)
        let year = String(y)
        let hour = h < 10 ? "0\(h)" : String(h)
        let minute = min < 10 ? "0\(min)" : String(min)
        
        self.shiftDated = month + "/" + day + "/" + year + " " + hour + ":" + minute + "HR"
    }
    
    static func < (lhs: ShiftIncidentTotals, rhs: ShiftIncidentTotals) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    
}
