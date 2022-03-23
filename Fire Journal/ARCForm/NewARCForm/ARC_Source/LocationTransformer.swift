//
//  LocationTransformer.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/24/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import Foundation
import UIKit
import MapKit

@objc(LocationTransformer)
class LocationTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override class func allowsReverseTransformation() -> Bool{
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return CLLocation.classForCoder()
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        var trans: Any!
        do {
            let t = try NSKeyedArchiver.archivedData(withRootObject: value!, requiringSecureCoding: false)
            trans = t
        } catch {
            print("there was an error")
        }
        return trans
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        var trans: Any!
        do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: value as! Data)
            trans = unarchiver
        } catch {
            print("error")
        }
        return trans
    }

    
}

extension LocationTransformer {
    
    static let name = NSValueTransformerName(rawValue: String(describing: LocationTransformer.self ))
    
    public static func register() {
        let transformer = LocationTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name )
    }
    
}


