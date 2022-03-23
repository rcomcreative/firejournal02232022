//
//  TodaysIncidentCount.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

struct TodaysIncidentCount: Equatable {
    var fireCount: String
    var emsCount: String
    var rescueCount: String
    var totalCount: String
    var totalYear: String
    var totalMonth: String
    
    init(fire: String, ems: String, rescue: String, count: String, year: String,month: String) {
        self.fireCount = fire
        self.emsCount = ems
        self.rescueCount = rescue
        self.totalCount = count
        self.totalYear = year
        self.totalMonth = month
    }
    
    
}
