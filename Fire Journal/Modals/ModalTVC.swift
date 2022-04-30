//
//  ModalTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 7/21/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

public enum SwitchTypes: Int {
    case platoon
    case fireStation
    case assignment
    case apparatus
    case resources
    case crew
    case tag
    case nfirsBasic1Type
    case localIncidentType
    case incidentNumber
    case dateTime
    case address
    case dateTo
    case dateFrom
    case incidentName
    case effort
    case campaign
    case completed
}

struct ICS214Data {
    var completed: Bool = false
    var incidentName: String = ""
    var fromDate: Date = Date()
    var toDate: Date = Date()
    var effort: String = ""
    var campaign: String = ""
}

struct AlarmData {
    var completed: Bool = false
    var campaign: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var installedAlarms: String = ""
    var c02AlarmsInstalled: String = ""
    var batteriesReplaced: String = ""
}

struct SearchParameters {
    var searchComplete: Bool = true
    var searchDate: Date?
}

protocol ModalTVCDelegate: AnyObject {
    func dismissTapped(shift: MenuItems)
    func saveBTapped(shift: MenuItems)
    func formTypedTapped(shift: MenuItems)
    func journalSaved(id:NSManagedObjectID,shift:MenuItems)
    func incidentSave(id:NSManagedObjectID,shift:MenuItems)
}

class ModalTVC: UITableViewController, StartShiftOvertimeSwitchDelegate,dismissUpdateSaveCellDelegate,dismissSaveCellDelegate,AddressFieldsButtonsCellDelegate,LabelTextViewDirectionalCellDelegate,LabelDateTimeButtonCellDelegate,DatePickerCellDelegate,LabelTextFieldCellDelegate,LabelTextViewCellDelegate,LabelAnswerSwitchCellDelegate,LabelTextViewSwitchCellDelegate,LabelTextFieldWithDirectionCellDelegate,MapViewCellDelegate,IncidentTextViewWithDirectionalCellDelegate,SegmentCellDelegate,CLLocationManagerDelegate,ImageTextFieldTextViewCellDelegate,LabelDirectionalTVSwitchCellDelegate,LabelTextFieldDirectionalSwitchCellDelegate,LabelNoDescripAnswerSwitchCellDelegate,LabelDateTimeSearchSwitchButtonCellDelegate,AddressSearchButtonsCellDelegate,LabelSearchTextViewDirectionalSwitchCellDelegate,ModalDataTVCDelegate,DatePickerDelegate,LabelNumberFieldCellDelegate,CrewModalTVCDelegate,ModalResourcesTVCDelegate,DataModalTVCDelegate,JournalSegmentDelegate,ModalHeaderSaveDismissDelegate,ModalFDResourcesDataDelegate {
    
    //    MARK: Objects
    var modalTitle: String = ""
    var modalInstructions: String = ""
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    var fjUserTime:UserTime! = nil
    
    // MARK: Properties
    var myShift: MenuItems = .journal
    var journalType: JournalTypes = .station
    var incidentType: IncidentTypes = .fire
    var overtimeOrAMB: Bool = false
    weak var delegate: ModalTVCDelegate? = nil
    var overtimeOrAM: String = ""
    var showPicker:Bool = false
    var showMap:Bool = false
    var startShift = StartShift.init(startTime: "")
    var incidentStructure: IncidentData!
    var journalStructure: JournalData!
    var startShiftStructure: StartShiftData!
    var shift: Shift!
    var endShiftStructure: EndShiftData!
    var updateShiftStructure: UpdateShiftData!
    var alarmStructure: AlarmData!
    var ics214Structure: ICS214Data!
    var city: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var stateName: String = ""
    var zipNum: String = ""
    var segmentType: MenuItems = .fire
    var updateTapped:Bool = false
    
    var locationManager:CLLocationManager!
    private var tableSize: TableSize!
    var sendingEntity: String = ""
    var sendingAttribue: String = ""
    private let segue: String = "ModalDataShow"
    var fju:FireJournalUser!
    var fetched:Array<Any>!
    var objectID:NSManagedObjectID!
    var userChanged:Bool = false
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var theCrew: TheCrew!
    var theUserCrew: UserCrews!
    var theResourcesGroup: UserResourcesGroups!
    var group: ResourcesItem!
    var theUser: UserEntryInfo!
    var personalJournalEntry: Bool = false
    var fjIncident:Incident!
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    
    
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    
    //    MARK: -DataModalTVCDelegate
    func dataModalCancelCalled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theDataModalChosen(objectID: NSManagedObjectID, user: UserInfo) {
        switch user {
        case .platoon:
            let platoon = context.object(with:objectID) as? UserPlatoon
            theUser.platoon = platoon?.platoon ?? ""
            theUser.platoonGuid = platoon?.platoonGuid ?? ""
            theUser.platoonDefault = platoon?.defaultPlatoon ?? true
            switch myShift {
            case .startShift:
                startShiftStructure.ssPlatoonTF = theUser.platoon
                startShiftStructure.ssPlatoonB = theUser.platoonDefault
            case .updateShift:
                updateShiftStructure.upsPlatoonTF = theUser.platoon
                updateShiftStructure.upsPlatoonB = theUser.platoonDefault
            default: break
            }
        case .apparatus:
            let apparatus = context.object(with:objectID) as? UserApparatusType
            theUser.apparatus = apparatus?.apparatus ?? ""
            theUser.apparatusGuid = apparatus?.apparatusGuid ?? ""
            theUser.apparatusDefault = apparatus?.defaultApparatus ?? true
            startShiftStructure.ssApparatusTF = theUser.apparatus
            startShiftStructure.ssApparatusB = theUser.apparatusDefault
        case .assignment:
            let assignment = context.object(with:objectID) as? UserAssignments
            theUser.assignment = assignment?.assignment ?? ""
            theUser.assignmentGuid = assignment?.assignmentGuid ?? ""
            theUser.assignmentDefault = assignment?.defaultAssignment ?? true
            startShiftStructure.ssAssignmentTF = theUser.assignment
            startShiftStructure.ssAssignmentB = theUser.assignmentDefault
        default:
            print("none")
        }
        tableView.reloadData()
    }
    //    MARK: ModalFDResourcesDataDelegate
    func theResourcesHaveBeenCollected(collectionOfResources: [UserResources]){
        self.dismiss(animated: true, completion: nil)
        //        MARK: TODO
//        let resources = collectionOfResources.joined(separator: ", ")
//        startShiftStructure.ssResourcesTF = resources
//        self.tableView.reloadData()
    }
    func theResourcesHasBeenCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: -ModalResourcesTVCDelegate
    func theModalResourceCancelHasBeenTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theResourcesChoiceHasBeenMade(resourceGroup: ResourcesItem, objectID: NSManagedObjectID) {
        theResourcesGroup = context.object(with: objectID) as? UserResourcesGroups
        
        startShiftStructure.ssResourcesTF = theResourcesGroup.resourcesGroup ?? ""
        startShiftStructure.ssResourcesName = theResourcesGroup.resourcesGroupName ?? ""
        startShiftStructure.ssResourcesCombine = "Resource Group: \(theResourcesGroup.resourcesGroupName ?? ""): \(theResourcesGroup.resourcesGroup ?? "")"
        startShiftStructure.ssResourcesB = theResourcesGroup.resourcesGroupDefault
        if theResourcesGroup.resourcesGroupDefault {
            startShiftStructure.ssResources = "Front Line"
        } else {
            startShiftStructure.ssResources = "Reserve"
        }
        startShiftStructure.ssResourcesGuid = theResourcesGroup.resourcesGroupGuid ?? ""
        self.group = resourceGroup
        self.dismiss(animated: true, completion:nil)
        tableView.reloadData()
    }
    
    
    //    MARK: -CrewModalTVCDelgate
    func theCrewModalCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theCrewModalChosenTapped(crew: TheCrew, objectID: NSManagedObjectID) {
        theUserCrew = context.object(with: objectID) as? UserCrews
        startShiftStructure.ssCrewCombine = "Crew Name: \(crew.crewName) : \(crew.crew)"
        startShiftStructure.ssCrewsName = theUserCrew.crewName ?? ""
        startShiftStructure.ssCrewsTF = theUserCrew.crew ?? ""
        startShiftStructure.ssCrewB = theUserCrew.crewDefault
        if theUserCrew.crewDefault {
            startShiftStructure.ssCrews = "AM Relief"
        } else {
            startShiftStructure.ssCrews = "Overtime"
        }
        startShiftStructure.ssCrewGuid = theUserCrew.crewGuid ?? ""
        theCrew = crew
        self.dismiss(animated: true, completion:nil)
        tableView.reloadData()
    }
    
    //    MARK: -LabelNumberFieldCellDELEGATE
    func numberFieldEdited(text: String) {
        incidentStructure.incidentNumber = text
    }
    
    func numberFieldDoneEditing(text: String) {
        incidentStructure.incidentNumber = text
        tableView.reloadData()
    }
    
    //    MARK: -DatePickerDelegate
    /**for the incident TVC*/
    
    func nfirsSecMOfficersChosenDate(date:Date,incidentType:IncidentTypes){}
    func nfirsSecMMembersChosenDate(date:Date,incidentType:IncidentTypes){}
    
    func alarmTimeChosenDate(date: Date, incidentType: IncidentTypes) {
            incidentStructure.incidentAlarmDate = date
            incidentStructure.incidentFullAlarmDateS = vcLaunch.fullDateString(date:date)
            incidentStructure.incidentAlarmMM = vcLaunch.monthString(date: date)
            incidentStructure.incidentAlarmdd = vcLaunch.dayString(date: date)
            incidentStructure.incidentAlarmYYYY = vcLaunch.yearString(date: date)
            incidentStructure.incidentAlarmHH = vcLaunch.hourString(date: date)
            incidentStructure.incidentAlarmmm = vcLaunch.minuteString(date: date)
        tableView.reloadData()
    }
    
