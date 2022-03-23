//
//  NewIncidentMapAnnotation.swift
//  ARCForm
//
//  Created by DuRand Jones on 11/3/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData

enum kAnnotationType {
    case annotationFire
    case annotationEMS
    case annotationRescue
    case annotationICS214
    case annotationCRRForm
    case annotationFireStation
}


class NewIncidentMapAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
    var objectID:NSManagedObjectID!
    var annotationImage:UIImage!
    var incidentType: IncidentTypes!
    var type:kAnnotationType = .annotationFire
    
    func imageForMapPin(type: kAnnotationType)->UIImage {
        var pinImage = UIImage(named: "fireWhitePin")
        switch type {
        case .annotationFire:
            pinImage = UIImage(named: "fireWhitePin")
        case .annotationEMS:
            pinImage = UIImage(named: "emsWhitePin")
        case .annotationRescue:
            pinImage = UIImage(named: "rescueWhitePin")
        case .annotationICS214:
            pinImage = UIImage(named: "ics214Pin")
        case .annotationCRRForm:
            pinImage = UIImage(named: "CRRAlarmPin")
        case .annotationFireStation:
            pinImage = UIImage(named: "FireStationPin")
        }
        let size = CGSize(width: 60, height: 60)
        UIGraphicsBeginImageContext(size)
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        pinImage!.draw(in: frame)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let image = UIImage(named: "avalancheA")
        return resizedImage ?? image!
    }
}
