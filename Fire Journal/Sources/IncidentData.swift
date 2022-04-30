//
//  IncidentData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/25/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//protocol IncidentDate {
//    var incidentDefaultDate: Date { get set }
//}
//
//extension IncidentDate {
//    var incidentDefaultDate: Date {
//        let date = Date()
//
//        return date
//    }
//}

struct IncidentData {
    var incidentNumber: String = ""
    var incidentDate: Date = Date()
    var incidentEmergencyYesNo: Bool = true
    var incidentEmergency: String = "Emergency"
    var incidentType: String = ""
    var incidentImageName:  String = "100515IconSet_092016_fireboard"
    var incidentLocalType:  String = ""
    var incidentNFIRSType:  String = ""
    var incidentLocation: CLLocation?
    var incidentLocationType:  String = ""
    var incidentStreetType:  String = ""
    var incidentStreetPrefix:  String = ""
    var incidentStreetNum:  String = ""
    var incidentStreetName:  String = ""
    var incidentLatitude: String = ""
    var incidentLongitude: String = ""
    var incidentCity:  String = ""
    var incidentState:  String = ""
    var incidentZip:  String = ""
    var incidentFullAddress: String = ""
    var incidentNotes: String = ""
    var incidentAlarmNotes: String = ""
    var incidentAlarmDate: Date? = nil
    var incidentFullAlarmDateS: String = ""
    var incidentAlarmMM: String = ""
    var incidentAlarmdd: String = ""
    var incidentAlarmYYYY: String = ""
    var incidentAlarmHH: String = ""
    var incidentAlarmmm: String = ""
    var incidentArrivalNotes: String = ""
    var incidentArrivalDate: Date? = nil
    var incidentFullArrivalDateS: String = ""
    var incidentArrivalMM: String = ""
    var incidentArrivaldd: String = ""
    var incidentArrivalYYYY: String = ""
    var incidentArrivalHH: String = ""
    var incidentArrivalmm: String = ""
    var incidentControlledNotes: String = ""
    var incidentControlledDate: Date? = nil
    var incidentFullControlledDateS: String = ""
    var incidentControlledMM: String = ""
    var incidentControlleddd: String = ""
    var incidentControlledYYYY: String = ""
    var incidentControlledHH: String = ""
    var incidentControlledmm: String = ""
    var incidentLastUnitNotes: String = ""
    var incidentLastUnitDate: Date? = nil
    var incidentFullLastUnitDateS: String = ""
    var incidentLastUnitMM: String = ""
    var incidentLastUnitdd: String = ""
    var incidentLastUnitYYYY: String = ""
    var incidentLastUnitHH: String = ""
    var incidentLastUnitmm: String = ""
    var incidentAction1No: String = ""
    var incidentAction1S: String = ""
    var incidentAction2No: String = ""
    var incidentAction2S: String = ""
    var incidentAction3No: String = ""
    var incidentAction3S: String = ""
    var incidentArson: Bool = false
    var incidentNfirsIncidentType:String = ""
    var incidentNfirsIncidentTypeNumber:String = ""
    var incidentCrew: String = ""
    var incidentCrewName: String = ""
    var incidentCrewCombine: String = ""
    var incidentCrewA = [String]()
    var incidentTags: String = ""
    var incidentTagsA = [String]()
    var incidentResources: String = ""
    var incidentResourcesName: String = ""
    var incidentResourcesCombined: String = ""
    var incidentResourcesA = [String]()
    var incidentUser: String = ""
    var incidentFireStation: String = ""
    var incidentPlatoon: String = ""
    var incidentAssignment: String = ""
    var incidentApparatus: String = ""
    var incidentFullDateS: String = ""
    var incidentNFIRSSec1FDID: String = ""
    var incidentNFIRSSec1State: String = ""
    var incidentNFIRSSec1Date: Date = Date()
    var incidentNFIRSSec1Station: String = ""
    var incidentNFIRSSec1IncidentNumber: String = ""
    var incidentNFIRSSec1Exposure: String = ""
    var incidentNFIRSSecDAidGivenB: Bool = false
    var incidentNFIRSSecDAidGivenS: String = ""
    var incidentNFIRSSecDTheirState: String = ""
    var incidentNFIRSSecDThierFDID: String = ""
    var incdientNFIRSSecDThierIncidentNumber: String = ""
    var incidentNFIRSSecEShiftOrPlatoon: String = ""
    var incidentNFIRSSecEAlarms: String = ""
    var incidentNFIRSSecEDistrict: String = ""
    var incidentNFIRSSecESpecialValue1: String = ""
    var incidentNFIRSSecESpecialValue2: String = ""
    var incidentNFIRSSecGSuppressionApparatus: String = ""
    var incidentNFIRSSecGSuppressionPersonnel: String = ""
    var incidentNFIRSSecGEMSApparatus: String = ""
    var incidentNFIRSSecGEMSPersonnel: String = ""
    var incidentNFIRSSecGOtherApparatus: String = ""
    var incidentNFIRSSecGOtherPersonnel: String = ""
    var incidentNFIRSSecHCasualties: Bool = false
    var incidentNFIRSSecHFSDeath: String = ""
    var incidentNFIRSSecHFSInjuries: String = ""
    var incidentNFIRSSecHCDeath: String = ""
    var incidentNFIRSSecHCInjuries: String = ""
    var incidentNFIRSSecHDAlerted: Bool = false
    var incidentNFIRSSecHDNotAlerted: Bool = false
    var incidentNFIRSSecHDUnknown: Bool = false
    var incidentNFIRSSecHHazardRelease: Bool = false
    var incidentNFIRSSecHHazardType: String = ""
    var incidentNFIRSSecIMixedUseProperty: Bool = false
    var incidentNFIRSSecIPropertyType: String = ""
    var incidentNFIRSSecJPropertyUse: Bool = false
    var incidentNFIRSSecJPUStructure: String = ""
    var incidentNFIRSSecJPUOutside: String = ""
    var incidentNFIRSSecJPULookup: Bool = false
    var incidentNFIRSSecJPULookupType: String = ""
    var incidentNFIRSSecKSameAddress: Bool = false
    var incidentNFIRSSecKBusinessName: String = ""
    var incidentNFIRSSecKPhoneNumber: String = ""
    var incidentNFIRSSecKNamePrefix: String = "Mr."
    var incidentNFIRSSecKFirstName: String = ""
    var incidentNFIRSSecKMiddle: String = ""
    var incidentNFIRSSecKLastName: String = ""
    var incidentNFIRSSecKNameSuffix: String = ""
    var incidentNFIRSSecKNumbMilePost: String = ""
    var incidentNFIRSSecKStreetPrefix: String = ""
    var incidentNFIRSSecKStreetPrefixB: Bool = true
    var incidentNFIRSSecKStreetName: String = ""
    var incidentNFIRSSecKStreetSuffix: String = ""
    var incidentNFIRSSecKStreetSuffixB: Bool = true
    var incidentNFIRSSecKPOBox: String = ""
    var incidentNFIRSSecKPOBoxB: Bool = true
    var incidentNFIRSSecKAptRoom: String = ""
    var incidentNFIRSSecKAptRoomB: Bool = true
    var incidentNFIRSSecKCity: String = ""
    var incidentNFIRSSecKState: String = ""
    var incidentNFIRSSecKZip: String = ""
    var incidentNFIRSSecKMorePeopleB: Bool = false
    var incidentNFIRSSecKSamePersonB: Bool = false
    var incidentNFIRSSecK2SameAddressB: Bool = false
    var incidentNFIRSSecK2BusinessName: String = ""
    var incidentNFIRSSecK2PhoneNumber: String = ""
    var incidentNFIRSSecK2NamePrefix: String = "Mr."
    var incidentNFIRSSecK2FirstName: String = ""
    var incidentNFIRSSecK2Middle: String = ""
    var incidentNFIRASecK2LastName: String = ""
    var incidentNFIRSSecK2NameSuffix: String = ""
    var incidentNFIRSSecK2NumbMilePost: String = ""
    var incidentNFIRSSecK2StreetPrefix: String = ""
    var incidentNFIRSSecK2StreetPrefixB: Bool = true
    var incidentNFIRSSecK2StreetName: String = ""
    var incidentNFIRSSecK2StreetSuffix: String = ""
    var incidentNFIRSSecK2StreetSuffixB: Bool = true
    var incidentNFIRSSecK2POBox: String = ""
    var incidentNFIRSSecK2POBoxB: Bool = true
    var incidentNFIRSSecK2AptRoom: String = ""
    var incidentNFIRSSecK2AptRoomB: Bool = true
    var incidentNFIRSSecK2City: String = ""
    var incidentNFIRSSecK2State: String = ""
    var incidentNFIRSSecK2Zip: String = ""
    var incidentNFIRSSecLRemarks: String = ""
    var incidentNFIRSSecLRemarksMoreB: Bool = false
    var incidentNFIRSSecLRemarksMore: String = ""
    var incidentNFIRSSecMOfficerInChargeID: String = ""
    var incidentNFIRSSecMOfficiersSignature: Data?
    var incidentNFIRSSecMOfficiersSignatureB: Bool = false
    var incidentNFIRSSecMOfficiersSignatureI: UIImage?
    var incidentNFIRSSecMOfficiersSignatureDate: Date = Date()
    var incidentNFIRSSecMOfficiersSignatureDateS: String = ""
    var incidentNFIRSSecMOfficersSignatureDateMM: String = ""
    var incidentNFIRSSecMOfficersSignatureDateDD: String = ""
    var incidentNFIRSSecMOfficersSignatureDateYYYY: String = ""
    var incidentNFIRSSecMOfficersRank: String = ""
    var incidentNFIRSSecMOfficersAssignment: String = ""
    var incidentNFIRSSecMMembersMakingReportID: String = ""
    var incidentNFIRSSecMMembersSignature:Data?
    var incidentNFIRSSecMMembersSignatureB: Bool = false
    var incidentNFIRSSecMMembersSignatureI: UIImage?
    var incidentNFIRSSecMMembersSignatureDate: Date = Date()
    var incidentNFIRSSecMMembersSignatureDateS: String = ""
    var incidentNFIRSSecMMembersSignatureDateMM: String = ""
    var incidentNFIRSSecMMembersSignatureDateDD: String = ""
    var incidentNFIRSSecMMembersSignatureDateYYYY: String = ""
    var incidentNFIRSSecMMembersRank: String = ""
    var incidentNFIRSSecMMembersAssignment: String = ""
    var incidentNFIRSSecMOfficerMakingReportB: Bool = false
    var incidentNFIRSSecCMFire2B: Bool = false
    var incidentNFIRSSecCMFire2S: String = "Fire-2"
    var incidentNFIRSSecCMStructFire3B: Bool = false
    var incidentNFIRSSecCMStructFire3S: String = "Structure Fire-3"
    var incidentNFIRSSecCMCivilian4B: Bool = false
    var incidentNFIRSSecCMCivilian4S: String = "Civilian Fire Cas-4"
    var incidentNFIRSSecCMFSCasualty5B: Bool = false
    var incidentNFIRSSecCMFSCasualty5S: String = "Fire Service Cas-5"
    var incidentNFIRSSecCMEMS6B: Bool = false
    var incidentNFIRSSecCMEMS6S: String = "EMS-6"
    var incidentNFIRSSecCMHazMat7B: Bool = false
    var incidentNFIRSSecCMHazMat7S: String = "Haz Mat-7"
    var incidentNFIRSSecCMWild8B: Bool = false
    var incidentNFIRSSecCMWild8S: String = "Wildland Fires-8"
    var incidentNFIRSSecCMApp9B: Bool = false
    var incidentNFIRSSecCMApp9S: String = "Apparatus-9"
    var incidentNFIRSSecCMPersonnel10B: Bool = false
    var incidentNFIRSSecCMPersonnel10S: String = "Personnel-10"
    var incidentNFIRSSecCMArson11B: Bool = false
    var incidentNFIRSSecCMArson11S: String = "Arson-11"
    var incidentNFIRSSecRMBuilding111B: Bool = false
    var incidentNFIRSSecRMBuilding111S: String = "Buildings 111"
    var incidentNFIRSSecRMSpecial112B: Bool = false
    var incidentNFIRSSecRMSpecial112S: String = "Special Structure 112"
    var incidentNFIRSSecRMConfined113B: Bool = false
    var incidentNFIRSSecRMConfined113S: String = "Confined 113-118"
    var incidentNFIRSSecRMMobile120B: Bool = false
    var incidentNFIRSSecRMMobile120S: String = "Mobile Property 120-124"
    var incidentNFIRSSecRMVehicle130B: Bool = false
    var incidentNFIRSSecRMVehicle130S: String = "Vehicle 130-138"
    var incidentNFIRSSecRMVegitation140B: Bool = false
    var incidentNFIRSSecRMVegitation140S: String = "Vegitation 140-143"
    var incidentNFIRSSecRMOutside150B: Bool = false
    var incidentNFIRSSecRMOutside150S: String = "Outside Rubbish Fire 150-155"
    var incidentNFIRSSecRMSOutside160B: Bool = false
    var incidentNFIRSSecRMSOutside160S: String = "Special Outside Fire 160"
    var incidentNFIRSSecRMSOutside161B: Bool = false
    var incidentNFIRSSecRMSOutside161S: String = "Special Outside Fire 161-163"
    var incidentNFIRSSecRMCropFire170B: Bool = false
    var incidentNFIRSSecRMCropFire170S: String = "Crop Fire 170-173"
    //    MARK: -POV entries in PersonalJournal related Incident
    var incidentPersonalJournalReference: String = ""
    var incidentGuid: String = ""
    var incidentUserResourcesA = [IncidentUserResource]()
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/YYYY HH:mm"
        return df
    }()
    
    mutating func incidentDateTime(type: IncidentTypes, date: Date)->String {
        let dateS: String = IncidentData.dateFormatter.string(from: date)
        let month = MonthFormat.init(date: date)
        let day = DayFormat.init(date: date)
        let year = YearFormat.init(date: date)
        let hour = HourFormat.init(date: date)
        let minutes = MinuteFormat.init(date: date)
        switch type {
        case .nfirsSecMOfficersDate:
            self.incidentNFIRSSecMOfficiersSignatureDate = date
            self.incidentNFIRSSecMOfficiersSignatureDateS = dateS
            self.incidentNFIRSSecMOfficersSignatureDateMM = month.monthForDate()
            self.incidentNFIRSSecMOfficersSignatureDateDD = day.dayForDate()
            self.incidentNFIRSSecMOfficersSignatureDateYYYY = year.yearForDate()
        case .nfirsSecMMembersDate:
            self.incidentNFIRSSecMMembersSignatureDate = date
            self.incidentNFIRSSecMMembersSignatureDateS = dateS
            self.incidentNFIRSSecMMembersSignatureDateMM = month.monthForDate()
            self.incidentNFIRSSecMMembersSignatureDateDD = day.dayForDate()
            self.incidentNFIRSSecMMembersSignatureDateYYYY = year.yearForDate()
        case .alarm:
            self.incidentAlarmDate = date
            self.incidentFullAlarmDateS = dateS
            self.incidentAlarmMM = month.monthForDate()
            self.incidentAlarmdd = day.dayForDate()
            self.incidentAlarmYYYY = year.yearForDate()
            self.incidentAlarmHH = hour.hourForDate()
            self.incidentAlarmmm = minutes.minuteForDate()
        case .arrival:
            self.incidentArrivalDate = date
            self.incidentFullArrivalDateS = dateS
            self.incidentArrivalMM = month.monthForDate()
            self.incidentArrivaldd = day.dayForDate()
            self.incidentArrivalYYYY = year.yearForDate()
            self.incidentArrivalHH = hour.hourForDate()
            self.incidentArrivalmm = minutes.minuteForDate()
        case .controlled:
            self.incidentControlledDate = date
            self.incidentFullControlledDateS = dateS
            self.incidentControlledMM = month.monthForDate()
            self.incidentControlleddd = day.dayForDate()
            self.incidentControlledYYYY = year.yearForDate()
            self.incidentControlledHH = hour.hourForDate()
            self.incidentControlledmm = minutes.minuteForDate()
        case .lastunitstanding:
            self.incidentLastUnitDate = date
            self.incidentFullLastUnitDateS = dateS
            self.incidentLastUnitMM = month.monthForDate()
            self.incidentLastUnitdd = day.dayForDate()
            self.incidentLastUnitYYYY = year.yearForDate()
            self.incidentLastUnitHH = hour.hourForDate()
            self.incidentLastUnitmm = minutes.minuteForDate()
        default:
            break
        }
        return dateS
    }
    
    mutating func nfirsTimesTheSame(type:IncidentTypes) {
        switch type {
        case .nfirsArrival:
            self.incidentArrivalDate = self.incidentAlarmDate
            self.incidentArrivalMM = self.incidentAlarmMM
            self.incidentArrivaldd = self.incidentAlarmdd
            self.incidentArrivalYYYY = self.incidentAlarmYYYY
            self.incidentArrivalHH = self.incidentAlarmHH
            self.incidentArrivalmm = self.incidentAlarmmm
            self.incidentFullArrivalDateS = self.incidentFullAlarmDateS
        case .nfirsControlled:
            self.incidentControlledDate = self.incidentAlarmDate
            self.incidentControlledMM = self.incidentAlarmMM
            self.incidentControlleddd = self.incidentAlarmdd
            self.incidentControlledYYYY = self.incidentAlarmYYYY
            self.incidentControlledHH = self.incidentAlarmHH
            self.incidentControlledmm = self.incidentAlarmmm
            self.incidentFullControlledDateS = self.incidentFullAlarmDateS
        case .nfirsLastUnit:
            self.incidentLastUnitDate = self.incidentAlarmDate
            self.incidentLastUnitMM = self.incidentAlarmMM
            self.incidentLastUnitdd = self.incidentAlarmdd
            self.incidentLastUnitYYYY = self.incidentAlarmYYYY
            self.incidentLastUnitHH = self.incidentAlarmHH
            self.incidentLastUnitmm = self.incidentAlarmmm
            self.incidentFullLastUnitDateS = self.incidentFullAlarmDateS
        default:
            break
        }
    }
}


