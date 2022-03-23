//
//  JournalData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/25/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct JournalData {
    var journalTitle: String = ""
    var journalPrivatePublic: Bool = true
    var journalPrivatePublicText: String = "Public"
    var journalType: String = ""
    var journalTypeImageName: String = ""
    var journalDate: Date?
    var journalCreationDate: String = ""
    var journalOverview:  String = ""
    var journalUser:  String = ""
    var journalFireStation:  String = ""
    var journalPlatoon:  String = ""
    var journalAssignment:  String = ""
    var journalApparatus:  String = ""
    var journalDiscussion:  String = ""
    var journalNextSteps:  String = ""
    var journalSummary:  String = ""
    var journalCrew:  String = ""
    var journalCrewName: String = ""
    var journalCrewCombine: String = ""
    var journalCrewA = [String]()
    var journalLocation: CLLocation!
    var journalLatitude: String = ""
    var journalLongitude: String = ""
    var journalStreetNum: String = ""
    var journalStreetName:  String = ""
    var journalCity: String = ""
    var journalState: String = ""
    var journalZip:  String = ""
    var journalTags:  String = ""
    var journalTagsA = [String]()
    var journalGuid: String = ""
    var journalUserGuid: String = ""
    var journalPlatoonGuid: String = ""
    var journalAssignmentGuid: String = ""
    var journalApparatusGuid: String = ""
    var journalIncidentGuid: String = ""
}