    func journalTimeChosenDate(date: Date, myShift: MenuItems)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
        let journalDate = dateFormatter.string(from: date)
        return journalDate
    }
    
    func arrivalTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        <#code#>
    }
    
    func controlledTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        <#code#>
    }
    
    func lastUnitTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        <#code#>
    }
    
    func directionalBJWasTapped(type: UserInfo) {
        switch type {
        case .platoon:
            incidentType = .platoon
        case .assignment:
            incidentType = .assignment
        case .apparatus:
            incidentType = .apparatus
        default:
            print("nope")
        }
        performSegue(withIdentifier: segue, sender: self)
    }
    
    func theTextFieldHasBeenEdited2(text: String) {
        //        <#code#>
    }
    
    //    MARK: -ModalDataTVCDelegate
    func theModalDataCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theModalDataTapped(object:NSManagedObjectID,type:IncidentTypes, index: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        print("here is the objecct \(object) and the type \(type)")
        switch type {
        case .nfirsIncidentType:
            let nfirsB1Type:NFIRSIncidentType = context.object(with: object) as! NFIRSIncidentType
            var name: String = ""
            var number: String = ""
            if let nfirsNum = nfirsB1Type.incidentTypeNumber {
                number = nfirsNum
            }
            if let nfirsName = nfirsB1Type.incidentTypeName {
                name = nfirsName
            }
            incidentStructure.incidentNFIRSType = "\(name)"
            incidentStructure.incidentNfirsIncidentType = "\(number) \(name)"
            incidentStructure.incidentNfirsIncidentTypeNumber = "\(number)"
        case .localIncidentType:
            let localIncidentType:UserLocalIncidentType = context.object(with: object) as! UserLocalIncidentType
            incidentStructure.incidentLocalType = localIncidentType.localIncidentTypeName ?? ""
        case .locationType:
            let location:NFIRSLocation = context.object(with: object) as! NFIRSLocation
            incidentStructure.incidentLocationType = location.location ?? ""
        case .streetType:
            let streetType:NFIRSStreetType = context.object(with: object) as! NFIRSStreetType
            incidentStructure.incidentStreetType = streetType.streetType ?? ""
        case .streetPrefix:
            let streetPrefix:NFIRSStreetPrefix = context.object(with: object) as! NFIRSStreetPrefix
            incidentStructure.incidentStreetPrefix = streetPrefix.streetPrefixAbbreviation ?? ""
        case .platoon:
            let platoon:UserPlatoon = context.object(with: object) as! UserPlatoon
            journalStructure.journalPlatoon = platoon.platoon ?? ""
            journalStructure.journalPlatoonGuid = platoon.platoonGuid ?? ""
            userChanged = true
        case .assignment:
            let assignment:UserAssignments = context.object(with: object) as! UserAssignments
            journalStructure.journalAssignment = assignment.assignment ?? ""
            journalStructure.journalAssignmentGuid = assignment.assignmentGuid ?? ""
            userChanged = true
        case .apparatus:
            let apparatus:UserApparatusType = context.object(with: object) as! UserApparatusType
            journalStructure.journalApparatus = apparatus.apparatus ?? ""
            journalStructure.journalApparatusGuid = apparatus.apparatusGuid ?? ""
            userChanged = true
        default:
            print("nothing to report")
        }
        
        tableView.reloadData()
    }
    func theModalDataWithTapped(type: IncidentTypes) {
        //
    }
    
    func theDirectionalButtonWasTapped(type: JournalTypes) {
        //        TODO:
    }
    
    func theTextViewIsFinishedEditing(type: JournalTypes, text: String) {
        //        TODO:
    }
    
    func theAddressHasBeenChosen(addressStreetNum:String,addressStreetName:String, addressCity: String, addressState: String, addressZip: String, location: CLLocation) {
        switch myShift {
        case .incidents:
            incidentStructure.incidentStreetNum = addressStreetNum
            incidentStructure.incidentStreetName = addressStreetName
            incidentStructure.incidentCity = addressCity
            incidentStructure.incidentState = addressState
            incidentStructure.incidentZip = addressZip
            incidentStructure.incidentLocation = location
        default:
            print("no incident")
        }
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        self.tableView.reloadData()
    }
    
    //    MARK: -LabelSearchTextViewDirectionalSwitchCellDELEGATE
    func tvSearchTextIsEditing(text: String) {
        print("TODO")
    }
    func tvSearchTextIsDoneEditing(text: String) {
        print("TODO")
    }
    func tvSearchDirectionalTapped() {
        print("TODO")
    }
    func tvSearchSwitchTaopped() {
        print("TODO")
    }
    //    MARK: -AddressSearchButtonsCellDelegate
    func theSearchLocationTapped() {
        print("TODO")
    }
    func theSearchMapTapped() {
        print("world tapped")
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        tableView.reloadData()
    }
    func theSearchAddressSwitchTapped() {
        print("TODO")
    }
    func theSearchTextIsEditing(text: String) {
        print("TODO")
    }
    func theSearchTextIsFinished(text: String) {
        print("TODO")
    }
    //   MARK: -LabelDateTimeSearchSwitchButtonCellDelegate
    func textEditing() {
        print("TODO")
    }
    func theTextIsFinishedEditing() {
        print("TODO")
    }
    func theTimeButtonWasTapped() {
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
    func theSearchSwitchWasTapped() {
        print("TODO")
    }
    //    MARK: -LabelNoDescripAnswerSwitchCellDelegate
    func theTextIsEditing() {
        print("TODO")
    }
    func theSwitchWasTappedHere() {
        print("TODO")
    }
    func theTextHasStoppedEditing() {
        print("TODO")
    }
    //    MARK: -LabelTextFieldDirectionalSwitchCellDelegate
    func directionalButTapped(switchType: SwitchTypes, type: MenuItems ) {
        switch type {
        case .startShift:
            switch switchType {
            case .resources:
                presentResource(menuType: type, title: "Resources", type: .resources)
            case .apparatus:
                presentModal(menuType: type, title: "Apparatus", type: .apparatus)
            case .assignment:
                presentModal(menuType: type, title: "Assignment", type: .assignment)
            case .platoon:
                presentModal(menuType: type, title: "Platoon", type: .platoon)
            default:
                print("no resources")
            }
        case .updateShift:
            switch switchType {
                case .platoon:
                presentModal(menuType: type, title: "Platoon", type: .platoon)
                default: break
            }
        default:
            print("no")
        }
    }
    func defaultOvertimeDirectionalSwitchTapped(switched: Bool, type: MenuItems, switchType: SwitchTypes) {
        print("switch tapped and we are boolean \(switched) \(type) \(switchType)")
        switch type {
        case .startShift:
            switch switchType {
            case .resources:
                if switched {
                    startShiftStructure.ssResources = "Front Line"
                    startShiftStructure.ssResourcesB = switched
                } else {
                    startShiftStructure.ssResources = "Reserve"
                    startShiftStructure.ssResourcesB = switched
                }
            case .apparatus:
                if switched {
                    startShiftStructure.ssApparatus = "Default"
                    startShiftStructure.ssApparatusB = switched
                } else {
                    startShiftStructure.ssApparatus = "Temp"
                    startShiftStructure.ssApparatusB = switched
                }
            case .assignment:
                if switched {
                    startShiftStructure.ssAssignment = "Default"
                    startShiftStructure.ssAssignmentB = switched
                } else {
                    startShiftStructure.ssAssignment = "Overtime"
                    startShiftStructure.ssAssignmentB = switched
                }
            case .platoon:
                if switched {
                    startShiftStructure.ssPlatoon = "Default"
                    startShiftStructure.ssPlatoonB = switched
                } else {
                    startShiftStructure.ssPlatoon = "Temp"
                    startShiftStructure.ssPlatoonB = switched
                }
            default:
                print("")
            }
        default:
            print("")
        }
        tableView.reloadData()
    }
    func descriptionTextFieldDoneEditing() {
        print("some one is done type here")
    }
    //    MARK: -LabelDirectionalTVSwitchCellDelegate
    func tvDirectionalTapped(myShift: MenuItems) {
        switch myShift {
        case .startShift:
            presentCrew(menuType: myShift, title: "Crew", type: .crew)
        default:
            print("none")
        }
    }
    func tvSwitchTapped(myShift: MenuItems, defaultOvertimeB: Bool) {
        print(myShift)
    }
    
    //    MARK: -presentCrew for startShift
    fileprivate func presentCrew(menuType:MenuItems, title:String, type:IncidentTypes){
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "CrewModalTVC") as! CrewModalTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.headerTitle = title
        dataTVC.myShift = menuType
        dataTVC.incidentType = type
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    //    MARK: -PRESENT RESOURCES FOR STARTSHIFT
    fileprivate func presentResource(menuType:MenuItems, title:String, type:IncidentTypes) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "ModalResourcesTVC") as! ModalResourcesTVC
