//
//  UserFDResource.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/19/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData

class UserFDResource {
    
    var resourceType: Int64
    var resource: String
    var custom: Bool
    var objectID: NSManagedObjectID
    var resourceApparatus: String = ""
    var resourceDescription: String = ""
    var resourceID: String = ""
    var resourceStatusImageName: String = ""
    var resourcePersonnelCount: Int64 = 0
    var resourceManufacturer: String = ""
    var resourceShopNumber: String = ""
    var resourceSpecialities: String = ""
    var resourceYear: String = ""
    
    init(type: Int64, resource: String, objectID: NSManagedObjectID, custom: Bool = false) {
        self.resourceType = type
        self.resource = resource
        self.custom = custom
        self.objectID = objectID
    }
}
