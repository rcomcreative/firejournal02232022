//
//  ICS214Data.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/24/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit
import CoreLocation

let notificationKeyICS = "FJkNO_FORMS_AVAILABLE"
let notificationKeyICS2 = "FJkNEWICS214FormCreated"
let notificationKeyICS3 = "FJkNewICSFORMNEEDED"
let notificationKeyICS4 = "FJkReleaseThatModal"
let notificationKeyICS5 = "FJkCompleteChanged"
let notificationKeyICS6 = "FJkCOREDATA_ICS214LASTOBJECT"
let notificationKeyICS7 = "FJkDASHBOARD_CALLEDFROMICS214"
let FJkFORMCHOSEN_FROMDASHBOARD = "FJkFORMCHOSEN_FROMDASHBOARD"
let notificationKeyICS9 = "FJkCOREDATA_INCIDENTSMAPSCALLED"
let notificationKeyMODIFIED = "FJkMODIFIEDICS214FORM_TOCLOUDKIT"
let notificationKeyLISTSYNC = "FJkSYNCTOCLOUD_FROMLIST"

struct ICS214Activities {
    var activity = [ String:String ]()
    var activityDateString = [ String:String ]()
    var activityDate = [ String:Date ]()
    var activityGuid = [ String:String]()
}
extension ICS214Activities : Equatable {}
func ==(lhs: ICS214Activities, rhs: ICS214Activities) -> Bool {
    return lhs.activity == rhs.activity && lhs.activityDateString == rhs.activityDateString && lhs.activityDate == rhs.activityDate && lhs.activityGuid == rhs.activityGuid
}
struct ActivityLog {
    var activity:String?
    var activityStringDate:String?
    var dateActivity:Date?
    var guid:String?
    init?(activity:String,activityStringDate:String,dateActivity:Date,guid:String) {
        self.activity = activity
        self.activityStringDate = activityStringDate
        self.dateActivity = dateActivity
        self.guid = guid
    }
}
extension ActivityLog : Equatable {}
func ==(lhs: ActivityLog, rhs: ActivityLog) -> Bool {
    return lhs.activity == rhs.activity && lhs.activityStringDate == rhs.activityStringDate && lhs.dateActivity == rhs.dateActivity && lhs.guid == rhs.guid
}

struct ActivityCaptured {
    var log: String?
    var logDateString: String?
    var logDate: Date?
    init?(log:String,logDateString:String,logDate:Date) {
        self.log = log
        self.logDateString = logDateString
        self.logDate = logDate
    }
}
extension ActivityCaptured : Equatable {}
func ==(lhs: ActivityCaptured, rhs: ActivityCaptured) -> Bool {
    return lhs.log == rhs.log && lhs.logDateString == rhs.logDateString && lhs.logDate == rhs.logDate
}

struct ICS214Resources {
    var resource = [ String:String ]()
    var icsPosition = [ String:String ]()
    var agency = [ String:String ]()
    var email = [ String:String ]()
    var phone = [ String:String ]()
    var resourceGuid = [ String:String ]()
}
extension ICS214Resources : Equatable {}
func ==(lhs: ICS214Resources, rhs: ICS214Resources) -> Bool {
    return lhs.resource == rhs.resource && lhs.email == rhs.email && lhs.phone == rhs.phone && lhs.icsPosition == rhs.icsPosition && lhs.agency == rhs.agency && lhs.resourceGuid == rhs.resourceGuid
}

struct CellParts {
    var cellAttributes = [ String : String ]()
    var type = [ String : FormType ]()
    var vType = [ String: ValueType ]()
    var dType = [ String: Date ]()
    var objID = [ String: Any? ]()
}
extension CellParts: Equatable {}
func ==(lhs: CellParts, rhs: CellParts) -> Bool {
    return lhs.cellAttributes == rhs.cellAttributes && lhs.type == rhs.type && lhs.vType == rhs.vType
}

struct Resource {
    var contact = [ String : String ]()
}
extension Resource : Equatable {}
func ==(lhs: Resource, rhs: Resource) -> Bool {
    return lhs.contact == rhs.contact
}