//        dataTVC.delegate = self
//        dataTVC.transitioningDelegate = slideInTransitioningDelgate
//        dataTVC.headerTitle = title
//        dataTVC.myShift = menuType
//        dataTVC.incidentType = type
//        dataTVC.modalPresentationStyle = .custom
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "ModalFDResourcesDataTVC") as! ModalFDResourcesDataTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.titleName = title
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    //    MARK: -presentModal for Apparatus, Assignment, Platoon
    fileprivate func presentModal(menuType: MenuItems, title: String, type: UserInfo) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "DataModalTVC") as! DataModalTVC
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        modalTVC.myShift = menuType
        modalTVC.userInfo = type
        modalTVC.modalPresentationStyle = .custom
        self.present(modalTVC, animated: true, completion: nil)
    }
    
    //    MARK: -LabelTextFieldDirectionalSwitchCellDelegate
    func defaultOvertimeDirectionalSwitchTapped(switched: Bool, type: MenuItems) {
        // TODO:
    }
    //    MARK: -ImageTextFieldTextViewCellDelegate
    func cellSelectedTapped(type: MenuItems) {
        switch type {
        case .nfirs:
            print("nirs")
        case .ics214:
            print("ics214")
        case .arcForm:
            print("archForm")
        default:break
        }
        delegate?.formTypedTapped(shift: type)
    }
    //    MARK: -journalSegmentDelegate
    func journalSectionChosen(type: MenuItems) {
        print("here is the type \(type)")
        segmentType = type
        switch segmentType {
        case .station:
            journalStructure.journalType = "Station"
        case .community:
            journalStructure.journalType = "Community"
        case .members:
            journalStructure.journalType = "Members"
        case .training:
            journalStructure.journalType = "Training"
        default:
            break
        }
    }
    //    MARK: -segmentCellDelegate
    func sectionChosen(type: MenuItems) {
        switch type {
        case .fire:
            incidentStructure.incidentType = "Fire"
            incidentStructure.incidentImageName = "100515IconSet_092016_fireboard"
        case .ems:
            incidentStructure.incidentType = "EMS"
            incidentStructure.incidentImageName = "100515IconSet_092016_emsboard"
        case .rescue:
            incidentStructure.incidentType = "Rescue"
            incidentStructure.incidentImageName = "100515IconSet_092016_rescueboard"
        default:
            print("no type")
        }
        segmentType = type
        tableView.reloadData()
    }
    //    MARK: IncidentTextViewWithDirectionalCellDelegate
    func theIncidentDirectionalButtonWasTapped() {
        incidentType = .nfirsIncidentType
        performSegue(withIdentifier: segue, sender: self)
    }
    func theIncidentTextViewIsFinishedEditing() {
        //  TODO:
    }
    
    func nfirsIncidentTypeInfoTapped() {
        if !alertUp {
            let message = "You can either type in the NFIRS Incident 3 digit number into the text field to add the correct NFIRS Incident Type or click on the red directional button to the left to bring up the whole list of NFIRS Incident Types."
            let alert = UIAlertController.init(title: "NFIRS Incident Type", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }

    func nfirstIncidentTyped(code: String) {
        let entity = "NFIRSIncidentType"
        let attribute = "incidentTypeNumber"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K = %@",attribute,code)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            self.fetched = try context.fetch(fetchRequest) as! [NFIRSIncidentType]
            if !self.fetched.isEmpty {
                let nfirsIncidentType = self.fetched.last as! NFIRSIncidentType
                var number: String = ""
                var name: String = ""
                if let nfirsNum = nfirsIncidentType.incidentTypeNumber {
                    number = nfirsNum
                }
                if let nfirsName = nfirsIncidentType.incidentTypeName {
                    name = nfirsName
                }
                incidentStructure.incidentNFIRSType = "\(name)"
                incidentStructure.incidentNfirsIncidentType = "\(number) \(name)"
                incidentStructure.incidentNfirsIncidentTypeNumber = "\(number)"
                let indexPath = IndexPath(row: 9, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as! IncidentTextViewWithDirectionalCell
                cell.descriptionTV.text = incidentStructure.incidentNfirsIncidentType
                cell.descriptionTV.setNeedsDisplay()
            } else {
                if !alertUp {
                    let message = "\(code) was not found to be part of the list of NFIRS Incident Type - please select from the NFIRS Incident Type list instead."
                    let alert = UIAlertController.init(title: "NFIRS Incident Type", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                        self.alertUp = false
                        self.incidentType = .nfirsIncidentType
                        self.performSegue(withIdentifier: self.segue, sender: self)
                    })
                    alert.addAction(okAction)
                    alertUp = true
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } catch let error as NSError {
            print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -MapViewCellDelegate
    func theMapCellInfoBTapped() {
           presentAlert()
       }
       
       func presentAlert() {
           let title: InfoBodyText = .mapSupportNotesSubject
           let message: InfoBodyText = .mapSupportNotes
           let alert = UIAlertController.init(title: title.rawValue , message: message.rawValue, preferredStyle: .alert)
           let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
               self.alertUp = false
           })
           alert.addAction(okAction)
           alertUp = true
           self.present(alert, animated: true, completion: nil)
       }
    
    func theMapLocationHasBeenChosen(location: CLLocation) {
        //        TODO:
    }
    func theMapCancelButtonTapped() {
        //        TODO:
    }
    //    MARK: -LabelTextFieldWithDirectionCellDelegate
    func directionalBTapped(type:IncidentTypes) {
        incidentType = type
        performSegue(withIdentifier: segue, sender: self)
    }
    func theTextFieldHasBeenEdited(text: String, type: UserInfo) {
        // TODO:
    }
    //    MARK: -LabelTextViewSwitchCellDelegate
    func labelTextViewSwitchCellSwitchTapped(switched: Bool, switchType: SwitchTypes, type: MenuItems) {
        switch type {
        case .startShift:
            startShiftStructure.ssCrewB = switched
            if switched {
                startShiftStructure.ssCrews = "AM Relief"
            } else {
                startShiftStructure.ssCrews = "Overtime"
            }
        default:
            print("no switch")
        }
        print(startShiftStructure!)
        tableView.reloadData()
    }
    func textViewEdited(text: String, switchType: SwitchTypes,myShift: MenuItems) {
        switch myShift {
        case .startShift:
            switch switchType {
            case .crew:
                startShiftStructure.ssCrewsTF = text
            default:
                print("no text view")
            }
        default:
            print("ain't no text view here")
        }
    }
    func textViewDidEndEditing(text: String, switchType: SwitchTypes,myShift: MenuItems) {
        switch myShift {
        case .startShift:
            switch switchType {
            case .crew:
                startShiftStructure.ssCrewsTF = text
            default:
                print("no text view")
            }
        default:
            print("ain't no text view here")
        }
    }
    //    MARK: -LabelAnswerSwitchCellDELEGATE
    func defaultOvertimeSwitchTapped(switched:Bool,type:MenuItems,switchType: SwitchTypes) {
        switch type {
        case .startShift:
            switch switchType {
            case .platoon:
                startShiftStructure.ssPlatoonB = switched
                if switched {
                    startShiftStructure.ssPlatoon = "Temp"
                } else {
                    startShiftStructure.ssPlatoon = "Default"
                }
            case .fireStation:
                startShiftStructure.ssFireStationB = switched
                if switched {
                    startShiftStructure.ssFireStation = "Default"
                } else {
                    startShiftStructure.ssFireStation = "Overtime"
                }
            case .assignment:
                startShiftStructure.ssAssignmentB = switched
                if switched {
                    startShiftStructure.ssAssignment = "Overtime"
                } else {
                    startShiftStructure.ssAssignment = "Default"
                }
            case .apparatus:
                startShiftStructure.ssApparatusB = switched
                if switched {
                    startShiftStructure.ssApparatus = "Temp"
                } else {
                    startShiftStructure.ssApparatus = "Default"
                }
            case .resources:
                startShiftStructure.ssResourcesB = switched
                if switched {
                    startShiftStructure.ssResources = "Overtime"
                } else {
                    startShiftStructure.ssResources = "Default"
                }
            default:
                print("no bool")
            }
        case .endShift:
            switch switchType {
            case .platoon:
                endShiftStructure.esPlatoonB = switched
                if switched {
                    endShiftStructure.esPlatoon = "Temp"
                } else {
                    endShiftStructure.esPlatoon = "Default"
                }
            case .fireStation:
                endShiftStructure.esFireStationB = switched
                if switched {
                    endShiftStructure.esFireStation = "Overtime"
                } else {
                    endShiftStructure.esFireStation = "Default"
                }
            default:
                print("no bool end")
            }
        default:
            print("no boo")
        }
        tableView.reloadData()
    }
    func answerLEditing(text: String, myShift: MenuItems, switchType: SwitchTypes) {
        switch myShift {
        case .startShift:
            switch switchType {
            case .platoon:
                startShiftStructure.ssPlatoonTF = text
            case .fireStation:
                startShiftStructure.ssFireStationTF = text
            case .assignment:
                startShiftStructure.ssAssignmentTF = text
            case .apparatus:
                startShiftStructure.ssApparatusTF = text
            case .resources:
                startShiftStructure.ssResourcesTF = text
            default:
                print("no text here")
            }
        case .updateShift:
            switch switchType {
            case .platoon:
                updateShiftStructure.upsPlatoonTF = text
            case .fireStation:
                updateShiftStructure.upsFireStationTF = text
            default:
                print("no text here")
            }
        case .endShift:
            switch switchType {
            case .platoon:
                endShiftStructure.esPlatoonTF = text
            case .fireStation:
                endShiftStructure.esFireStationTF = text
            default:
                print("no text here")
            }
        default:
            print("no text")
        }
    }
    func answerLDidEndEditing(text: String, switchType: SwitchTypes) {
        switch myShift {
        case .startShift:
            switch switchType {
            case .platoon:
                startShiftStructure.ssPlatoonTF = text
            case .fireStation:
                startShiftStructure.ssFireStationTF = text
            case .assignment:
                startShiftStructure.ssAssignmentTF = text
            case .apparatus:
                startShiftStructure.ssApparatusTF = text
            case .resources:
                startShiftStructure.ssResourcesTF = text
            default:
                print("no text here")
            }
        case .updateShift:
            switch switchType {
            case .platoon:
                updateShiftStructure.upsPlatoonTF = text
            case .fireStation:
                updateShiftStructure.upsFireStationTF = text
            default:
                print("no text here")
            }
        case .endShift:
            switch switchType {
            case .platoon:
                endShiftStructure.esPlatoonTF = text
            case .fireStation:
                endShiftStructure.esFireStationTF = text
            default:
                print("no text here")
            }
        default:
            print("no text")
        }
        print(startShiftStructure!)
    }
    //    MARK: -LabelTextViewCellDELEGATE
    
    func textViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {}
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {}
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
        switch myShift {
        case .startShift:
            startShiftStructure.ssDiscussion = text
        case .updateShift:
            updateShiftStructure.upsDiscussion = text
        case .endShift:
            endShiftStructure.esDiscussion = text
        case .journal,.personal:
            journalStructure.journalOverview = text
        default:
            print("no text")
        }
    }
    func textViewDoneEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
        switch myShift {
        case .startShift:
            startShiftStructure.ssDiscussion = text
        case .endShift:
            endShiftStructure.esDiscussion = text
        case .journal,.personal:
            journalStructure.journalOverview = text
        default:
            print("no text")
        }
        tableView.reloadData()
    }
    //    MARK: LabelTextFieldCellDELEGATE
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        switch myShift {
        case .startShift:
            startShiftStructure.ssRelieving = text
        case .endShift:
            endShiftStructure.esRelieving = text
        case .journal,.personal:
            journalStructure.journalTitle = text
        case .incidents:
            incidentStructure.incidentNumber = text
        default: break
        }
    }
    
    func incidentLabelTFEditing(text:String, myShift: MenuItems, type: IncidentTypes){}
    func incidentLabelTFFinishedEditing(text:String,myShift:MenuItems, type: IncidentTypes){}
    
    
    func userInfoTextFieldEditing(text:String, myShift: MenuItems, journalType: JournalTypes){}
    func userInfoTextFieldFinishedEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        switch myShift {
        case .startShift:
            startShiftStructure.ssRelieving = text
        case .endShift:
            endShiftStructure.esRelieving = text
        case .journal,.personal:
            journalStructure.journalTitle = text
        case .incidents:
            incidentStructure.incidentNumber = text
        default:
            print("NO TEXT")
        }
    }
    //    MARK: -DatePickerDelegate
    func chosenFromDate(date: Date) {
        // TODO:
    }
    func chosenToDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let dateFrom = dateFormatter.string(from: date)
        switch myShift {
        case .incidents:
            incidentStructure.incidentDate = date
        case .journal,.personal:
            journalStructure.journalDate = date
            journalStructure.journalCreationDate = dateFrom
        case .startShift:
            startShiftStructure.ssDateTime = date
        case .endShift:
            endShiftStructure.esDateTime = date
        default:
            print("no date")
        }
        startShift?.startTime = dateFrom
        tableView.reloadData()
    }
    //    MARK: -dateTimeButton expose datePicer
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
            if (incidentStructure != nil) {
                    let date = Date()
                    incidentStructure.incidentAlarmDate = date
                    incidentStructure.incidentFullAlarmDateS = vcLaunch.fullDateString(date:date)
                    incidentStructure.incidentAlarmMM = vcLaunch.monthString(date: date)
                    incidentStructure.incidentAlarmdd = vcLaunch.dayString(date: date)
                    incidentStructure.incidentAlarmYYYY = vcLaunch.yearString(date: date)
                    incidentStructure.incidentAlarmHH = vcLaunch.hourString(date: date)
                    incidentStructure.incidentAlarmmm = vcLaunch.minuteString(date: date)
            }
            if (journalStructure != nil) {
                if journalStructure.journalCreationDate == "" {
                    journalStructure.journalCreationDate = journalTimeChosenDate(date:Date(), myShift: myShift)
                }
            }
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
    //    MARK: -LabelTextViewDirectionalCellDelegate
    func theDirectionalButtonWasTapped() {
        // TODO:
    }
    func theTextViewIsFinishedEditing() {
        // TODO:
    }
    //    MARK: -Address cell delegates
    func addressFieldFinishedEditing(address: String, tag: Int) {
        //        TODO:
    }
    
    func worldBTapped() {
        print("world tapped")
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        switch myShift {
        case .incidents:
            let rowNumber: Int = 10
            let sectionNumber: Int = 0
            let indexPath = IndexPath(item: rowNumber, section: sectionNumber)
            tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            break;
        }
        tableView.reloadData()
    }
    func locationBTapped() {
        print("location tapped")
        determineLocation()
    }
    
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //            locationManager.requestAlwaysAuthorization()
            //            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                self.city = "\(pm.locality!)"
                self.incidentStructure.incidentCity = self.city
                self.streetNum = "\(pm.subThoroughfare!)"
                self.incidentStructure.incidentStreetNum = self.streetNum
                self.streetName = "\(pm.thoroughfare!)"
                self.incidentStructure.incidentStreetName = self.streetName
                self.stateName = "\(pm.administrativeArea!)"
                self.incidentStructure.incidentState = self.stateName
                self.zipNum = "\(pm.postalCode!)"
                self.incidentStructure.incidentZip = self.zipNum
                self.incidentStructure.incidentLocation = userLocation
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    func addressHasBeenFinished() {
        // TODO:
    }
    //    MARK: -dismissSaveDelegate
    func dismissBTapped() {
        print("dismissed")
        delegate?.dismissTapped(shift: myShift)
    }
    
    //    MARK: -ModalHeaderSaveDismissDelegate
    func modalDismiss(){
        switch myShift {
        case .startShift:
            self.userDefaults.set(4, forKey: FJkSTARTUPDATEENDSHIFT)
            delegate?.dismissTapped(shift: myShift)
        case .updateShift, .endShift:
            self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
            delegate?.dismissTapped(shift: myShift)
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
    func modalSave(myShift: MenuItems){
        print("theSaved saveBTapped")
        switch myShift {
        case .startShift:
            saveStartShift()
        case .endShift:
            saveEndShift()
        case .updateShift:
            saveUpdateEndShift()
        case .journal,.personal:
            if journalStructure.journalTitle == "" {
                if !alertUp {
                    let alert = UIAlertController.init(title: "Journal Entry", message: "Please enter a journal entry title.", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                        self.alertUp = false
                    })
                    alert.addAction(okAction)
                    alertUp = true
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                saveTheJournal()
            }
        case .incidents:
            saveTheIncident()
        default:
            delegate?.saveBTapped(shift: myShift)
        }
        updateTapped = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveBTapped() {
        print("theSaved saveBTapped")
        switch myShift {
        case .startShift:
            saveStartShift()
        case .endShift:
            saveEndShift()
        case .updateShift:
            saveUpdateEndShift()
        case .journal,.personal:
            if journalStructure.journalTitle == "" {
                if !alertUp {
                let alert = UIAlertController.init(title: "Journal Entry", message: "Please enter a journal entry title.", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
                }
            } else {
            saveTheJournal()
            }
        case .incidents:
            saveTheIncident()
        default:
            delegate?.saveBTapped(shift: myShift)
        }
        updateTapped = false
    }
    
    private func saveUpdateEndShift(){
        let indexPath = IndexPath(row: 7, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelAnswerSwitchCell
        _ = cell.textFieldShouldEndEditing(cell.answerL)
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDate()
        fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        fjuJournal.journalEntryType = "Station"
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fju.userGuid
        let journalTitle = "Update Shift \(sDate)"
        fjuJournal.journalHeader = journalTitle
        var updateShift:String = ""
        if updateShiftStructure.upsAMReliefDefaultT {
            updateShift = "Move Up"
        } else {
            updateShift = "Overtime"
        }
        let overview:String = "Update Shift:\n\(updateShift)\nDate/Time:\(sDate)\nRelieving:\(updateShiftStructure.upsRelieving)\nDisscussion:\(updateShiftStructure.upsDiscussion)\nPlatoon:\(updateShiftStructure.upsPlatoonTF) - \(updateShiftStructure.upsPlatoon)\nFire Station:\(updateShiftStructure.upsFireStationTF) - \(updateShiftStructure.upsFireStation)\nAssignment: \(updateShiftStructure.upsAssignmentTF) - \(updateShiftStructure.upsAssignment)\rApparatus: \(updateShiftStructure.upsApparatusTF) - \(updateShiftStructure.upsApparatus)\nResources: \(updateShiftStructure.upsResourcesCombine) - \(updateShiftStructure.upsResourcesTF)\nCrew:\(updateShiftStructure.upsCrewCombine) - \(updateShiftStructure.upsCrews)"
        fjuJournal.journalOverview = overview as NSObject
        
        fjuJournal.journalTempPlatoon = updateShiftStructure.upsPlatoonTF
        fjuJournal.journalTempApparatus = updateShiftStructure.upsApparatusTF
        fjuJournal.journalTempAssignment = updateShiftStructure.upsAssignmentTF
        fjuJournal.journalTempFireStation = updateShiftStructure.upsFireStationTF
        fjuJournal.journalFireStation = updateShiftStructure.upsFireStationTF
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
        
        fjuJournal.journalPrivate = true
        
        let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        fjuJournal.addToJournalTagDetails(fjuJournalTags)
        
        fju.platoonDefault = updateShiftStructure.upsPlatoonB
        fju.tempPlatoon = updateShiftStructure.upsPlatoonTF
        fju.assignmentDefault = updateShiftStructure.upsAssignmentB
        fju.tempAssignment = updateShiftStructure.upsAssignmentTF
        fju.tempFireStation = updateShiftStructure.upsFireStationTF
        if fju.fireStation == "" {
            fju.fireStation  = updateShiftStructure.upsFireStationTF
        }
        fju.tempApparatus = updateShiftStructure.upsApparatusTF
        fju.apparatusDefault = updateShiftStructure.upsApparatusB
        fju.tempResources = updateShiftStructure.upsResourcesCombine
        fju.defaultResources = updateShiftStructure.upsResources
        fju.defaultResourcesName = updateShiftStructure.upsResourcesName
        fju.fjpUserModDate = journalModDate
        fju.fjpUserBackedUp = false
        fjuJournal.fireJournalUserInfo = fju
        
        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            fjUserTime.updateShiftStatus = updateShiftStructure.upsAMReliefDefaultT
            fjUserTime.updateShiftFireStation = updateShiftStructure.upsFireStationTF
            fjUserTime.updateShiftPlatoon = updateShiftStructure.upsPlatoonTF
            fjUserTime.updateShiftRelievedBy = updateShiftStructure.upsRelieving
            fjUserTime.updateShiftDiscussion = updateShiftStructure.upsDiscussion
            fjUserTime.userUpdateShiftTime = journalModDate
            fjUserTime.entryState = EntryState.update.rawValue
            fjUserTime.userTimeBackup = false
        }
        
        saveToCD()
    }
    
    private func saveEndShift(){
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDate()
        fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        fjuJournal.journalEntryType = "Station"
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fju.userGuid
        let journalTitle = "End Shift \(sDate)"
        fjuJournal.journalHeader = journalTitle
        var endShift:String = ""
        if endShiftStructure.esAMReliefDefaultT {
            endShift = "AM Relief"
        } else {
            endShift = "Overtime"
        }
        let overview:String = "End Shift:\n\(endShift)\nDate/Time:\(sDate)\nRelieving:\(endShiftStructure.esRelieving)\nDisscussion:\(endShiftStructure.esDiscussion)\nPlatoon:\(endShiftStructure.esPlatoonTF) - \(endShiftStructure.esPlatoon)\nFire Station:\(endShiftStructure.esFireStationTF) - \(endShiftStructure.esFireStation)\nAssignment: \(endShiftStructure.esAssignmentTF) - \(endShiftStructure.esAssignment)\rApparatus: \(endShiftStructure.esApparatusTF) - \(endShiftStructure.esApparatus)\nResources: \(endShiftStructure.esResourcesCombine) - \(endShiftStructure.esResourcesTF)\nCrew:\(endShiftStructure.esCrewCombine) - \(endShiftStructure.esCrews)"
        fjuJournal.journalOverview = overview as NSObject
        
        fjuJournal.journalTempPlatoon = endShiftStructure.esPlatoonTF
        fjuJournal.journalTempApparatus = endShiftStructure.esApparatusTF
        fjuJournal.journalTempAssignment = endShiftStructure.esAssignmentTF
        fjuJournal.journalTempFireStation = endShiftStructure.esFireStationTF
        fjuJournal.journalFireStation = endShiftStructure.esFireStationTF
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
        
        fjuJournal.journalPrivate = true
        
        let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        fjuJournal.addToJournalTagDetails(fjuJournalTags)
        
        fju.platoonDefault = endShiftStructure.esPlatoonB
        fju.tempPlatoon = endShiftStructure.esPlatoonTF
        fju.assignmentDefault = endShiftStructure.esAssignmentB
        fju.tempAssignment = endShiftStructure.esAssignmentTF
        fju.tempFireStation = endShiftStructure.esFireStationTF
        if fju.fireStation == "" {
            fju.fireStation  = endShiftStructure.esFireStationTF
        }
        fju.tempApparatus = endShiftStructure.esApparatusTF
        fju.apparatusDefault = endShiftStructure.esApparatusB
        fju.tempResources = endShiftStructure.esResourcesCombine
        fju.defaultResources = endShiftStructure.esResources
        fju.defaultResourcesName = endShiftStructure.esResourcesName
        fju.fjpUserModDate = journalModDate
        fju.fjpUserBackedUp = false
        fjuJournal.fireJournalUserInfo = fju
        
        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            fjUserTime.endShiftStatus = endShiftStructure.esAMReliefDefaultT
            fjUserTime.enShiftRelievedBy = endShiftStructure.esRelieving
            fjUserTime.endShiftDiscussion = endShiftStructure.esDiscussion
            fjUserTime.userEndShiftTime = journalModDate
            fjUserTime.entryState = EntryState.update.rawValue
            fjUserTime.userTimeBackup = false
        }
        
        saveToCD()
    }
    
    private func saveStartShift() {
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDate()
        fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        fjuJournal.journalEntryType = "Station"
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fju.userGuid
        let journalTitle = "Start Shift \(sDate)"
        fjuJournal.journalHeader = journalTitle
        let overview:String = "Start Shift:\n\(startShiftStructure.ssAMReliefDefaultT)\nDate/Time:\(sDate)\nRelieving:\(startShiftStructure.ssRelieving)\nDisscussion:\(startShiftStructure.ssDiscussion)\nPlatoon:\(startShiftStructure.ssPlatoonTF) - \(startShiftStructure.ssPlatoon)\nFire Station:\(startShiftStructure.ssFireStationTF) - \(startShiftStructure.ssFireStation)\nAssignment: \(startShiftStructure.ssAssignmentTF) - \(startShiftStructure.ssAssignment)\rApparatus: \(startShiftStructure.ssApparatusTF) - \(startShiftStructure.ssApparatus)\nResources: \(startShiftStructure.ssResourcesCombine) - \(startShiftStructure.ssResourcesTF)\nCrew:\(startShiftStructure.ssCrewCombine) - \(startShiftStructure.ssCrews)"
        fjuJournal.journalOverview = overview as NSObject
        
        fjuJournal.journalTempPlatoon = startShiftStructure.ssPlatoonTF
        fjuJournal.journalTempApparatus = startShiftStructure.ssApparatusTF
        fjuJournal.journalTempAssignment = startShiftStructure.ssAssignmentTF
        fjuJournal.journalTempFireStation = startShiftStructure.ssFireStationTF
        fjuJournal.journalFireStation = startShiftStructure.ssFireStationTF
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
        
        fjuJournal.journalPrivate = true
        
        let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        fjuJournal.addToJournalTagDetails(fjuJournalTags)
        
        fju.platoonDefault = startShiftStructure.ssPlatoonB
        fju.tempPlatoon = startShiftStructure.ssPlatoonTF
        fju.assignmentDefault = startShiftStructure.ssAssignmentB
        fju.tempAssignment = startShiftStructure.ssAssignmentTF
        fju.tempFireStation = startShiftStructure.ssFireStationTF
        if fju.fireStation == "" {
            fju.fireStation  = startShiftStructure.ssFireStationTF
        }
        fju.tempApparatus = startShiftStructure.ssApparatusTF
        fju.apparatusDefault = startShiftStructure.ssApparatusB
        fju.tempResources = startShiftStructure.ssResourcesTF
        fju.defaultResources = startShiftStructure.ssResourcesTF
        fju.defaultResourcesName = startShiftStructure.ssResourcesName
        fju.crewDefault = startShiftStructure.ssCrewB
        if startShiftStructure.ssCrewB {
            fju.deafultCrewName = startShiftStructure.ssCrewsName
            fju.defaultCrew = startShiftStructure.ssCrewsTF
        } else {
            fju.crewOvertime = startShiftStructure.ssCrewsTF
            fju.crewOvertimeName = startShiftStructure.ssCrewsName
        }
        fju.fjpUserModDate = journalModDate
        fju.fjpUserBackedUp = false
        fjuJournal.fireJournalUserInfo = fju
        
        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            fjUserTime.startShiftStatus = startShiftStructure.ssAMReliefDefault
            fjUserTime.startShiftApparatus = startShiftStructure.ssApparatusTF
            fjUserTime.startShiftAssignment = startShiftStructure.ssAssignmentTF
            fjUserTime.startShiftFireStation = startShiftStructure.ssFireStationTF
            fjUserTime.startShiftPlatoon = startShiftStructure.ssPlatoonTF
            fjUserTime.startShiftResources = startShiftStructure.ssResourcesTF
            fjUserTime.startShiftCrew = startShiftStructure.ssCrewsTF
            fjUserTime.startShiftRelieving = startShiftStructure.ssRelieving
            fjUserTime.startShiftDiscussion = startShiftStructure.ssDiscussion
            fjUserTime.userStartShiftTime = journalModDate
            fjUserTime.entryState = EntryState.update.rawValue
            fjUserTime.userTimeBackup = false
        }
        
        saveToCD()
    }
    
    private func theUserTimeCount(entity: String, guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "userTimeGuid", guid)
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            if userFetched.isEmpty {
                
            } else {
                fjUserTime = userFetched.last!
            }
        } catch let error as NSError {
            print("ModalTVC line 1415 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func saveTheIncident() {
        let fjuIncident = Incident.init(entity: NSEntityDescription.entity(forEntityName: "Incident", in: context)!, insertInto: context)
        let incidentModDate = Date()
        let iGuidDate = GuidFormatter.init(date:incidentModDate)
        let iGuid:String = iGuidDate.formatGuid()
        fjuIncident.fjpIncGuidForReference = "02."+iGuid
        let jGuidDate = GuidFormatter.init(date:incidentModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuIncident.fjpJournalReference = "01."+jGuid
        fjuIncident.fjpUserReference = fju.userGuid
        
        let searchDate = FormattedDate.init(date:incidentModDate)
        let sDate:String = searchDate.formatTheDate()
        fjuIncident.incidentSearchDate = sDate
        fjuIncident.incidentDateSearch = sDate
        fjuIncident.incidentNumber = incidentStructure.incidentNumber
        fjuIncident.incidentType = incidentStructure.incidentEmergency
        fjuIncident.situationIncidentImage = incidentStructure.incidentType
        fjuIncident.incidentEntryTypeImageName = incidentStructure.incidentImageName
        
//        MARK: -LOCATION-
        /// incidentLocation archived with SecureCoding
        if incidentStructure.incidentLocation != nil {
            if let location = incidentStructure.incidentLocation {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    fjuIncident.incidentLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
            }
            fjuIncident.incidentStreetNumber = incidentStructure.incidentStreetNum
            fjuIncident.incidentStreetHyway = incidentStructure.incidentStreetName
            fjuIncident.incidentZipCode = incidentStructure.incidentZip
        }
        fjuIncident.incidentBackedUp = false
        fjuIncident.incidentNFIRSCompleted = false
        fjuIncident.incidentNFIRSDataComplete = false
        fjuIncident.incidentPhotoTaken = false
        fjuIncident.incidentCreationDate = incidentModDate
        fjuIncident.incidentModDate = incidentModDate
        fjuIncident.fjpIncidentDateSearch = incidentModDate
        
        let fjuIncidentAddress = IncidentAddress.init(entity: NSEntityDescription.entity(forEntityName: "IncidentAddress", in: context)!, insertInto: context)
        
        fjuIncidentAddress.streetHighway = incidentStructure.incidentStreetName
        fjuIncidentAddress.streetNumber = incidentStructure.incidentStreetNum
        fjuIncidentAddress.city = incidentStructure.incidentCity
        fjuIncidentAddress.incidentState = incidentStructure.incidentState
        fjuIncidentAddress.zip = incidentStructure.incidentZip
        fjuIncidentAddress.prefix = incidentStructure.incidentStreetPrefix
        fjuIncidentAddress.streetType = incidentStructure.incidentStreetType
        fjuIncidentAddress.incidentAddressInfo = fjuIncident
        
        let fjuIncidentLocal = IncidentLocal.init(entity: NSEntityDescription.entity(forEntityName: "IncidentLocal", in: context)!, insertInto: context)
        fjuIncidentLocal.incidentLocalType = incidentStructure.incidentLocalType
        fjuIncidentLocal.incidentLocalInfo = fjuIncident
        
        let fjuIncidentNFIRS = IncidentNFIRS.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRS", in: context)!, insertInto: context)
        fjuIncidentNFIRS.incidentTypeNumberNFRIS = incidentStructure.incidentNfirsIncidentTypeNumber
        fjuIncidentNFIRS.incidentTypeTextNFRIS = incidentStructure.incidentNfirsIncidentType
        fjuIncidentNFIRS.incidentFDID = fju.fdid ?? ""
        fjuIncidentNFIRS.fireStationState = fju.fireStationState ?? ""
        fjuIncidentNFIRS.incidentFireStation = fju.fireStation ?? ""
//        MARK: -STRING-
        fjuIncidentNFIRS.incidentLocation = incidentStructure.incidentLocationType
        fjuIncidentNFIRS.incidentNFIRSInfo = fjuIncident
        
        let fjuIncidentNotes = IncidentNotes.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNotes", in: context)!, insertInto: context)
        fjuIncidentNotes.incidentNote = ""
        fjuIncidentNotes.incidentSummaryNotes = "" as NSObject
        fjuIncidentNotes.incidentNotesInfo = fjuIncident
        
        let fjuIncidentTimer = IncidentTimer.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTimer", in: context)!, insertInto: context)
        fjuIncidentTimer.incidentAlarmCombinedDate = incidentStructure.incidentFullAlarmDateS
        fjuIncidentTimer.incidentAlarmDateTime = incidentStructure.incidentAlarmDate
        fjuIncidentTimer.incidentAlarmMonth = incidentStructure.incidentAlarmMM
        fjuIncidentTimer.incidentAlarmDay = incidentStructure.incidentAlarmdd
        fjuIncidentTimer.incidentAlarmYear = incidentStructure.incidentAlarmYYYY
        fjuIncidentTimer.incidentAlarmHours = incidentStructure.incidentAlarmHH
        fjuIncidentTimer.incidentAlarmMinutes = incidentStructure.incidentAlarmmm
        fjuIncidentTimer.incidentTimerInfo = fjuIncident
        
        let fjuUserCrews = UserCrews.init(entity: NSEntityDescription.entity(forEntityName: "UserCrews", in: context)!, insertInto: context)
        fjuUserCrews.userCrewsInfo = fjuIncident
        
        let fjuUserResourcesGroups = UserResourcesGroups.init(entity: NSEntityDescription.entity(forEntityName: "UserResourcesGroups", in: context)!, insertInto: context)
        fjuUserResourcesGroups.userResourcesGroupInfo = fjuIncident
        
        let fjuIncidentTags = IncidentTags.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTags", in: context)!, insertInto: context)
        fjuIncident.addToIncidentTagDetails(fjuIncidentTags)
        
        let fjuIncidentTeam = IncidentTeam.init(entity:NSEntityDescription.entity(forEntityName: "IncidentTeam", in: context)!, insertInto: context)
        fjuIncident.addToTeamMemberDetails(fjuIncidentTeam)
        
        let fjuIncidentResources = IncidentResources.init(entity:NSEntityDescription.entity(forEntityName: "IncidentResources", in: context)!, insertInto: context)
        fjuIncident.addToIncidentResourceDetails(fjuIncidentResources)
        
        let fjuActionsTaken = ActionsTaken.init(entity: NSEntityDescription.entity(forEntityName: "ActionsTaken", in: context)!, insertInto: context)
        fjuActionsTaken.actionsTakenInfo = fjuIncident
        
        let fjuIncidentNFIRSCompleteMods = IncidentNFIRSCompleteMods.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSCompleteMods", in: context)!, insertInto: context)
        fjuIncidentNFIRSCompleteMods.addToCompletedModuleInfo(fjuIncident)
        //        let completedMods = fjuIncident.mutableSetValue(forKey:"completedModulesDetails")
        //        completedMods.add(fjuIncidentNFIRSCompleteMods)
        
        let fjuIncidentNFIRSKSec = IncidentNFIRSKSec.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSKSec", in: context)!, insertInto: context)
        fjuIncidentNFIRSKSec.incidentNFIRSKSecInto = fjuIncident
        
        let fjuIncidentNFIRSRequiredModules = IncidentNFIRSRequiredModules.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSRequiredModules", in: context)!, insertInto: context)
        fjuIncidentNFIRSRequiredModules.addToRequiredModuleInfo(fjuIncident)
        //        let modules = fjuIncident.mutableSetValue(forKey: "requiredModulesDetails")
        //        modules.add(fjuIncidentNFIRSRequiredModules)
        
        let fjuIncidentNFIRSsecL = IncidentNFIRSsecL.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecL", in: context)!, insertInto: context)
        fjuIncidentNFIRSsecL.sectionLInfo = fjuIncident
        
        let fjuIncidentNFIRSsecM = IncidentNFIRSsecM.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecM", in: context)!, insertInto: context)
        fjuIncidentNFIRSsecM.sectionMInfo = fjuIncident
        
        let fjuIncidentPhotos = IncidentPhotos.init(entity: NSEntityDescription.entity(forEntityName: "IncidentPhotos", in: context)!, insertInto: context)
        let photos = fjuIncident.mutableSetValue(forKey: "incidentPhotoDetails")
        photos.add(fjuIncidentPhotos)
        
        
        
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        fjuJournal.fjpIncReference = "02."+iGuid
        fjuJournal.fjpUserReference = fju.userGuid
        fjuJournal.journalDateSearch = sDate
        fjuJournal.journalModDate = incidentModDate
        fjuJournal.journalCreationDate = incidentModDate
        fjuJournal.fjpJournalModifiedDate = incidentModDate
        fjuJournal.journalEntryType = fjuIncident.situationIncidentImage
        fjuJournal.journalEntryTypeImageName = "NOTJournal"
        let incidentNumber = fjuIncident.incidentNumber ?? ""
        fjuJournal.journalHeader = "Incident Entry #\(incidentNumber) \(sDate)"
        
        fjuIncident.incidentInfo = fjuJournal
        fjuIncident.fireJournalUserIncInfo = fju
        fjIncident = fjuIncident
        
        saveToCD()
        
    }
    //    MARK: -SAVE THE JOURNAL ENTRY
    private func saveTheJournal() {
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDate()
//        var address = ""
        fjuJournal.journalStreetNumber = journalStructure.journalStreetNum
        fjuJournal.journalStreetName = journalStructure.journalStreetName
        fjuJournal.journalCity = journalStructure.journalCity
        fjuJournal.journalState = journalStructure.journalState
        fjuJournal.journalZip = journalStructure.journalZip
        
//        MARK: -LOCATION-
        /// journalLocation archived with secureCoding
        if journalStructure.journalLocation != nil {
            if let location = journalStructure.journalLocation {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    fjuJournal.journalLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
            }
        }

        fjuJournal.journalHeader = journalStructure.journalTitle
        fjuJournal.journalEntryType = journalStructure.journalType
        
        switch myShift {
        case .journal:
            if journalStructure.journalType != "" {
                if journalStructure.journalType == "Station" {
                    journalStructure.journalTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                } else if journalStructure.journalType == "Community" {
                    journalStructure.journalTypeImageName = "ICONS_communityboard color"
                } else if journalStructure.journalType == "Members" {
                    journalStructure.journalTypeImageName = "ICONS_Membersboard color"
                } else if journalStructure.journalType == "Training" {
                    journalStructure.journalTypeImageName = "ICONS_training"
                } else {
                    journalStructure.journalTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                }
            } else {
                fjuJournal.journalEntryType = "Station"
                journalStructure.journalTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
            }
            fjuJournal.journalEntryTypeImageName = journalStructure.journalTypeImageName
        default: break
        }
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fju.userGuid ?? ""
        fjuJournal.journalOverview = journalStructure.journalOverview as NSObject
        fjuJournal.journalTempPlatoon = journalStructure.journalPlatoon
        fjuJournal.journalTempApparatus = journalStructure.journalApparatus
        fjuJournal.journalTempAssignment = journalStructure.journalAssignment
        fjuJournal.journalTempFireStation = journalStructure.journalFireStation
        fjuJournal.journalFireStation = journalStructure.journalFireStation
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
//        MARK: -LOCATION-
        /// journalLocation archived with secureCoding
        if journalStructure.journalLocation != nil {
            if let location = journalStructure.journalLocation {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    fjuJournal.journalLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
            }
        }
        
        fjuJournal.journalPrivate = journalStructure.journalPrivatePublic
        
        let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        fjuJournal.addToJournalTagDetails(fjuJournalTags)
        
        fjuJournal.fireJournalUserInfo = fju
        
        if userChanged {
            fju.platoonGuid = journalStructure.journalPlatoonGuid
            fju.tempPlatoon = journalStructure.journalPlatoon
            fju.assignmentGuid = journalStructure.journalAssignmentGuid
            fju.tempAssignment = journalStructure.journalAssignment
            fju.apparatusGuid = journalStructure.journalApparatusGuid
            fju.tempApparatus = journalStructure.journalApparatus
        }
        
        saveToCD()
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Modal TVC merge that"])
            }
            switch myShift {
            case .journal,.personal:
                let entity = "Journal"
                let attribute = "journalDateSearch"
                let sort = "journalCreationDate"
                getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkCKNewJournalCreated),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
                delegate?.journalSaved(id: objectID, shift: myShift)
            case .incidents:
                let entity = "Incident"
                let attribute = "incidentSearchDate"
                let sort = "incidentCreationDate"
                getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkCKNewIncidentCreated),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
                delegate?.incidentSave(id: objectID, shift: myShift)
            case .startShift:
                let entity = "UserTime"
                let attribute = "userTimeGuid"
                let sort = "userStartShiftTime"
                getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkSTARTSHIFTFORDASH),
                            object: nil,
                            userInfo: ["startShift":self.startShiftStructure!])
                }
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
//                delegate?.startSaveBTapped(shift: myShift, startShift: startShiftStructure)
            case .updateShift:
                let entity = "UserTime"
                let attribute = "userTimeGuid"
                let sort = "userStartShiftTime"
                getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
