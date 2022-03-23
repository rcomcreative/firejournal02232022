//
//  Stack.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//import Foundation
import UIKit
import CloudKit
import CoreData
import CoreLocation

// MARK: Serialization of CLLocation
@objc(SecureCLLocationTransformer)
class SecureCLLocationTransformer: NSSecureUnarchiveFromDataTransformer {
    public static let transformerName = NSValueTransformerName(rawValue: "SecureCLLocationTransformer")
    override class var allowedTopLevelClasses: [AnyClass] {
        return [CLLocation.self]
    }
}