struct ResourceAttendee {
    var name: String!
    var email: String?
    var phone: String?
    var icsPosition: String?
    var homeAgency: String?
    var guid: String?
    init?(name: String, email: String, phone: String, icsPosition: String, homeAgency: String, guid: String) {
        self.name = name
        self.email = email
        self.phone = phone
        self.icsPosition = icsPosition
        self.homeAgency = homeAgency
        self.guid = guid
    }
}
extension ResourceAttendee : Equatable {}
func ==(lhs: ResourceAttendee, rhs: ResourceAttendee) -> Bool {
    return lhs.name == rhs.name && lhs.email == rhs.email && lhs.phone == rhs.phone && lhs.icsPosition == rhs.icsPosition && lhs.homeAgency == rhs.homeAgency && lhs.guid == rhs.guid
}



enum FormType:String {
    case teamCell = "team cell"
    case twoTF = "Two"
    case oneTF = "One"
    case photoAndTF = "A Photo with Owner Name"
    case header = "Header"
    case textInputCell = "text input"
    case doubleTextFieldCell = "double text input"
    case entryThreeFieldsCell = "3 field entry"
    case entryTwoFieldsCell = "2 field entry"
    case completedThreeFieldCell = "3 fields answered"
    case completedTwoFieldCell = "2 fields answered"
    case doubleButtonCell = "double button cell"
    case pickerDateCell = "pickerDate cell"
    case pickerDateTwoCell = "pickerDate Second Cell"
    case pickerDateThreeCell = "pickerDate Third Cell"
    case fourTextOneButtonCell = "four text fields one button cell"
    case modalHeader = "header for modal"
    case listHeader = "address list header"
    case twoFieldsOneButtonCell = "one button two fields cell"
    case contactsCell = "contacts cell"
    case listCell = "contact list cell"
    case addButtonCell = "add button cell"
    case noSelectCell = "no selection cell"
    case formTwoInputWTV = "form cell with two input one Text View"
    case completedTwoInputWTV = "completed cell with two input one Text View"
    case theMapCell = "the map cell"
    case paragraphCell
    case formSegmentCell
    case fourSwitchCell
    case efforWithDateCell
    case effortWithoutDateCell
    case effortWithoutDateCellAddress
    case incidentMasterCell
    case journalMasterCell
    case IncidentDateInputCell
    case IncidentDatesCell
    case IncidentDoubleEntryCell
    case IncidentEmergencyCell
    case IncidentIndicatorCell
    case IncidentLocationButtonCell
    case IncidentSingleEntryCell
    case IncidentTypeCell
}

enum ValueType:String {
    case fjKIncidentName = "incidentName"
    case fjKDateFrom = "dateFrom"
    case fjKDateTo = "dateTo"
    case fjKUnitLeader = "unitLeader"
    case fjKICSPosition = "icsUnitPosition"
    case fjKISCUnitName = "unitName"
    case fjKTeamMember = "teamMember"
    case fjKTeamICSPosition = "teamICSPosition"
    case fjKTeamHomeAgency = "teamHomeAgency"
    case fjKActivityLogDate = "activityLogDate"
    case fjKNotableActivity = "notableActivity"
    case fjKPreparedName = "preparedName"
    case fjKPreparedPosition = "preparedPosition"
    case fjKPreparedSignature = "preparedSignature"
    case fjKPreparedDate = "preparedDate"
    case fjKEmpty = ""
    case fjKEffortType
    case fjKIncidentNumber
    case fjKTeamName
    case fjKIncidentFormNumber
    case fjKIncidentDate
    case fjKIncidentDateInput
    case fjKIncidentEmergency
    case fjKIncidentType
    case fjKIncidentLocalType
    case fjKIncidentNFIRSType
    case fjKIncidentLocationButtons
    case fjKIncidentStreetNumAndName
    case fjKIncidentCity
    case fjKIncidentStateAndZip
    case fjKIncidentLocationType
    case fjKIncidentStreetType
    case fjKIncidentStreetPrefix
}

