//
//  TodayIncident.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

struct TodayIncident: Equatable {
    var incidentImage: UIImage!
    var situationIncidentImage: String!
    var objectID: NSManagedObjectID!
    var incidentNumber: String
    var streetAddress: String!
    var incidentCity: String!
    var incidentState: String!
    var incidentZip: String!
    var incidentAnnotationAddress: String!
    var alarmTime: String!
    var arrivalTime: String!
    var controlledTime: String!
    var lastUnitTime: String!
    var incidentResources: String!
    var incidentLocation: CLLocation!
    var theIncidentDate: String!
    
    var cityStateZip: String = ""
    
    init(number: String) {
        if number == "" {
            self.incidentNumber = "No Incident Number assigned yet"
        } else {
            self.incidentNumber = "Incident #\(number)"
        }
    }
}
