    //
    //  Staff.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/18/22.
    //

import Foundation
import UIKit

struct NewStaff:  Hashable {
    
    var firstName: String = ""
    var mInitial: String = ""
    var lastName: String = ""
    var fullName: String = ""
    var email: String = ""
    var mobile: String = ""
    var phone: String = ""
    var icsPosition: String = ""
    var icsHomeAgency: String = ""
    var rank: String = ""
    var platoon: String = ""
    var officerImage = UIImage(systemName: "person.circle")
    var isSupervisor: Bool = false
    var identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: NewStaff, rhs: NewStaff) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