struct ICS214FormStructure {
    var eventType:String?
    var teamType:String?
    var incidentName: String?
    var incidentNumber: String?
    var dateFrom: Date?
    var dateTo: Date?
    var unitLeader: String?
    var icsPosition: String?
    var icsUnitName: String?
    var preparedByName: String?
    var preparedPosition: String?
    var preparedSignature: String?
    var preparedDate: Date?
    var ics214guid: String = ""
    var masterGuid: String?
    var incidentGuid: String?
    var journalGuid: String?
    var effort: String?
}

struct IncidentEntry {
    var incidentNumber: String!
    var incidentDate: Date!
    var incidentStreetNumber: String!
    var incidentStreetName: String!
    var incidentZip: String!
    var situationIncidentImage: String!
    var incidentEntryTypeImageName: String!
    init?(incidentNumber:String,incidentDate:Date,incidentStreetNumber:String,incidentStreetName:String,incidentZip:String,situationIncidentImage:String,incidentEntryTypeImageName:String) {
        self.incidentNumber = incidentNumber
        self.incidentDate = incidentDate
        self.incidentStreetNumber = incidentStreetNumber
        self.incidentStreetName = incidentStreetName
        self.incidentZip = incidentZip
        self.situationIncidentImage = situationIncidentImage
        self.incidentEntryTypeImageName = incidentEntryTypeImageName
    }
}


//  MARK: - Remaking Cell Parts
protocol CellStorage {
    //    MARK: - CELL type - FormType
    var type: FormType { get }
    //    MARK: - Cell Tag Int
    var tag: Int { get set }
    //    MARK: -TEXT FOR CELL- replacing cellAttributes
    var header: String { get set }
    var field1: String { get set }
    var field2: String { get set }
    var field3: String { get set }
    var field4: String { get set }
    var cellValue1: String { get set }
    var cellValue2: String { get set }
    var cellValue3: String { get set}
    var cellValue4: String { get set}
    var cellValue5: String { get set}
    
    //    MARK: -valueTypes replacing vType
    var valueType1: ValueType { get }
    var valueType2: ValueType { get }
    var valueType3: ValueType { get }
    var valueType4: ValueType { get }
    var valueType5: ValueType { get }
    
    //    MARK: - replacing dtype
    var cellDate: Date { get set }
    
    //    MARK: - ics214 objects id
    var objectID: NSManagedObjectID { get }
}

extension CellStorage {
    
    var type: FormType {
        return FormType.header
    }
    
    var valueType1: ValueType {
        return ValueType.fjKEmpty
    }
    
    var valueType2: ValueType {
        return ValueType.fjKEmpty
    }
    
    var valueType3: ValueType {
        return ValueType.fjKEmpty
    }
    
    var valueType4: ValueType {
        return ValueType.fjKEmpty
    }
    
    var valueType5: ValueType {
        return ValueType.fjKEmpty
    }
    
    var cellDate: Date {
        return Date()
    }
    
    var cellValue1: String {
        return ""
    }
    
    var cellValue2: String {
        return ""
    }
    
    var cellValue3: String {
        return ""
    }
    
    var cellValue4: String {
        return ""
    }
    
    var cellValue5: String {
        return ""
    }
    
    var field1: String {
        return ""
    }
    
    var field2: String {
        return ""
    }
    
    var field3: String {
        return ""
    }
    
    var field4: String {
        return ""
    }
    
    var tag: Int {
        return 0
    }
    
}

class ICS214Cell0: CellStorage {
    
    var tag = 0
    
    var type: FormType = FormType.header
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell1: CellStorage {
    
    
    var tag = 1
    
    var type: FormType = FormType.textInputCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
    var valueType1: ValueType {
        return ValueType.fjKIncidentName
    }
    
}

class ICS214Cell2: CellStorage {
    
    var tag = 2
    
    var type: FormType = FormType.doubleButtonCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKDateFrom
    }
    
    var valueType2: ValueType {
        return ValueType.fjKDateTo
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
}

class ICS214Cell3: CellStorage {
    
    var tag = 3
    
    var type: FormType = FormType.textInputCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKUnitLeader
    }
    
