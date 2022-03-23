//
//  UserEntryInfo.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/29/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

class UserEntryInfo {
    var user: String!
    var entryType: MenuItems = .journal
    var entryTypeS: String = "Station"
    var fireStation: String = ""
    var platoon: String = ""
    var platoonGuid: String = ""
    var platoonDefault: Bool = true
    var apparatus: String = ""
    var apparatusGuid: String = ""
    var apparatusDefault: Bool = true
    var assignment: String = ""
    var assignmentGuid: String = ""
    var assignmentDefault: Bool = true
    
    init(user: String) {
        self.user = user
    }
    
}