//                delegate?.updateBTapped(shift: myShift, updateShift: updateShiftStructure)
            case .endShift:
                let entity = "UserTime"
                let attribute = "userTimeGuid"
                let sort = "userStartShiftTime"
                getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
//                delegate?.endSaveBTapped(shift: myShift, endShift: endShiftStructure)
            default:
                print("no sir")
            }
        } catch let error as NSError {
            print("ModalTVC line 1679 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func getTheLastSaved(entity:String,attribute:String,sort:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        switch myShift {
        case .journal, .incidents:
            predicate = NSPredicate(format: "%K != %@", attribute, "")
        case .personal:
            predicate =  NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value: false))
        case .startShift, .endShift:
            predicate =  NSPredicate(format: "%K != %@",attribute, "")
        default:
            print("No search")
        }
        let sectionSortDescriptor = NSSortDescriptor(key: sort, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            switch myShift {
            case .journal,.personal:
                self.fetched = try context.fetch(fetchRequest) as! [Journal]
                let journal = self.fetched.last as! Journal
                self.objectID = journal.objectID
            case .incidents:
                self.fetched = try context.fetch(fetchRequest) as! [Incident]
                let incident = self.fetched.last as! Incident
                self.objectID = incident.objectID
            case .startShift, .endShift:
                self.fetched = try context.fetch(fetchRequest) as! [UserTime]
                let userTime = self.fetched.last as! UserTime
                self.objectID = userTime.objectID
            default:
                print("nothing")
            }
        } catch let error as NSError {
            print("ModalTVC line 1721 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -dismissUpdateSaveDelegate
    func theDismissedTapped() {
        print("theDismissed")
        updateTapped = false
        delegate?.dismissTapped(shift: myShift)
    }
    
    func theUpdateTapped() {
        updateTapped = true
        tableView.reloadData()
        //        delegate?.updateBTapped(shift: myShift)
    }
    
    func theSaveTapped() {
        print("theSaved")
        switch myShift {
        case .startShift:
            //            delegate?.startSaveBTapped(shift: myShift, startShift: startShiftStructure)
            saveStartShift()
            print("this shouldn't be happening")
        case .endShift:
            if updateTapped {
                saveUpdateEndShift()
            } else {
                saveEndShift()
            }
        default:
            delegate?.saveBTapped(shift: myShift)
        }
        updateTapped = false
    }
    //    MARK: -delegate methods for startShiftOvertime StartShiftOvertimeSwitchDelegate
    func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems) {
        switch myShift {
        case .startShift:
            startShiftStructure.ssAMReliefDefaultT = type
            startShiftStructure.ssAMReliefDefault = startOrEnd
        case .updateShift:
            updateShiftStructure.upsAMReliefDefault = type
            updateShiftStructure.upsAMReliefDefaultT = startOrEnd
        case .endShift:
            endShiftStructure.esAMReliefDefault = type
            endShiftStructure.esAMReliefDefaultT = startOrEnd
        case .journal,.personal:
            journalStructure.journalPrivatePublicText = type
            journalStructure.journalPrivatePublic = startOrEnd
        case .incidents:
            incidentStructure.incidentEmergency = type
            incidentStructure.incidentEmergencyYesNo = startOrEnd
        default:
            print("no bool")
        }
        tableView.reloadData()
        //        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    private func getTheUser() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let count = try context.count(for:fetchRequest)
            if count != 0 {
                do {
                    fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
                    fju = fetched.last as? FireJournalUser
                    switch myShift {
                    case .journal,.personal:
                        journalStructure.journalUser = fju.userName ?? ""
                        journalStructure.journalFireStation = fju.fireStation ?? ""
                        journalStructure.journalPlatoon = fju.tempPlatoon ?? ""
                        journalStructure.journalAssignment = fju.tempAssignment ?? ""
                        journalStructure.journalApparatus = fju.tempApparatus ?? ""
                    case .incidents:
                        incidentStructure.incidentUser = fju.userName ?? ""
                        incidentStructure.incidentFireStation = fju.fireStation ?? ""
                        incidentStructure.incidentPlatoon = fju.tempPlatoon ?? ""
                        incidentStructure.incidentAssignment = fju.tempAssignment ?? ""
                        incidentStructure.incidentApparatus = fju.tempApparatus ?? ""
                    default:
                        print("no")
                    }
                } catch let error as NSError {
                    print("ModalTVC line 1806 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("ModalTVC line 1806 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func titlesAndText(type:MenuItems) {
        myShift = type
        switch myShift {
        case .journal:
            self.title = "Journal"
            modalTitle = "New Journal Entry"
            modalInstructions = "Create a new journal entry for every item you would normally record in your fire station operations. If you wish to change the entry date or time, tap on the clock."
            getTheUser()
            var address = ""
            if let streetNum = fju.fireStationStreetNumber {
                journalStructure.journalStreetNum = streetNum
                address = streetNum
            }
            if let streetName = fju.fireStationStreetName {
                journalStructure.journalStreetName = streetName
                address = "\(address) \(streetName)"
            }
            if let city = fju.fireStationCity {
                journalStructure.journalCity = city
                address = "\(address) \(city)"
            }
            if let state = fju.fireStationState {
                journalStructure.journalState = state
                address = "\(address) \(state)"
            }
            if let zip = fju.fireStationZipCode {
                journalStructure.journalZip = zip
                address = "\(address) \(zip)"
            }
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address) {
                placemarks, error in
                let placemark = placemarks?.first
                if let location = placemark?.location {
                    self.journalStructure.journalLocation = location
                }
            }
        case .personal:
            self.title = "Personal Journal"
            modalTitle = "Personal Journal Entry"
            modalInstructions = "Create a topic or title and manage a personal journal. These entries are separate from the main journal and are private. Create an overview here, and then save the topic. Once saved, you may enter your thoughts, either as a single entry, or as multiple entries on the same topic. Use the time stamp to separate each entry. "
            getTheUser()
        case .incidents:
            self.title = "Incident"
            modalTitle = "New Incident"
            modalInstructions = "Start a new incident by indicating if this response is emergency or non-emergency. Then, tap on the clock to indicate the alarm time. Tap on the globe to locate an address on a map, or tap on the pin to select the location where you’re standing. You have the option of adding both your department’s incident type as well as the incident as categorized by NFIRS."
            getTheUser()
        case .forms:
            self.title = "Forms"
            modalTitle = "Choose a Form"
            modalInstructions = "Select the appropriate form for use when involved in campaign incidents, or when supporting the community. Additional functionality, including export in NIMS format is available when you opt to become a member."
        case .startShift:
            self.title = "Start Shift"
            modalTitle = "Start Shift"
            modalInstructions = "When you arrive for your scheduled shift, you should start your shift by tapping on the START SHIFT button (as you’ve done). This will start an internal clock that tracks your time at work. You may also make notes relative to the member you’re relieving, and any discussion notes the two of you may have had prior to you taking over."
            getTheUser()
        case .updateShift:
            self.title = "Update Shift"
            modalTitle = "Update Shift"
            modalInstructions = "When you make relief during the middle of a shift, or if you move up to a different fire station, make changes here."
            getTheUser()
        case .endShift:
            self.title = "End Shift"
            modalTitle = "End Shift"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
            getTheUser()
        case .camera:
            self.title = "Csmera"
            modalTitle = "Camera"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
        case .incidentSearch:
            self.title = "Incident Search"
            modalTitle = "Incident Search"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
        case .nfirsBasic1Search:
            self.title = "NFIRS Basic 1 Search"
            modalTitle = "NFIRS Basic 1 Search"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
        case .alarmSearch:
            self.title = "Alarm Search"
            modalTitle = "Alarm Search"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
        case .ics214Search:
            self.title = "ICS 214 Search"
            modalTitle = "ICS 214 Search"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
        case .shiftCalendar:
            self.title = "Shift Calendar"
            modalTitle = "Shift Calendar"
            modalInstructions = "When it’s time to end your shift, simply tap on the END SHIFT button. In addition, note the time, as not all shifts will end at the same hour. You may also list your relief, and any discussion points you shared prior to your relief taking charge."
        default:
            self.title = "Wrong"
        }
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "startShiftOvertimeSwitchCell", bundle: nil), forCellReuseIdentifier: "startShiftOvertimeSwitchCell")
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UINib(nibName: "dismissSaveCell", bundle: nil), forCellReuseIdentifier: "dismissSaveCell")
        tableView.register(UINib(nibName: "dismissUpdateSaveCell", bundle: nil), forCellReuseIdentifier: "dismissUpdateSaveCell")
        tableView.register(UINib(nibName: "AddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "AddressFieldsButtonsCell")
        tableView.register(UINib(nibName: "LabelTextViewDirectionalCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewDirectionalCell")
        tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
        tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "LabelTextViewCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
        tableView.register(UINib(nibName: "LabelAnswerSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelAnswerSwitchCell")
        tableView.register(UINib(nibName: "LabelTextViewSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewSwitchCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "LabelTextFieldWithDirectionCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldWithDirectionCell")
        tableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")
        tableView.register(UINib(nibName: "IncidentTextViewWithDirectionalCell", bundle: nil), forCellReuseIdentifier: "IncidentTextViewWithDirectionalCell")
        tableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        tableView.register(UINib(nibName: "ImageTextFieldTextViewCell", bundle: nil), forCellReuseIdentifier: "ImageTextFieldTextViewCell")
        tableView.register(UINib(nibName: "LabelDirectionalTVSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelDirectionalTVSwitchCell")
        tableView.register(UINib(nibName: "LabelTextFieldDirectionalSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldDirectionalSwitchCell")
        tableView.register(UINib(nibName: "LabelNoDescripAnswerSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelNoDescripAnswerSwitchCell")
        tableView.register(UINib(nibName: "LabelDateTimeSearchSwitchButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeSearchSwitchButtonCell")
        tableView.register(UINib(nibName: "AddressSearchButtonsCell", bundle: nil), forCellReuseIdentifier: "AddressSearchButtonsCell")
        tableView.register(UINib(nibName: "LabelNumberFieldCell", bundle: nil), forCellReuseIdentifier: "LabelNumberFieldCell")
        tableView.register(UINib(nibName: "JournalSegmentCell", bundle: nil), forCellReuseIdentifier: "JournalSegmentCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ModalDataShow" {
            let detailTV:ModalDataTVC = segue.destination as! ModalDataTVC
            switch myShift {
            case .incidents:
                switch incidentType{
                case .nfirsIncidentType:
                    print("nfirs here")
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = incidentType
                    detailTV.headerTitle = "NFIRS Basic 1"
                    detailTV.context = context
                    detailTV.entity = "NFIRSIncidentType"
                    detailTV.attribute = "incidentTypeName"
                    print("here is the headerText \(detailTV.headerTitle)")
                case .localIncidentType:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = incidentType
                    detailTV.headerTitle = "Local Incident Type"
                    detailTV.context = context
                    detailTV.entity = "UserLocalIncidentType"
                    detailTV.attribute = "localIncidentTypeName"
                    print("here is the headerText \(detailTV.headerTitle)")
                case .locationType:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = incidentType
                    detailTV.headerTitle = "Location Type"
                    detailTV.context = context
                    detailTV.entity = "NFIRSLocation"
                    detailTV.attribute = "location"
                    print("here is the headerText \(detailTV.headerTitle)")
                case .streetType:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = incidentType
                    detailTV.headerTitle = "Street Type"
                    detailTV.context = context
                    detailTV.entity = "NFIRSStreetType"
                    detailTV.attribute = "streetType"
                    print("here is the headerText \(detailTV.headerTitle)")
                case .streetPrefix:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = incidentType
                    detailTV.headerTitle = "Street Prefix"
                    detailTV.context = context
                    detailTV.entity = "NFIRSStreetPrefix"
                    detailTV.attribute = "streetPrefix"
                default:
                    print("all other incident types")
                }
            case .journal,.personal:
                switch incidentType {
                case .platoon:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = .platoon
                    detailTV.headerTitle = "Choose Your Platoon"
                    detailTV.context = context
                    detailTV.entity = "UserPlatoon"
                    detailTV.attribute = "platoon"
                    incidentType = .platoon
                case .assignment:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = .assignment
                    detailTV.headerTitle = "Choose Your Assignment"
                    detailTV.context = context
                    detailTV.entity = "UserAssignments"
                    detailTV.attribute = "assignment"
                case .apparatus:
                    detailTV.delegate = self
                    detailTV.myShift = myShift
                    detailTV.incidentType = .apparatus
                    detailTV.headerTitle = "Choose Your Apparatus"
                    detailTV.context = context
                    detailTV.entity = "UserApparatusType"
                    detailTV.attribute = "apparatus"
                default:
                    print("no")
                }
                switch journalType{
                case .crew:
                    print("crew here")
                    detailTV.delegate = self
                    detailTV.journalType = journalType
                    detailTV.headerTitle = "Journal Crew"
                default:
                    print("all other journal types")
                }
            default:
                print("no shift")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        roundViews()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let dateFrom = dateFormatter.string(from: date)
        startShift?.startTime = dateFrom
        tableSize = TableSize.init(myShift: myShift)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        registerCells()
        print("here is myshift \(myShift)")
        switch myShift {
        case .incidents:
            incidentStructure = IncidentData.init()
        case .incidentSearch:
            incidentStructure = IncidentData.init()
        case .journal,.personal:
            journalStructure = JournalData.init()
            switch myShift {
            case .personal:
                personalJournalEntry = true
                journalStructure.journalPrivatePublic = false
                journalStructure.journalPrivatePublicText = "Private"
                journalStructure.journalType = "Station"
            default:
                print("not private")
            }
        case .nfirsBasic1Search:
            incidentStructure = IncidentData.init()
        case .startShift:
            startShiftStructure = StartShiftData.init()
            shift = .start
            theUser = UserEntryInfo.init(user:"")
            getTheUser()
            
            startShiftStructure.ssPlatoonB = true
            startShiftStructure.ssPlatoon = "Default"
            if let platoon = fju.platoon {
                startShiftStructure.ssPlatoonTF = platoon
            }
            
            startShiftStructure.ssFireStationB = true
            startShiftStructure.ssFireStation = "Default"
            if let fireStation = fju.fireStation {
                startShiftStructure.ssFireStationTF = fireStation
            }
            
            startShiftStructure.ssApparatusB = true
            startShiftStructure.ssApparatus = "Default"
            if let apparatus = fju.initialApparatus {
                startShiftStructure.ssApparatusTF = apparatus
            }
            
            startShiftStructure.ssAssignmentB = true
            startShiftStructure.ssAssignment = "Default"
            if let assignment = fju.initialAssignment {
                startShiftStructure.ssAssignmentTF = assignment
            }
            
            startShiftStructure.ssResourcesB = true
            startShiftStructure.ssResources = "Front Line"
            if let resources = fju.defaultResources {
                    startShiftStructure.ssResourcesTF = resources
            }
            
            startShiftStructure.ssCrewB = true
            startShiftStructure.ssCrews = "AM Relief"
            if let crew = fju.defaultCrew {
                    startShiftStructure.ssCrewsTF = crew
            }
            startShiftStructure.ssAMReliefDefault = fju.shiftStatusAMorOver
            if startShiftStructure.ssAMReliefDefault {
                startShiftStructure.ssAMReliefDefaultT = "AM Relief"
            } else {
                startShiftStructure.ssAMReliefDefaultT = "Overtime"
            }
        case .updateShift:
            updateShiftStructure = UpdateShiftData.init()
            shift = .update
            theUser = UserEntryInfo.init(user:"")
            getTheUser()
            updateShiftStructure.upsPlatoonTF = fju.tempPlatoon ?? ""
            updateShiftStructure.upsPlatoonB = fju.platoonDefault
            if fju.platoonDefault {
                updateShiftStructure.upsPlatoon = "Default"
            } else {
                updateShiftStructure.upsPlatoon = "Temp"
            }
            updateShiftStructure.upsFireStationTF = fju.tempFireStation ?? ""
            updateShiftStructure.upsApparatusTF = fju.tempApparatus ?? ""
            updateShiftStructure.upsApparatusB = fju.apparatusDefault
            if fju.apparatusDefault {
                updateShiftStructure.upsApparatus = "Default"
            } else {
                updateShiftStructure.upsApparatus = "Temp"
            }
            updateShiftStructure.upsAssignmentTF = fju.tempAssignment ?? ""
            updateShiftStructure.upsAssignmentB = fju.assignmentDefault
            if fju.assignmentDefault {
                updateShiftStructure.upsAssignment = "Default"
            } else {
                updateShiftStructure.upsAssignment = "Overtime"
            }
            updateShiftStructure.upsResourcesCombine = fju.tempResources ?? ""
            updateShiftStructure.upsResources = fju.defaultResources ?? ""
            updateShiftStructure.upsResourcesName = fju.defaultResourcesName ?? ""
            updateShiftStructure.upsResourcesB = fju.resourcesDefault
            if fju.resourcesDefault {
                updateShiftStructure.upsResourcesTF = "Front Line"
            } else {
                updateShiftStructure.upsResourcesTF = "Reserve"
            }
            updateShiftStructure.upsCrewCombine = fju.defaultCrew ?? ""
            updateShiftStructure.upsCrewB = fju.crewDefault
            if fju.crewDefault {
                updateShiftStructure.upsCrews = "AM Relief"
            } else {
                updateShiftStructure.upsCrews = "Overtime"
            }
            updateShiftStructure.upsAMReliefDefaultT = fju.shiftStatusAMorOver
        case .endShift:
            endShiftStructure = EndShiftData.init()
            shift = .end
            theUser = UserEntryInfo.init(user:"")
            getTheUser()
            endShiftStructure.esPlatoonTF = fju.tempPlatoon ?? ""
            endShiftStructure.esPlatoonB = fju.platoonDefault
            if fju.platoonDefault {
                endShiftStructure.esPlatoon = "Default"
            } else {
                endShiftStructure.esPlatoon = "Temp"
            }
            endShiftStructure.esFireStationTF = fju.tempFireStation ?? ""
            endShiftStructure.esApparatusTF = fju.tempApparatus ?? ""
            endShiftStructure.esApparatusB = fju.apparatusDefault
            if fju.apparatusDefault {
                endShiftStructure.esApparatus = "Default"
            } else {
                endShiftStructure.esApparatus = "Temp"
            }
            endShiftStructure.esAssignmentTF = fju.tempAssignment ?? ""
            endShiftStructure.esAssignmentB = fju.assignmentDefault
            if fju.assignmentDefault {
                endShiftStructure.esAssignment = "Default"
            } else {
                endShiftStructure.esAssignment = "Overtime"
            }
            endShiftStructure.esResourcesCombine = fju.tempResources ?? ""
            endShiftStructure.esResources = fju.defaultResources ?? ""
            endShiftStructure.esResourcesName = fju.defaultResourcesName ?? ""
            endShiftStructure.esResourcesB = fju.resourcesDefault
            if fju.resourcesDefault {
                endShiftStructure.esResourcesTF = "Front Line"
            } else {
                endShiftStructure.esResourcesTF = "Reserve"
            }
            endShiftStructure.esCrewCombine = fju.defaultCrew ?? ""
            endShiftStructure.esCrewB = fju.crewDefault
            if fju.crewDefault {
                endShiftStructure.esCrews = "AM Relief"
            } else {
                endShiftStructure.esCrews = "Overtime"
            }
            endShiftStructure.esAMReliefDefaultT = fju.shiftStatusAMorOver
        case .alarmSearch:
            alarmStructure = AlarmData.init()
        case .ics214Search:
            ics214Structure = ICS214Data.init()
        default:
            print("none")
        }
        titlesAndText(type: myShift)
    }
    
    
    func fetchTheUserTime(guid: String)->UserTime {
        var uTime = UserTime.init(context: context)
        let entity = "UserTime"
        let attribute = "userTimeGuid"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K = %@",attribute,guid)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try context.fetch(fetchRequest) as! [UserTime]
            if !fetched.isEmpty {
                uTime = fetched.last!
            }
        } catch let error as NSError {
            print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
        }
        return uTime
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        switch myShift {
        case .journal:
            headerV.modalHTitleL.text = ""
            let color = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1.0)
            headerV.contentView.backgroundColor = color
        case .personal:
            headerV.modalHTitleL.text = "New Personal Entry"
            let color = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1.0)
            headerV.contentView.backgroundColor = color
        case .incidents:
            headerV.modalHTitleL.text = ""
            let color = ButtonsForFJ092018.fillColor38
            headerV.contentView.backgroundColor = color
        case .endShift:
            headerV.modalHTitleL.text = "End Shift"
            let color = ButtonsForFJ092018.fillColor38
            headerV.contentView.backgroundColor = color
        case .startShift:
            headerV.modalHTitleL.text = "Start Shift"
            let color = UIColor(red: 0.130, green: 0.534, blue: 0.243, alpha: 1.000)
            headerV.contentView.backgroundColor = color
        case .updateShift:
            headerV.modalHTitleL.text = "Update Shift"
            let color = UIColor(red: 0.957, green: 0.518, blue: 0.159, alpha: 1.000)
            headerV.contentView.backgroundColor = color
        case .forms:
            headerV.modalHTitleL.text = ""
            let color = ButtonsForFJ092018.gradientForBoxColor2
            headerV.contentView.backgroundColor = color
            headerV.modalHSaveB.isHidden = true
            headerV.modalHSaveB.alpha = 0.0
        default: break
        }
        headerV.myShift = myShift
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if Device.IS_IPHONE {
            return 0
        } else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        footerView.backgroundColor = UIColor.white
        footerView.alpha = 0.0
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch myShift {
        case .incidents:
            return 14
        case .journal:
            return 13
        case .personal:
            return 8
        case .forms:
            if Device.IS_IPHONE {
                return 3
            } else {
                return 4
            }
        case .nfirsBasic1Search:
            return 14
        case .startShift:
            return 13
        case .endShift:
            return 7
        case .updateShift:
            return 8
        case .incidentSearch:
            return 14
        case .alarmSearch:
            return 14
        case .ics214Search:
            return 14
        default:
            return 3
        }
    }
    
    
    /// Mark: -tableView heightForRowAt
    /// Using TableSize class to build the size for each cell for each type of MenuItems
    ///
    /// - Parameters:
    ///   - tableView: self.tableview
    ///   - indexPath: the indexPath for each cell
    /// - Returns: CGFloat
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableSize.cellSizesForModal(myShift: myShift, indexPath: indexPath, showMap: showMap, showPicker: showPicker, updateTapped: updateTapped)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.modalTitleL.text = modalTitle
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.modalInstructions.text = modalInstructions
            return cell
        case 2:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.delegate = self
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = incidentStructure.incidentEmergencyYesNo
                cell.myShift = myShift
                cell.amOrOvertimeL.text = incidentStructure.incidentEmergency
                cell.amOrOvertimeL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                return cell
            case .journal,.personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.delegate = self
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = journalStructure.journalPrivatePublic
                if personalJournalEntry {
                    cell.startOrEndB = false
                    cell.amOrOvertimeSwitch.setOn(cell.startOrEndB,animated:true)
                    cell.amOrOvertimeSwitch.isHidden = true
                    cell.amOrOvertimeSwitch.alpha = 0.0
                    cell.amOrOvertimeL.text = "Private"
                } else {
                    cell.startOrEndB = true
                    cell.amOrOvertimeSwitch.setOn(cell.startOrEndB,animated:true)
                    cell.amOrOvertimeSwitch.isHidden = true
                    cell.amOrOvertimeSwitch.alpha = 0.0
                    cell.amOrOvertimeL.text = "Public"
                    journalStructure.journalPrivatePublicText = "Public"
                }
                cell.myShift = myShift
                cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                return cell
            case .forms:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
                cell.delegate = self
                let image = UIImage(named: "100515IconSet_092016_ICS 214 Form")
                cell.iconIV.image = image
                let bImage = UIImage(named: "ics214Gradient")
                cell.newFormB.setImage(bImage, for: .normal)
                cell.myShift = .ics214
                cell.subjectL.text = "ICS-214 Activity Log"
                cell.descriptionTV.text = "Use the ICS-214 to record your activities during any operational period in which you or your crew are on scene. Record activities such as resources, assignment, date, time, and what took place. Typically, and ICS-214 is used for each operational period. You may create a single form, or a master form and subsequent follow up forms (for multiple operational periods within a single extended incident)."
                return cell
                //                MARK: NFIRS FORM COPY
                //                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
                //                cell.delegate = self
                //                let image = UIImage(named: "100515IconSet_092016_NFIRSBasic1")
                //                cell.iconIV.image = image
                //                cell.subjectL.text = "NFIRS Basic 1"
                //                cell.myShift = .nfirs
                //                cell.descriptionTV.text = "The NFIRS-1 Basic Form is the most commonly used form following an emergency incident. Designed by the U.S. Fire Administration (USFA), this form should be used following every incident, regardless of type. Data may be shared, or, using Fire Journal Cloud (subscription required), you may create a PDF file that matches the Government NFIRS-1 form."
            //                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.delegate = self
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = true
                cell.myShift = myShift
                cell.amOrOvertimeL.text = "Completed"
                cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
                cell.delegate = self
                cell.subjectL.text = "Incident Type"
                cell.myShift = .incidents
                cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
                cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
                cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
                if incidentStructure.incidentType == "" {
                    incidentStructure.incidentType = "Fire"
                }
                switch segmentType {
                case .fire:
                    cell.typeSegment.selectedSegmentIndex = 0
                case .ems:
                    cell.typeSegment.selectedSegmentIndex = 1
                case .rescue:
                    cell.typeSegment.selectedSegmentIndex = 2
                default:
                    cell.typeSegment.selectedSegmentIndex = 0
                }
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.amOrOvertimeL.text = startShiftStructure.ssAMReliefDefaultT
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = startShiftStructure.ssAMReliefDefault
                cell.myShift = myShift
                cell.delegate = self
                return cell
            case .updateShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.amOrOvertimeL.text = updateShiftStructure.upsAMReliefDefault
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = updateShiftStructure.upsAMReliefDefaultT
                cell.myShift = myShift
                cell.delegate = self
                return cell
            case .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.amOrOvertimeL.text = endShiftStructure.esAMReliefDefault
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = endShiftStructure.esAMReliefDefaultT
                cell.myShift = myShift
                cell.delegate = self
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.delegate = self
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = true
                cell.myShift = myShift
                cell.amOrOvertimeL.text = "Completed"
                cell.amOrOvertimeL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
                cell.delegate = self
                cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.amOrOvertimeSwitch.layer.cornerRadius = 16
                cell.startOrEndB = true
                cell.myShift = myShift
                cell.amOrOvertimeL.text = "Completed"
                cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 3:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "Incident Number"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                if incidentStructure.incidentNumber != "" {
                    cell.descriptionTF.text = incidentStructure.incidentNumber
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Incident Number"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .incidentNumber
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Campaign"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Wilson",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .incidentNumber
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Incident Name"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45)])
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .incidentNumber
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "Topic/Title"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalTitle != "" {
                    cell.descriptionTF.text = journalStructure.journalTitle
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Roll Call",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                return cell
            case .personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "Topic/Title"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalTitle != "" {
                    cell.descriptionTF.text = journalStructure.journalTitle
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Reflection",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
                cell.delegate = self
                cell.type = IncidentTypes.fire
                cell.dateTimeTV.text = startShift?.startTime
                cell.dateTimeL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece")
                cell.dateTimeB.setImage(image, for: .normal)
                switch myShift {
                case .incidents:
                    cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
                default:
                    cell.dateTimeTV.textColor = UIColor.black
                }
                return cell
            case .forms:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
                cell.delegate = self
                let image = UIImage(named: "100515IconSet_092016_redCross")
                cell.iconIV.image = image
                cell.myShift = .arcForm
                let bImage = UIImage(named: "CRRGradient")
                cell.newFormB.setImage(bImage, for: .normal)
                cell.subjectL.text = "CRR Smoke Alarm Inspection Form"
                cell.descriptionTV.text = "Use the Community Risk Reduction (CRR) Smoke Alarm Inspection Form when performing home fire safety inspections, including the installation of smoke alarms. You will have the option of creating a single form - or a campaign when, for example, conducting a neighborhood smoke alarm canvassing operation. This form conforms to that used by the nationally recognized fire safety organizations."
                return cell
            case .startShift,.updateShift, .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
                cell.delegate = self
                cell.type = IncidentTypes.fire
                cell.dateTimeTV.text = startShift?.startTime
                cell.dateTimeL.text = "Date/Time"
                switch myShift {
                case .startShift:
                    let image = UIImage(named: "ICONS_TimePiece green")
                    cell.dateTimeB.setImage(image, for: .normal)
                case .updateShift:
                    let image = UIImage(named: "ICONS_TimePiece orange")
                    cell.dateTimeB.setImage(image, for: .normal)
                case .endShift:
                    let image = UIImage(named: "ICONS_TimePiece red")
                    cell.dateTimeB.setImage(image, for: .normal)
                default:
                    cell.dateTimeTV.textColor = UIColor.black
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 4:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
                cell.delegate = self
                cell.type = IncidentTypes.fire
                cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                if incidentStructure.incidentFullAlarmDateS != "" {
                    cell.dateTimeTV.text = incidentStructure.incidentFullAlarmDateS
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                    let date = Date()
                    let incidentDate = dateFormatter.string(from: date)
                    incidentStructure.incidentFullAlarmDateS = incidentDate
                    incidentStructure.incidentDate = date
                    incidentStructure.incidentAlarmDate = date
                    let month = MonthFormat.init(date: date)
                    incidentStructure.incidentAlarmMM = month.monthForDate()
                    let day = DayFormat.init(date: date)
                    incidentStructure.incidentAlarmdd = day.dayForDate()
                    let year = YearFormat.init(date: date)
                    incidentStructure.incidentAlarmYYYY = year.yearForDate()
                    let hour = HourFormat.init(date: date)
                    incidentStructure.incidentAlarmHH = hour.hourForDate()
                    let minutes = MinuteFormat.init(date: date)
                    incidentStructure.incidentAlarmmm = minutes.minuteForDate()
                    cell.dateTimeTV.attributedPlaceholder = NSAttributedString(string: incidentStructure.incidentFullAlarmDateS,attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
//                    cell.dateTimeTV.text = incidentStructure.incidentFullAlarmDateS
                }
                cell.dateTimeL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece red")
                cell.dateTimeB.setImage(image, for: .normal)
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
                cell.delegate = self
                cell.descriptionTF.text = startShift?.startTime
                cell.subjectL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece red")
                cell.clockB.setImage(image, for: .normal)
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .dateTime
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Local Partner"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Red Cross",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .incidentNumber
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Campaign"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Freemont",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45)])
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .incidentNumber
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalSegmentCell", for: indexPath) as! JournalSegmentCell
                cell.delegate = self
                cell.subjectL.text = "Type"
                cell.myShift = .journal
                cell.typeSegment.setTitle("Station", forSegmentAt: 0)
                cell.typeSegment.setTitle("Community", forSegmentAt: 1)
                cell.typeSegment.setTitle("Members", forSegmentAt: 2)
                cell.typeSegment.setTitle("Training", forSegmentAt: 3)
                cell.typeSegment.tintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                
                switch segmentType {
                case .station:
                    cell.typeSegment.selectedSegmentIndex = 0
                case .community:
                    cell.typeSegment.selectedSegmentIndex = 1
                case .members:
                    cell.typeSegment.selectedSegmentIndex = 2
                case .training:
                    cell.typeSegment.selectedSegmentIndex = 3
                default:
                    cell.typeSegment.selectedSegmentIndex = 0
                }
                
                return cell
            case .personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
                cell.delegate = self
                if journalStructure.journalCreationDate == "" {
                    journalStructure.journalCreationDate = journalTimeChosenDate(date:Date(), myShift: myShift)
                }
                cell.dateTimeTV.text = journalStructure.journalCreationDate
                cell.dateTimeL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece")
                cell.dateTimeB.setImage(image, for: .normal)
                cell.type = IncidentTypes.personal
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                return cell
                //                MARK: RED CROSS FORM HERE
                //            case .forms:
                //                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTextFieldTextViewCell", for: indexPath) as! ImageTextFieldTextViewCell
                //                cell.delegate = self
                //                let image = UIImage(named: "100515IconSet_092016_redCross")
                //                cell.iconIV.image = image
                //                cell.myShift = .arcForm
                //                cell.subjectL.text = "ARC Smoke Alarm Form"
                //                cell.descriptionTV.text = "This form is to be used when inspecting a living space for working smoke alarms. You may use a single form, or create a campaign (such as when inspecting an entire street). Data may be shared, or, using Fire Journal Cloud (subscription required), you may create a PDF file that matches that used by the American Red Cross."
            //                return cell
            case .startShift,.updateShift, .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 5:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                let incidentType:IncidentTypes = .alarm
                cell.delegate2 = self
                cell.incidentType = incidentType
                
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNoDescripAnswerSwitchCell", for: indexPath) as! LabelNoDescripAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Effort"
                cell.descriptionTF.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "FEMA",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45)])
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .incidentNumber
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
                cell.delegate = self
                cell.descriptionTF.text = startShift?.startTime
                cell.subjectL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece red")
                cell.clockB.setImage(image, for: .normal)
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .dateTime
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
                cell.delegate = self
                if journalStructure.journalCreationDate == "" {
                    journalStructure.journalCreationDate = journalTimeChosenDate(date:Date(), myShift: myShift)
                }
                cell.dateTimeTV.text = journalStructure.journalCreationDate
                cell.dateTimeL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece")
                cell.dateTimeB.setImage(image, for: .normal)
                cell.type = IncidentTypes.journal
                switch myShift {
                case .journal:
                    cell.dateTimeTV.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)
                default:
                    cell.dateTimeTV.textColor = UIColor.black
                }
                return cell
            case .personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "Incident Number"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "14",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "Relieving"
                cell.descriptionTF.text = startShiftStructure.ssRelieving
                return cell
            case .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.descriptionTF.text = endShiftStructure.esRelieving
                cell.subjectL.text = "Relieved By"
                return cell
            case .updateShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.delegate = self
                cell.myShift = myShift
                cell.subjectL.text = "Discussion"
                cell.descriptionTV.text = updateShiftStructure.upsDiscussion
                cell.journalType = .endShift
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 6:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
                cell.delegate = self
                cell.subjectL.text = "Incident Type"
                cell.myShift = .incidents
                cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
                cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
                cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
                
                if incidentStructure.incidentType == "" {
                    incidentStructure.incidentType = "Fire"
                }
                
                switch segmentType {
                case .fire:
                    cell.typeSegment.selectedSegmentIndex = 0
                case .ems:
                    cell.typeSegment.selectedSegmentIndex = 1
                case .rescue:
                    cell.typeSegment.selectedSegmentIndex = 2
                default:
                    cell.typeSegment.selectedSegmentIndex = 0
                }
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressSearchButtonsCell", for: indexPath) as! AddressSearchButtonsCell
                cell.subjectL.text = "Address"
                if streetName == "" {
                    cell.addressL.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
                } else {
                    cell.addressL.text = "\(streetNum) \(streetName)"
                }
                cell.addressL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if city == "" {
                    cell.cityL.attributedPlaceholder = NSAttributedString(string: "Your Town",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
                } else {
                    cell.cityL.text = city
                }
                cell.cityL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if stateName == "" {
                    cell.stateL.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.0)])
                } else {
                    cell.stateL.text = stateName
                }
                cell.stateL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if zipNum == "" {
                    cell.zipL.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
                } else {
                    cell.zipL.text = zipNum
                }
                cell.zipL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.delegate = self
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .address
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
                cell.delegate = self
                cell.descriptionTF.text = startShift?.startTime
                cell.subjectL.text = "Date From"
                let image = UIImage(named: "ICONS_TimePiece")
                cell.clockB.setImage(image, for: .normal)
                cell.descriptionTF.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .dateTime
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                return cell
            case .personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.delegate = self
                cell.myShift = .journal
                cell.journalType = .overview
                cell.subjectL.text = "Overview"
                cell.descriptionTV.text = journalStructure.journalOverview
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
                cell.subjectL.text = "Address"
                let image1 = UIImage(named: "ICONS_location blue")
                let image2 = UIImage(named: "ICONS_world blue")
                cell.locationB.setImage(image1, for: .normal)
                cell.mapB.setImage(image2, for: .normal)
                if streetName == "" {
                    cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                } else {
                    cell.addressTF.text = "\(streetNum) \(streetName)"
                }
                cell.addressTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                if city == "" {
                    cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                } else {
                    cell.cityTF.text = city
                }
                cell.cityTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                if stateName == "" {
                    cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                } else {
                    cell.stateTF.text = stateName
                }
                cell.stateTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                if zipNum == "" {
                    cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                } else {
                    cell.zipTF.text = zipNum
                }
                cell.zipTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.delegate = self
                return cell
            case .updateShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Platoon"
                cell.myShift = myShift
                cell.switchType = .platoon
                cell.descriptionTF.text = updateShiftStructure.upsPlatoonTF
                cell.defaultOrNote = updateShiftStructure.upsPlatoonB
                cell.defaultOvertimeL.text = updateShiftStructure.upsPlatoon
                cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
                cell.instructionalL.text = "If your update impacts your platoon, update it here."
                let image = UIImage(named: "ICONS_Directional orange")
                cell.directionalB.setImage(image, for: .normal)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.delegate = self
                cell.myShift = myShift
                cell.subjectL.text = "Discussion"
                cell.descriptionTV.text = startShiftStructure.ssDiscussion
                cell.journalType = .startShift
                return cell
            case .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.delegate = self
                cell.myShift = myShift
                cell.subjectL.text = "Discussion"
                cell.descriptionTV.text = endShiftStructure.esDiscussion
                cell.journalType = .endShift
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 7:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
                cell.subjectL.text = "Address"
                if incidentStructure.incidentStreetName == "" {
                    cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                } else {
                    streetName = incidentStructure.incidentStreetName
                    streetNum = incidentStructure.incidentStreetNum
                    cell.addressTF.text = "\(streetNum) \(streetName)"
                }
                cell.addressTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentCity == "" {
                    cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Your Town",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                } else {
                    cell.cityTF.text = incidentStructure.incidentCity
                }
                cell.cityTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentState == "" {
                    cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                } else {
                    cell.stateTF.text = incidentStructure.incidentState
                }
                cell.stateTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentZip == "" {
                    cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                } else {
                    cell.zipTF.text = incidentStructure.incidentZip
                }
                cell.zipTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.delegate = self
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
                cell.delegate = self
                if(showMap) {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 500)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = false
                    cell.useAddressB.alpha = 1.0
                } else {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 0)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = true
                    cell.useAddressB.alpha = 0.0
                }
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressSearchButtonsCell", for: indexPath) as! AddressSearchButtonsCell
                cell.subjectL.text = "Address"
                if streetName == "" {
                    cell.addressL.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                } else {
                    cell.addressL.text = "\(streetNum) \(streetName)"
                }
                cell.addressL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if city == "" {
                    cell.cityL.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                } else {
                    cell.cityL.text = city
                }
                cell.cityL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if stateName == "" {
                    cell.stateL.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                } else {
                    cell.stateL.text = stateName
                }
                cell.stateL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if zipNum == "" {
                    cell.zipL.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.45)])
                } else {
                    cell.zipL.text = zipNum
                }
                cell.zipL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.delegate = self
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .address
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.delegate = self
                cell.myShift = .journal
                cell.journalType = .overview
                cell.subjectL.text = "Overview"
                cell.descriptionTV.text = journalStructure.journalOverview
                return cell
            case .personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "User"
                if journalStructure.journalUser != "" {
                    cell.descriptionTF.text = journalStructure.journalUser
                } else {
                    cell.descriptionTF.placeholder = "Mark Smith"
                }
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
                cell.delegate = self
                if(showMap) {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 500)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = false
                    cell.useAddressB.alpha = 1.0
                } else {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 0)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = true
                    cell.useAddressB.alpha = 0.0
                }
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Platoon"
                cell.myShift = myShift
                cell.switchType = .platoon
                cell.descriptionTF.text = startShiftStructure.ssPlatoonTF
                cell.defaultOrNote = startShiftStructure.ssPlatoonB
                cell.defaultOvertimeL.text = startShiftStructure.ssPlatoon
                cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
                cell.instructionalL.text = "Select the platoon your working today"
                switch myShift {
                case .startShift:
                    let image = UIImage(named: "Directional-green-24974f")
                    cell.directionalB.setImage(image, for: .normal)
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    let image = UIImage(named: "ICONS_Directional red")
                    cell.directionalB.setImage(image, for: .normal)
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                default:
                    print("no shift")
                }
                return cell
            case .updateShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Fire Station"
                cell.myShift = myShift
                cell.switchType = .fireStation
                cell.defaultOvertimeL.text = updateShiftStructure.upsFireStation
                cell.switched = updateShiftStructure.upsFireStationB
                cell.answerL.text = updateShiftStructure.upsFireStationTF
                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
                cell.descriptionL.text = "If you move to a different station, enter it here."
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Platoon"
                cell.myShift = myShift
                cell.switchType = .platoon
                cell.defaultOvertimeL.text = endShiftStructure.esPlatoon
                cell.switched = endShiftStructure.esPlatoonB
                cell.answerL.text = endShiftStructure.esPlatoonTF
                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
                cell.descriptionL.text = "Select the platoon your working today"
                switch myShift {
                case .startShift:
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                default:
                    print("no shift")
                }
                if(updateTapped) {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 85)
                    )
                    cell.contentView.frame = frame
                    cell.answerL.isHidden = false
                    cell.alpha = 1.0
                } else {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 0)
                    )
                    cell.contentView.frame = frame
                    cell.answerL.isHidden = true
                    cell.alpha = 0.0
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 8:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
                cell.delegate = self
                switch myShift {
                case .incidents:
                    cell.incidentType = incidentStructure.incidentType
                default: break
                }
                if(showMap) {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 500)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = false
                    cell.useAddressB.alpha = 1.0
                    cell.reload()
                } else {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 0)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = true
                    cell.useAddressB.alpha = 0.0
                }
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDirectionalTVSwitchCell", for: indexPath) as! LabelDirectionalTVSwitchCell
                cell.delegate = self
                cell.subjectL.text = "NFIRS Incident Type"
                cell.descriptionTV.textColor =  UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
                cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.defaultOvertimeL.text = "Off"
                cell.myShift = myShift
                cell.defaultOvertimeB = false
                cell.myShift = .nfirsBasic1Search
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeSearchSwitchButtonCell", for: indexPath) as! LabelDateTimeSearchSwitchButtonCell
                cell.delegate = self
                cell.descriptionTF.text = startShift?.startTime
                cell.subjectL.text = "Date To"
                let image = UIImage(named: "ICONS_TimePiece")
                cell.clockB.setImage(image, for: .normal)
                cell.descriptionTF.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
                cell.myShift = myShift
                cell.defaultOrNot = false
                cell.switchType = .dateTime
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51,  alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .alarmSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
                cell.delegate = self
                if(showMap) {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 500)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = false
                    cell.useAddressB.alpha = 1.0
                } else {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 0)
                    )
                    cell.contentView.frame = frame
                    cell.useAddressB.isHidden = true
                    cell.useAddressB.alpha = 0.0
                }
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "User"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalUser != "" {
                    cell.descriptionTF.text = journalStructure.journalUser
                } else {
                    cell.descriptionTF.placeholder = "Mark Smith"
                }
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Platoon"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "C-Platoon"
                let image = UIImage(named: "ICONS_Directional blue")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .platoon
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Fire Station"
                cell.myShift = myShift
                cell.switchType = .fireStation
                cell.defaultOvertimeL.text = startShiftStructure.ssFireStation
                cell.switched = startShiftStructure.ssFireStationB
                cell.answerL.text = startShiftStructure.ssFireStationTF
                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
                cell.descriptionL.text = "Select or set up Fire Station you’re working at today."
                switch myShift {
                case .startShift:
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                default:
                    print("no shift")
                }
                return cell
            case .endShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Fire Station"
                cell.myShift = myShift
                cell.switchType = .fireStation
                cell.defaultOvertimeL.text = endShiftStructure.esFireStation
                cell.switched = endShiftStructure.esFireStationB
                cell.answerL.text = endShiftStructure.esFireStationTF
                cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
                cell.descriptionL.text = "Select or set up Fire Station you’re working at today."
                switch myShift {
                case .startShift:
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                    if(updateTapped) {
                        let frame = CGRect(
                            origin: CGPoint(x: 0, y: 0),
                            size: CGSize(width: tableView.frame.size.width, height: 85)
                        )
                        cell.contentView.frame = frame
                        cell.answerL.isHidden = false
                        cell.answerL.alpha = 1.0
                    } else {
                        let frame = CGRect(
                            origin: CGPoint(x: 0, y: 0),
                            size: CGSize(width: tableView.frame.size.width, height: 0)
                        )
                        cell.contentView.frame = frame
                        cell.answerL.isHidden = true
                        cell.answerL.alpha = 0.0
                    }
                default:
                    print("no shift")
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 9:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentTextViewWithDirectionalCell", for: indexPath) as! IncidentTextViewWithDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "NFIRS Incident Type"
                if incidentStructure.incidentNfirsIncidentType != "" {
                    cell.descriptionTV.textColor =  UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                    let type = incidentStructure.incidentNFIRSType
                    let number = incidentStructure.incidentNfirsIncidentTypeNumber
                    cell.descriptionTV.text = number+" "+type
                } else {
                    cell.descriptionTV.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)
                    cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = .incidents
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Local Incident Type"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "Structure Fire"
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .localIncidentType
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .ics214Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate = self
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.theShift = myShift
                cell.subjectL.text = "Fire Station"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalFireStation != "" {
                    cell.descriptionTF.text = journalStructure.journalFireStation
                } else {
                    cell.descriptionTF.placeholder = "01"
                }
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Crew"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "FF Smith, FF Marks"
                let image = UIImage(named: "ICONS_Directional blue")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .crew
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Assignment"
                cell.myShift = myShift
                cell.switchType = .assignment
                cell.descriptionTF.text = startShiftStructure.ssAssignmentTF
                cell.defaultOrNote = startShiftStructure.ssAssignmentB
                cell.defaultOvertimeL.text = startShiftStructure.ssAssignment
                cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
                cell.instructionalL.text = "Select or set up your assignment"
                switch myShift {
                case .startShift:
                    let image = UIImage(named: "Directional-green-24974f")
                    cell.directionalB.setImage(image, for: .normal)
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    let image = UIImage(named: "ICONS_Directional orange")
                    cell.directionalB.setImage(image, for: .normal)
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                default:
                    print("no shift")
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 10:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.subjectL.text = "Local Incident Type"
                cell.myShift = myShift
                cell.incidenttype = .localIncidentType
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                if incidentStructure.incidentLocalType != "" {
                    cell.descriptionTF.text = incidentStructure.incidentLocalType
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Platoon"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "C-Platoon"
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .platoon
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.myShift = myShift
                cell.userInfo = .platoon
                cell.subjectL.text = "Platoon"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalPlatoon != "" {
                    cell.descriptionTF.text = journalStructure.journalPlatoon
                } else {
                    cell.descriptionTF.placeholder = "B-Platoon"
                }
                let image = UIImage(named: "ICONS_Directional blue")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Fire Station"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "76"
                let image = UIImage(named: "ICONS_Directional blue")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .fireStation
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Apparatus"
                cell.myShift = myShift
                cell.switchType = .apparatus
                cell.descriptionTF.text = startShiftStructure.ssApparatusTF
                cell.defaultOrNote = startShiftStructure.ssApparatusB
                cell.defaultOvertimeL.text = startShiftStructure.ssApparatus
                cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
                cell.instructionalL.text = "Select or set up the rig you are working with"
                switch myShift {
                case .startShift:
                    let image = UIImage(named: "Directional-green-24974f")
                    cell.directionalB.setImage(image, for: .normal)
                    
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    let image = UIImage(named: "ICONS_Directional orange")
                    cell.directionalB.setImage(image, for: .normal)
                    
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                default:
                    print("no shift")
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 11:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.myShift = myShift
                cell.incidenttype = .locationType
                cell.subjectL.text = "Location Type"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                if incidentStructure.incidentLocationType != "" {
                    cell.descriptionTF.text = incidentStructure.incidentLocationType
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "In Front Of",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Crew"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "FF Smith, FF Marks"
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .crew
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.myShift = myShift
                cell.userInfo = .assignment
                cell.subjectL.text = "Assignment"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalAssignment != "" {
                    cell.descriptionTF.text = journalStructure.journalAssignment
                } else {
                    cell.descriptionTF.placeholder = "Chief Officer"
                }
                let image = UIImage(named: "ICONS_Directional blue")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Tags"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "March, Emergency"
                let image = UIImage(named: "ICONS_Directional blue")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .tag
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Resources"
                cell.myShift = myShift
                cell.switchType = .resources
                cell.defaultOvertimeL.text = startShiftStructure.ssResources
                
                cell.defaultOrNote = startShiftStructure.ssResourcesB
                
                if startShiftStructure.ssResourcesTF != "" {
                    cell.descriptionTF.textColor = UIColor.black
                    cell.descriptionTF.text = startShiftStructure.ssResourcesTF
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "E76, R1, EMS1",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.18, green: 0.22, blue: 0.26, alpha: 0.45)])
                }
                cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
                cell.instructionalL.text = "Select or create the rigs in your station"
                switch myShift {
                case .startShift:
                    let image = UIImage(named: "Directional-green-24974f")
                    cell.directionalB.setImage(image, for: .normal)
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                case .endShift:
                    let image = UIImage(named: "ICONS_Directional orange")
                    cell.directionalB.setImage(image, for: .normal)
                    cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
                    cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
                    cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                default:
                    print("no shift")
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 12:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.myShift = myShift
                cell.incidenttype = .streetType
                cell.subjectL.text = "Street Type"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                if incidentStructure.incidentStreetType != "" {
                    cell.descriptionTF.text = incidentStructure.incidentStreetType
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "AVE Avenue",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Fire Station"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "76"
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .fireStation
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .startShift:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDirectionalTVSwitchCell", for: indexPath) as! LabelDirectionalTVSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Crew"
                cell.myShift = .startShift
                cell.switchType = .crew
                let image = UIImage(named: "Directional-green-24974f")
                cell.directionalB.setImage(image, for: .normal)
                cell.defaultOvertimeL.text = startShiftStructure.ssCrews
                if startShiftStructure.ssCrewsTF != "" {
                    cell.descriptionTV.textColor = UIColor.black
                    cell.descriptionTV.text = startShiftStructure.ssCrewsTF
                } else {
                    cell.descriptionTV.attributedText = NSAttributedString(string: "FF Johnston, FF Smith, EMT Travis, EMT Jones",attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                }
                cell.defaultOvertimeB = startShiftStructure.ssCrewB
                cell.defaultOvertimeSwitch.setOn(cell.defaultOvertimeB, animated: true)
                cell.descriptionL.text = "Select your default crew"
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .journal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.myShift = myShift
                cell.userInfo = .apparatus
                cell.subjectL.text = "Apparatus"
                cell.descriptionTF.textColor = UIColor.black
                if journalStructure.journalApparatus != "" {
                    cell.descriptionTF.text = journalStructure.journalApparatus
                } else {
                    cell.descriptionTF.placeholder = "Engine"
                }
                let image = UIImage(named: "ICONS_Directional blue")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDirectionalTVSwitchCell", for: indexPath) as! LabelDirectionalTVSwitchCell
                cell.delegate = self
                cell.subjectL.text = "NFIRS Incident Type"
                cell.descriptionTV.textColor =  UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
                cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
                let image = UIImage(named: "ICONS_Directional blue")
                cell.directionalB.setImage(image, for: .normal)
                cell.defaultOvertimeL.text = "Off"
                cell.myShift = myShift
                cell.defaultOvertimeB = false
                cell.myShift = .nfirsBasic1Search
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 13:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.myShift = myShift
                cell.incidenttype = .streetPrefix
                cell.subjectL.text = "Street Prefix"
                cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                if incidentStructure.incidentStreetPrefix != "" {
                    cell.descriptionTF.text = incidentStructure.incidentStreetPrefix
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "N",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case .incidentSearch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Tags"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "Emergency, March"
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .tag
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            case .nfirsBasic1Search:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Local Incident Type"
                cell.descriptionTF.textColor = UIColor.black
                cell.descriptionTF.placeholder = "Structure Fire"
                let image = UIImage(named: "ICONS_Directional blue")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = myShift
                cell.defaultOrNote = false
                cell.switchType = .localIncidentType
                cell.defaultOvertimeL.text = "Off"
                cell.defaultOvertimeSwitch.setOn(false, animated: true)
                cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
                cell.defaultOvertimeSwitch.layer.cornerRadius = 16
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! startShiftOvertimeSwitchCell
            return cell
        }
    }
    
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