    var valueType2: ValueType {
        return ValueType.fjKDateTo
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell4: CellStorage {
    
    var tag = 4
    
    var type: FormType =  FormType.textInputCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKICSPosition
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell5: CellStorage {
    
    var tag = 5
    
    var type: FormType = FormType.textInputCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKISCUnitName
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell6: CellStorage {
    
    var tag = 6
    
    var type: FormType = FormType.entryThreeFieldsCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = "Name"
    
    var field2: String = "ICS Position"
    
    var field3: String = "Home Agency"
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
}

class ICS214Cell8: CellStorage {
    
    var tag = 8
    
    var type: FormType = FormType.fourTextOneButtonCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var field1: String = "Name:"
    
    var field2: String = "Position/Type:"
    
    var field3: String = "Signature:"
    
    var field4: String = "Date/Time:"
    
    var cellValue1: String = "preparationName"
    
    var cellValue2: String = "postionType"
    
    var cellValue3: String = "signature"
    
    var cellValue4: String = "date"
    
    var cellValue5: String = "dateSignature"
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
}

class ICS214Cell9: CellStorage {
    
    var tag = 9
    
    var type: FormType = FormType.pickerDateCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""

}

class ICS214Cell10: CellStorage {
    
    var tag = 10
    
    var type: FormType = FormType.pickerDateTwoCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell11: CellStorage {
    
    var tag = 11
    
    var type: FormType = FormType.pickerDateThreeCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell7: CellStorage {
    
    var tag = 7
    
    var type: FormType = FormType.formTwoInputWTV
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
    var field1: String = "Day/Time"
    
    var field2: String = "Notable Activities"
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = "date"
    
    var cellValue2: String = "activity"
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell3Entered: CellStorage {
    
    var tag = 15
    
    var type: FormType = FormType.formTwoInputWTV
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class ICS214Cell2Entered: CellStorage {
    
    var tag = 16
    
    var type: FormType = FormType.completedThreeFieldCell
    
    var objectID: NSManagedObjectID
    
    var cellDate: Date
    
    var header: String
    
    init(header: String, date: Date, id: NSManagedObjectID) {
        self.header = header
        self.cellDate = date
        self.objectID = id
    }
    
    var valueType1: ValueType {
        return ValueType.fjKTeamMember
    }
    
    var valueType2: ValueType {
        return ValueType.fjKTeamICSPosition
    }
    
    var valueType3: ValueType {
        return ValueType.fjKTeamHomeAgency
    }
    
    var field1: String = ""
    
    var field2: String = ""
    
    var field3: String = ""
    
    var field4: String = ""
    
    var cellValue1: String = ""
    
    var cellValue2: String = ""
    
    var cellValue3: String = ""
    
    var cellValue4: String = ""
    
    var cellValue5: String = ""
    
}

class CellAttributes: NSObject {
    
    var cells = [CellStorage]()
    
    override init() {
        super.init()
        let emptyString: String = ""
        let date = Date()
        let obID = NSManagedObjectID()
        let cell0 = ICS214Cell0(header: emptyString, date: date, id: obID)
        cells.append(cell0)
        let cell1 = ICS214Cell1.init(header: "1. Incident Name:", date: date, id: obID)
        cells.append(cell1)
        let cell2 = ICS214Cell2.init(header: "2 Operational Period:", date: date, id: obID)
        cells.append(cell2)
        let cell9 = ICS214Cell9.init(header: "", date: date, id: obID)
        cells.append(cell9)
        let cell3 = ICS214Cell3.init(header: "3 Name:", date: date, id: obID)
        cells.append(cell3)
        let cell4 = ICS214Cell4.init(header: "4 ICS Position:", date: date, id: obID)
        cells.append(cell4)
        let cell5 = ICS214Cell5.init(header: "5. Home Agency:", date: date, id: obID)
        cells.append(cell5)
        let cell6 = ICS214Cell6.init(header: "6. Resources Assigned:", date: date, id: obID)
        cells.append(cell6)
        let cell7 = ICS214Cell7.init(header: "7. Activity Log:", date: date, id: obID)
        cells.append(cell7)
        let cell10 = ICS214Cell10.init(header: "", date: date, id: obID)
        cells.append(cell10)
        let cell8 = ICS214Cell8.init(header: "8. Prepared By:", date: date, id: obID)
        cells.append(cell8)
        let cell11 = ICS214Cell11.init(header: "", date: date, id: obID)
        cells.append(cell11)
    }
}