public enum IncidentTypes: Int {
    case fire
    case ems
    case rescue
    case alarm
    case arrival
    case controlled
    case lastunitstanding
    case firstAction
    case secondAction
    case thirdAction
    case emergency
    case arson
    case crew
    case tags
    case nfirsIncidentType
    case localIncidentType
    case locationType
    case streetType
    case streetPrefix
    case resources
    case platoon
    case rank
    case assignment
    case fdid
    case apparatus
    case incidentNote
    case alarmNote
    case arrivalNote
    case controlledNote
    case lastUnitStandingNote
    case ics214Form
    case arcForm
    case allIncidents
    case userLocation
    case state
    case nfirsAlarm
    case nfirsArrival
    case nfirsControlled
    case nfirsLastUnit
    case nfirsSecHCasualties
    case nfirsSecHDAlarm
    case nfirsSecHDAlerted
    case nfirsSecHDNotAlerted
    case nfirsSecHDUnknown
    case nfirsSecHHRelease
    case nfirsSecHHType
    case nfirsSecIMixedUse
    case nfirsSecIMixedType
    case nfirsSecJPropertyUse
    case nfirsSecJPUStructure
    case nfirsSecJPUOutside
    case nfirsSecJPULookUp
    case nfirsSecJPULookUpType
    case nfirsSecKMorePeople
    case nfirsSecKSamePerson
    case nfirsSecKSameAddress
    case nfirsSecKBusinessName
    case nfirsSecKBusinessName2
    case nfirsSecKPhoneNumber
    case nfirsSecKPhoneNumber2
    case nfirsSecKNamePrefix
    case nfirsSecKNamePrefix2
    case nfirsSecKNameSuffix
    case nfirsSecKNameSuffix2
    case nfirsSecKStreetSuffix
    case nfirsSecK2StreetSuffix
    case nfirsSecKStreetPrefix
    case nfirsSecKStreetPrefix2
    case nfirsSecKPOBox
    case nfirsSecK2POBox
    case nfirsSecKAptSuite
    case nfirsSecK2AptSuite
    case nfirsSecLRemarks
    case nfirsSecLRemarksB
    case nfirsSecMOfficerSignature
    case nfirsSecMOfficersDate
    case nfirsSecMMembersSignature
    case nfirsSecMMembersDate
    case officersRank
    case officersAssignment
    case membersRank
    case membersAssignment
    case nfirsSecCMFire2
    case nfirsSecCMStructFire3
    case nfirsSecCMCivilian4
    case nfirsSecCMFSCasualty5
    case nfirsSecCMEMS6
    case nfirsSecCMHazMat7
    case nfirsSecCMWild8
    case nfirsSecCMApp9
    case nfirsSecCMPersonnel10
    case nfirsSecCMArson11
    case nfirsSecRMBuilding111
    case nfirsSecRMSpecial112
    case nfirsSecRMConfined113
    case nfirsSecRMMobile120
    case nfirsSecRMVehicle130
    case nfirsSecRMVegitation140
    case nfirsSecRMOutside150
    case nfirsSecRMSOutside160
    case nfirsSecRMSOutside161
    case nfirsSecRMCropFire170
    case journal
    case personal
    case myFireStation
    case station
    case community
    case members
    case deptMember
    case training
    case languages
    case icsPosition
    case qualfications
    case education
    case specialities
    case extrasklls
    case injuries
    case manditoryTraining
    case otherCerts
    case children
    case staffNote
    case stationType
    case fireFighter
    case strikeTeam
    case wildlandRed
    case vaccinated
    case medicalNotes
    case officerNotes
    case platoonPriorities
    case stationPriorities
    case shiftNotes
    case startShiftNotes
    case endShiftNotes
    case supervisor
    case apparatusManufacturer
    case apparatusAssignedPositions
    case apparatusNotes
    case apparatusMilage
    case apparatusMaintenance
    case leaveWork
    case incidentPhoto
    case overview
    case discussion
    case nextSteps
    case summary
    case theRanks
    case theProject
    case theProjectOverview
    case theProjectClassNote
    case theProjectCrew
}

