//
//  DashboardSections.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/21/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

enum DashboardSections: Int, Hashable, CaseIterable, CustomStringConvertible {
    
case shift, forms, status, incidents, totalIncidents, weather
    
    var description: String {
        switch self {
        case .shift: return "Shift"
        case .forms: return "Forms"
        case .status: return "Status"
        case .incidents: return "Incidents"
        case .totalIncidents: return "Incident Totals"
        case .weather: return "Weather"
        }
    }
    
}
