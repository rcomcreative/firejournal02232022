//
//  CrewFromContact.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

class CrewFromContact {
    var name: String
    var phone: String
    var email: String
    var image = UIImage(named: "ContactsIcon")
    var firstName: String = ""
    var mInitial: String = ""
    var lastName: String = ""
    var homeAgency: String = ""
    var attendeeGuid: String = ""
    var position: String = ""
    var attendeeDate = Date()
    var overtimeB: Bool = true
    var overtimeS: String = "AM Relief"
    var attendeesString: String = ""
    var attendees: Array<String>
    
    init(name: String, phone: String, email: String, crew: Array<String>) {
        self.name = name
        self.phone = phone
        self.email = email
        self.attendees = crew
    }
    
    func joinAttendees()->String {
        let group:String = attendees.joined(separator: ", ")
        return group
    }
    
    func createGuid() {
        self.attendeeDate = Date()
        let groupDate = GuidFormatter.init(date:attendeeDate)
        let grGuid:String = groupDate.formatGuid()
        self.attendeeGuid = "79."+grGuid
    }
    
    func overtimeSwitch(yesno: Bool) {
        self.overtimeB = yesno
        if yesno {
            self.overtimeS = "AM Relief"
        } else {
            self.overtimeS = "Overtime"
        }
    }
    
}

extension CrewFromContact : Equatable {}
func ==(lhs: CrewFromContact, rhs: CrewFromContact) -> Bool {
    return lhs.name == rhs.name && lhs.phone == rhs.phone && lhs.email == rhs.email && lhs.homeAgency == rhs.homeAgency && lhs.attendeeGuid == rhs.attendeeGuid && lhs.position == rhs.position && lhs.attendeesString == rhs.attendeesString
}