public enum NFIRSModule:Int {
    case modA
    case modB
    case modC
    case modD
    case modE1
    case modE2
    case modF
    case modG1
    case modG2
    case modH1
    case modH2
    case modH3
    case modI
    case modJ
    case modK1
    case modK2
    case modL
    case modM
    case modRequired
    case modCompleted
    case incident
}

protocol NFIRSSection {
    var type: NFIRSModule { get }
    var section: Int { get }
    var sectionTitle: String { get }
    var sectionDescription: String { get }
    var rowCount: Int { get }
    var isCollapsible: Bool { get }
    var isCollapsed: Bool { get set }
}

extension NFIRSSection {
    var rowCount: Int {
        return 0
    }
    var isCollapsible: Bool {
        return true
    }
}

class IncidentSec0: NFIRSSection {
    var type: NFIRSModule = .incident
    
    var section: Int = 0
    
    var rowCount: Int = 30
    
    var isCollapsed: Bool = false
    
    var isCollapsible: Bool = false
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModA: NFIRSSection {
    
    var type: NFIRSModule {
        return .modA
    }
    
    var section: Int {
        return 1
    }
    
    var rowCount: Int {
        return 7
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModB: NFIRSSection {
    
    var type: NFIRSModule {
        return .modB
    }
    
    var section: Int {
        return 2
    }
    
    var rowCount: Int {
        return 12
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModC: NFIRSSection {
    
    
    var type: NFIRSModule {
        return .modC
    }
    
    var section: Int {
        return 3
    }
    
    var rowCount: Int {
        return 1
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModD: NFIRSSection {
    
    var type: NFIRSModule {
        return .modD
    }
    
    var section: Int {
        return 4
    }
    
    var rowCount: Int {
        return 4
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModE: NFIRSSection {
    var type: NFIRSModule {
        return .modE1
    }
    
    var section: Int {
        return 5
    }
    
    var rowCount: Int {
        return 17
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModF: NFIRSSection {
    var type: NFIRSModule {
        return .modF
    }
    
    var section: Int {
        return 6
    }
    
    var rowCount: Int {
        return 3
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModG: NFIRSSection {
    var type: NFIRSModule {
        return .modG1
    }
    
    var section: Int {
        return 7
    }
    
    var rowCount: Int {
        return 20
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModH: NFIRSSection {
    var type: NFIRSModule {
        return .modH1
    }
    
    var section: Int {
        return 8
    }
    
    var rowCount: Int {
        return 14
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModI: NFIRSSection {
    var type: NFIRSModule {
        return .modI
    }
    
    var section: Int {
        return 9
    }
    
    var rowCount: Int {
        return 3
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModJ: NFIRSSection {
    var type: NFIRSModule {
        return .modJ
    }
    
    var section: Int {
        return 10
    }
    
    var rowCount: Int {
        return 5
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModK: NFIRSSection {
    var type: NFIRSModule {
        return .modK1
    }
    
    var section: Int {
        return 11
    }
    
    var rowCount: Int {
        return 38
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModL: NFIRSSection {
    var type: NFIRSModule {
        return .modL
    }
    
    var section: Int {
        return 12
    }
    
    var rowCount: Int {
        return 2
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModM: NFIRSSection {
    var type: NFIRSModule {
        return .modM
    }
    
    var section: Int {
        return 13
    }
    
    var rowCount: Int {
        return 13
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModRequired: NFIRSSection {
    var type: NFIRSModule {
        return .modRequired
    }
    
    var section: Int {
        return 15
    }
    
    var rowCount: Int {
        return 10
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSModCompleted: NFIRSSection {
    var type: NFIRSModule {
        return .modCompleted
    }
    
    var section: Int {
        return 14
    }
    
    var rowCount: Int {
        return 10
    }
    
    var isCollapsed: Bool = true
    
    var isCollapsible: Bool = true
    
    var sectionTitle: String
    var sectionDescription: String
    
    init(title: String, modDescription: String) {
        self.sectionTitle = title
        self.sectionDescription = modDescription
    }
}

class NFIRSBasicOne: NSObject {
    
    var sections = [NFIRSSection]()
    
    var reloadSections: ((_ section: Int)-> Void)?
    
    override init() {
        super.init()
        let incidentInfo = IncidentSec0(title: "", modDescription: "")
        sections.append(incidentInfo)
        let section1 = NFIRSModA(title: "NFIRS-1 Basic SECTION A", modDescription: "The Basic Module (NFIRS–1) captures general information on every incident (or emergency call) to which the department responds.")
        sections.append(section1)
        let section2 = NFIRSModB(title: "NFIRS-1 Basic SECTION B", modDescription: "The exact location of the incident is used for spatial analyses and response planning that can be linked to demographic data. Incident address information is required at the local government level to establish an official document of record.")
        sections.append(section2)
        let section3 = NFIRSModC(title: "NFIRS-1 Basic SECTION C", modDescription: "This is the actual situation that emergency personnel found on the scene when they arrived.These codes include the entire spectrum of fire department activities from fires to EMS to public service.")
        sections.append(section3)
        let section4 = NFIRSModD(title: "NFIRS-1 Basic SECTION D", modDescription: "The Aid Given or Received entry serves as data control to ensure that the same incident is not counted more than once while still giving credit for activity performed by outside departments.")
        sections.append(section4)
        let section5 = NFIRSModE(title: "NFIRS-1 Basic SECTION E1,E2,E3", modDescription: "All dates and times are entered as numerals. For time of day, the 24-hour clock is used. The actual month, day, year, and time of day (hour, minute, and (optional in on-line entry) seconds) when the alarm was received by the fire department.This is not an elapsed time.")
        sections.append(section5)
        let section6 = NFIRSModF(title: "NFIRS-1 Basic SECTION F", modDescription: "These data elements, together with Incident Type, enable a fire department to document the breadth of activities and the resources required by the responding fire department to effectively handle the incident.")
        sections.append(section6)
        let section7 = NFIRSModG(title: "NFIRS-1 Basic SECTION G1, G2", modDescription: "The total complement of fire department personnel and apparatus (suppression, EMS, other) that respond- ed to the incident.This includes all fire and EMS personnel assigned to the incident whether they arrived at the scene or were canceled before arrival.")
        sections.append(section7)
        let section8 = NFIRSModH(title: "NFIRS-1 Basic SECTION H1,H2,H3", modDescription: "Section H captures information on the number of civilians and firefighters injured or killed as a result of the incident. Other information in this section relates to whether a detector alerted occupants in a structure and whether hazardous materials were released.")
        sections.append(section8)
        let section9 = NFIRSModI(title: "NFIRS-1 Basic SECTION I", modDescription: "This data element captures the overall use of a property. If a property has two or more uses, then the Mixed Use Property designation applies.")
        sections.append(section9)
        let section10 = NFIRSModJ(title: "NFIRS-1 Basic SECTION J", modDescription: "This entry refers to the actual use of the property where the incident occurred, not the overall use of mixed use properties of which the property is part (see Mixed Use Property, Section I).")
        sections.append(section10)
        let section11 = NFIRSModK(title: "NFIRS-1 Basic SECTION K1,K2", modDescription: "The full name of the company or agency occupying, managing, or leasing the property where the incident occurred. The full name of the company or agency that owns the property where the incident occurred.")
        sections.append(section11)
        let section12 = NFIRSModL(title: "NFIRS-1 Basic SECTION L", modDescription: "The Remarks section is an area for any comments that might be made concerning the incident. It is also a place to describe what happened, fire department operations, or unusual conditions encountered.")
        sections.append(section12)
        let section13 = NFIRSModM(title: "NFIRS-1 Basic SECTION M", modDescription: "Section M requires the identifcation and signatures of the person completing the incident report and his/ her supervisor. A completed example of the  fields used is presented at the end of this section.")
        sections.append(section13)
        let section14 = NFIRSModCompleted(title: "NFIRS-1 Basic Completed Modules", modDescription: "This area of the Basic Module is used to determine the totality of all the modules submitted for a specific incident. It acts as a checklist for completed modules under the paper form system.")
        sections.append(section14)
        let section15 = NFIRSModRequired(title: "NFIRS-1 Basic Modules Required", modDescription: "The block indicates whether a Fire Module or Structure Fire Module is required according to the Incident Type recorded in Section C of this module.")
        sections.append(section15)
    }
}

