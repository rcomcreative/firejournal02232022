//
//  Form.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/18/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Form {
    var campaign: Bool = false;
    var campaignTitle: String = ""
    var campaignStart: Date = Date()
    var campaignComplete: Bool = false;
    var campaignEnd: Date = Date()
    var master: Bool = false;
    var locationAvailable: Bool = false;
    var location: CLLocation?
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var aptMobileNum: String = ""
    var numNewSA: String = ""
    var numBellShaker: String = ""
    var numBatteriesReplaced: String = ""
    var createFEP: Bool = false;
    var reviewChecklist: Bool = false;
    var localHazard: Bool = false;
    var descHazard: String = ""
    var residentName: String = ""
    var residentSigned: Bool = false;
    var residentSigDate: Date = Date()
    var residentSig: Data?
    var contactInfo: Bool = false;
    var residentCellNum: String = ""
    var residentEmail: String = ""
    var residentOtherPhone: String = ""
    var installerName: String = ""
    var installerSigned: Bool = false;
    var installerSig: Data?
    var installerDate: Date = Date()
    var iaNumPeople: String = ""
    var ia17Under: String = ""
    var ia65Over: String = ""
    var iaDisability: String = ""
    var iaVets: String = ""
    var iaPrexistingSA: String = ""
    var iaWorkingSA: String = ""
    var iaNotes: String = ""
    var nationalPartner: String = ""
    var localPartner: String = ""
    var option1: String = ""
    var option2: String = ""
    var adminName: String = ""
    var adminDate: Date = Date()
}
