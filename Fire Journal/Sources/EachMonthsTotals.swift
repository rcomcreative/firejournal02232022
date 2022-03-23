//
//  EachMonthsTotals.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/20/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

struct EachMonthsTotal: Equatable {
    
    var year: Int
    var month: Int
    var fire: Int
    var ems: Int
    var rescue: Int
    
    init(theYear: Int, theMonth: Int, theFire: Int, theEMS: Int, theRescue: Int ) {
        self.year = theYear
        self.month = theMonth
        self.fire = theFire
        self.ems = theEMS
        self.rescue = theRescue
    }
    
}

