//
//  StartShiftDashbaordModalTVC.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

protocol StartShiftDashbaordModalTVCDelegate: AnyObject {
    func startShiftCancel()
    func startShiftSave(shift: MenuItems, startShift: StartShiftData)
}

class StartShiftDashbaordModalTVC: UITableViewController {
    
//    MARK: -PROPERTIES-
    weak var delegate: StartShiftDashbaordModalTVCDelegate? = nil
    var alertUp: Bool = false
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    var relieveOrSupervisor: String = ""
    var relievingGuid: String = ""
    var supervisorGuid: String = ""
    var theResourcesCombineString: String = ""
    
    //    MARK: DATA
    var fjUserTime:UserTime!
    var fju:FireJournalUser!
    var fjuFireStationAddress: String = ""
    var fdResources = [UserFDResources]()
    var fdResourceCount: Int = 0
    var fdResourcesA = [String]()
    var fdResource: UserFDResources!
    var fetched:Array<Any>!
    var objectID:NSManagedObjectID!
    var fetchedResources = [UserFDResources]()
    var discussionHeight: CGFloat = 110
    var relieveAttendee: UserAttendees!
    var supervisorAttendee: UserAttendees!
    
    //    MARK: STRUCTS
    var theUser: UserEntryInfo!
    var startShiftStructure: StartShiftData!
    var startShift = StartShift.init(startTime: "")
    var theUserCrew: UserCrews!
    
    //    MARK: BOOL
    var showPicker: Bool = false
    var resourceTapped: Bool = false
    var updateCV: Bool = false
    var shiftAMorRelief = false
    var saveBTapped: Bool = false
    
    var resources = [UserFDResource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        getUserFDResources()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        startShiftStructure = StartShiftData.init()
        theUser = UserEntryInfo.init(user:"")
        roundViews()
        registerCells()
        getTheUser()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        tableView.layer.cornerRadius = 20
        tableView.clipsToBounds = true
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "SwitchCenteredTVCell", bundle: nil), forCellReuseIdentifier: "SwitchCenteredTVCell")
        tableView.register(UINib(nibName: "SwitchLeftAlignedTVCell", bundle: nil), forCellReuseIdentifier: "SwitchLeftAlignedTVCell")
        tableView.register(UINib(nibName: "DateTimeTVCell", bundle: nil), forCellReuseIdentifier: "DateTimeTVCell")
        tableView.register(UINib(nibName: "SubjectLabelTextFieldTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldTVCell")
        tableView.register(UINib(nibName: "SubjectLabelTextFieldIndicatorTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldIndicatorTVCell")
        tableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
        tableView.register(UINib(nibName: "SubjectLCell", bundle: nil), forCellReuseIdentifier: "SubjectLCell")
        tableView.register(UINib(nibName: "StartShiftFDResourcesCell", bundle: nil), forCellReuseIdentifier: "StartShiftFDResourcesCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
    }

    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ShiftModalHeaderV", owner: self, options: nil)?.first as! ShiftModalHeaderV
        headerV.delegate = self
        headerV.infoB.tintColor = UIColor(named: "FJGreenColor")
        headerV.backgroundIV.image = UIImage(named: "EDF0F6-D8E7FA_CellBkgrnd4sq")
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let row = indexPath.row
    switch row {
    case 0:
        return 44
    case 1:
        return 88
    case 2:
        if(showPicker) {
            return  132
        } else {
            return 0
        }
    case 3,4:
        return 88
    case 5,6:
        return 88
    case 7:
        return 44
    case 8:
        if fdResources.count != 0 {
            return 240
        } else {
            return 90
        }
    case 9:
        if discussionHeight == 110 {
            discussionHeight = getDiscussionHeight()
        }
        return discussionHeight
    case 10:
        return 200
    default:
        return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
        switch  row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCenteredTVCell", for: indexPath) as! SwitchCenteredTVCell
            cell.centerSwitch.isOn = shiftAMorRelief
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeTVCell", for: indexPath) as! DateTimeTVCell
            cell.subjectL.text = "Date/Time"
            let theDate = startShiftStructure.ssDateTime
            let stringDate = vcLaunch.fullDateString(date: theDate)
            cell.dateTimeTF.text = stringDate
            cell.dateTimeB.tintColor = UIColor(named: "FJGreenColor")
            cell.delegate = self
        return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldTVCell", for: indexPath) as! SubjectLabelTextFieldTVCell
            cell.subjectL.text = "Fire Station"
            cell.subjectTF.text = startShiftStructure.ssFireStationTF
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell.subjectL.text = "Platoon"
            cell.subjectTF.text = startShiftStructure.ssPlatoonTF
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            return cell
        case 5:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell.subjectL.text = "Assignment"
            cell.subjectTF.text = startShiftStructure.ssAssignmentTF
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell.subjectL.text = "Relieving"
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            cell.subjectTF.text = startShiftStructure.ssRelieving
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLCell", for: indexPath) as! SubjectLCell
            cell.subjectL.text = "Station Apparatus Status"
            return cell
        case 8:
            if resources.count != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StartShiftFDResourcesCell", for: indexPath) as! StartShiftFDResourcesCell
                cell.delegate = self
                cell.fdResourcesCount = fdResourceCount
                cell.fdResources = fdResources
                if updateCV {
                    cell.startShiftCV.reloadData()
                    updateCV = false
                }
                print(fdResourceCount)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.modalTitleL.font = cell.modalTitleL.font.withSize(12)
                cell.modalTitleL.adjustsFontSizeToFitWidth = true
                cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.modalTitleL.numberOfLines = 0
                cell.modalTitleL.setNeedsDisplay()
                cell.modalTitleL.text = "To set up your station's apparatus, you'll need to go into Settings, under Fire/EMS Resources and choose up to 10 Fire/EMS Resources to be your base Station Apparatus. Once created, you can manage your Fire/EMS Resources with Front Line, Reserve and Out of Service modes."
                return cell
            }
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextViewTVCell", for: indexPath) as! SubjectLabelTextViewTVCell
            cell.subjectL.text = "Discussion"
            if startShiftStructure.ssDiscussion != "" {
                cell.subjectTV.text = startShiftStructure.ssDiscussion
            }
            cell.delegate = self
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell.subjectL.text = "Supervisor"
            cell.subjectTF.text = ""
            cell.indicatorB.tintColor = UIColor(named: "FJGreenColor")
            cell.subjectTF.text = startShiftStructure.ssSupervisor
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.item
        switch row {
        case 4:
            let platoons = getThePlatoons()
            let storyboard = UIStoryboard(name: "Platoons", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! PlatoonsVC
            vc.platoons = platoons
            vc.delegate = self
            present(vc, animated: true )
        case 5:
            presentModal(menuType: MenuItems.startShift, title: "Assignment", type: UserInfo.assignment)
        case 6:
            relieveOrSupervisor = "Relieve"
            presentCrew(menuType: MenuItems.startShift, title: "Relieving", type: IncidentTypes.crew)
        case 10:
            relieveOrSupervisor = "Supervisor"
            presentCrew(menuType: MenuItems.startShift, title: "Supervisor", type: IncidentTypes.crew)
        default:
            break
        }
    }

}

extension StartShiftDashbaordModalTVC {
    
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
    
    //    MARK: -presentCrew for startShift
    fileprivate func presentCrew(menuType:MenuItems, title:String, type:IncidentTypes){
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisorModal", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorModalTVC") as! RelieveSupervisorModalTVC
        dataTVC.delegate = self
        if relieveOrSupervisor == "Relieve" {
            dataTVC.relieveOrSupervisor = true
            dataTVC.headerTitle = "Relieving"
        } else if relieveOrSupervisor == "Supervisor" {
            dataTVC.relieveOrSupervisor = false
            dataTVC.headerTitle = "Supervisor"
        }
        dataTVC.menuType = MenuItems.startShift
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
}

extension StartShiftDashbaordModalTVC: RelieveSupervisorModalTVCDelegate {
    func relieveSupervisorModalCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorModalSave(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
        let crew = relieveSupervisor.first
        if relieveOrSupervisor {
            startShiftStructure.ssRelieving = crew?.attendee ??  ""
            relievingGuid = crew?.attendeeGuid ?? ""
            let indexPath = IndexPath(row: 6, section: 0)
            relieveAttendee = crew
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            startShiftStructure.ssSupervisor = crew?.attendee ?? ""
            supervisorGuid = crew?.attendeeGuid ?? ""
            let indexPath = IndexPath(row: 10, section: 0)
            supervisorAttendee = crew
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension StartShiftDashbaordModalTVC: SubjectLabelTextViewTVCellDelegate {
    func subjectLabelTextViewEditing(text: String) {
        startShiftStructure.ssDiscussion = text
    }
    
    func subjectLabelTextViewDoneEditing(text: String) {
        self.resignFirstResponder()
        startShiftStructure.ssDiscussion = text
        if !saveBTapped {
            updateTheTextViewCell()
        }
    }
    
    func updateTheTextViewCell() {
         let indexPath = IndexPath(row: 9, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SubjectLabelTextViewTVCell
        let size = CGSize(width: cell.subjectTV.frame.width, height: .infinity)
        cell.subjectTV.text = startShiftStructure.ssDiscussion
        let estimatedSize = cell.subjectTV.sizeThatFits(size)
        discussionHeight = estimatedSize.height + 110
        if discussionHeight < 110 {
            discussionHeight = 110
        }
        tableView.beginUpdates()
        cell.subjectTV.constraints.forEach {
            (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 110 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 110
                    }
                }
            }
        }
        tableView.endUpdates()
    }
    
}

extension StartShiftDashbaordModalTVC: CrewModalTVCDelegate {
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
        self.dismiss(animated: true, completion:nil)
    }
    
    
}

extension StartShiftDashbaordModalTVC: DataModalTVCDelegate {
    func dataModalCancelCalled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theDataModalChosen(objectID: NSManagedObjectID, user: UserInfo) {
        switch user {
        case .assignment:
            let assignment = context.object(with:objectID) as? UserAssignments
            theUser.assignment = assignment?.assignment ?? ""
            theUser.assignmentGuid = assignment?.assignmentGuid ?? ""
            theUser.assignmentDefault = assignment?.defaultAssignment ?? true
            startShiftStructure.ssAssignmentTF = theUser.assignment
            startShiftStructure.ssAssignmentB = theUser.assignmentDefault
            let indexPath = IndexPath(row: 5, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.dismiss(animated: true, completion: nil)
        default: break
        }
    }
}

extension StartShiftDashbaordModalTVC: PlatoonsVCDelegate {
    func platoonsCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func platoonsVCChosen(platoon: UserPlatoon) {
        theUser.platoon = platoon.platoon ?? ""
        theUser.platoonGuid = platoon.platoonGuid ?? ""
        theUser.platoonDefault = platoon.defaultPlatoon
        startShiftStructure.ssPlatoonTF = theUser.platoon
        let indexPath = IndexPath(row: 4, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true, completion: nil)
    }
}

extension StartShiftDashbaordModalTVC: ShiftModalHeaderVDelegate {
    
    func shiftModalSaveBTapped() {
        saveBTapped = true
        saveStartShift()
            let entity = "UserTime"
            let attribute = "userTimeGuid"
            let sort = "userStartShiftTime"
            getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkSTARTSHIFTFORDASH),
                        object: nil,
                        userInfo: ["startShift":self.startShiftStructure as Any])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                        object: nil,
                        userInfo: ["objectID":self.objectID as Any])
            }
            delegate?.startShiftSave(shift: MenuItems.startShift, startShift: startShiftStructure)
    }
    
    func shiftModalCancelBTapped() {
        delegate?.startShiftCancel()
    }
    
    func shiftModalInfoBTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let message: InfoBodyText = .startShiftRecorded
        let title: InfoBodyText = .startShiftRecordedSubject
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension StartShiftDashbaordModalTVC: SwitchCenteredTVCellDelegate {
    func switchCenteredHasBeenTapped(switchB: Bool) {
        shiftAMorRelief.toggle()
        startShiftStructure.ssAMReliefDefault = shiftAMorRelief
    }

}

extension StartShiftDashbaordModalTVC: FDResourceCustomEditVCDelegate {
    func fdResourceCustomEditCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fdResourceCustomEditSaveTapped(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = false
        updateCV = true
        saveToCDForUFDResource(objectID: fdResource.objectID)
        self.dismiss(animated: true, completion: nil)
    }
}

extension StartShiftDashbaordModalTVC: FDResourceEditVCDelegate {
    func theCancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theSaveResourceTapped(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = false
        updateCV = true
        saveToCDForUFDResource(objectID: fdResource.objectID)
        self.dismiss(animated: true, completion: nil)
    }
}

extension StartShiftDashbaordModalTVC:  StartShiftFDResourcesCellDelegate {
    func aResourceHasBeenTappedForEditing(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = true
        let custom = fdResource.customResource
        if custom {
                   let storyboard = UIStoryboard(name: "CustomResource", bundle: nil)
                   let vc = storyboard.instantiateInitialViewController() as! FDResourceCustomEditVC
                   vc.fdResources = resource
                   vc.delegate = self
                   present(vc, animated: true )
        } else {
                    let storyboard = UIStoryboard(name: String(describing: Resources.self ), bundle: nil)
                    let vc = storyboard.instantiateInitialViewController() as! FDResourceEditVC
                    vc.fdResources = resource
                    vc.delegate = self
                    present(vc, animated: true )
        }
    }
}

extension StartShiftDashbaordModalTVC: NSFetchedResultsControllerDelegate  {
//    MARK: -SAVE THE SHIFT-
    private func saveStartShift() {
        let resources = buildTheResourcesForJournalEntry()
        let resourcesString = resources.reduce("", +)
        startShiftStructure.ssResourcesCombine = theResourcesCombineString
        startShiftStructure.ssResourcesTF = resourcesString
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDateAndTime()
        fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        fjuJournal.journalEntryType = "Station"
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fju.userGuid
        let journalTitle = "Start Shift \(sDate)"
        fjuJournal.journalHeader = journalTitle
        let overview:String = "Start Shift:\n\(startShiftStructure.ssAMReliefDefaultT)\nDate/Time:\(sDate)\nRelieving:\(startShiftStructure.ssRelieving)\nSupervisor:\(startShiftStructure.ssSupervisor)\nDisscussion:\(startShiftStructure.ssDiscussion)\nPlatoon:\(startShiftStructure.ssPlatoonTF) - \(startShiftStructure.ssPlatoon)\nFire Station:\(startShiftStructure.ssFireStationTF) - \(startShiftStructure.ssFireStation)\nAssignment: \(startShiftStructure.ssAssignmentTF) - \(startShiftStructure.ssAssignment)\rApparatus: \(startShiftStructure.ssApparatusTF) - \(startShiftStructure.ssApparatus)\nResources: \(resourcesString)\nAddress: \(fjuFireStationAddress)\n"
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
        fju.tempResources = startShiftStructure.ssResourcesCombine
        fju.defaultResources = startShiftStructure.ssResourcesCombine
        fju.defaultResourcesName = ""
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
            fjUserTime.startShiftResources = startShiftStructure.ssResourcesCombine
            fjUserTime.startShiftCrew = startShiftStructure.ssCrewsTF
            fjUserTime.startShiftRelieving = startShiftStructure.ssRelieving
            fjUserTime.startShiftDiscussion = startShiftStructure.ssDiscussion
            fjUserTime.startShiftSupervisor = startShiftStructure.ssSupervisor
            fjUserTime.userStartShiftTime = journalModDate
            fjUserTime.entryState = EntryState.update.rawValue
            fjUserTime.userTimeBackup = false
        }
        saveToCD()
    }
//    MARK: -SAVE TO  CD-
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"STARTSHIFT merge that"])
            }
            getUserFDResources()
            self.tableView.reloadData()

        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "StartShiftModalTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
//    MARK: -USER TIME COUNT-
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
            print("THEUSERTIMECOUNT line 651 Fetch Error: \(error.localizedDescription)")
        }
    }
//    MARK: -BUILD RESOURCES FOR JOURNAL-
    func buildTheResourcesForJournalEntry()->[String] {
//        getUserFDResources()
        var theResourcesString = "\n"
        var theResourceType = ""
        var resourceA = [theResourcesString]
        theResourcesCombineString = ""
        if fdResources.isEmpty { return resourceA } else {
            for resource in fdResources {
                theResourcesString = resource.fdResource ?? ""
                let resourceType: Int64 = resource.fdResourceType
                    switch resourceType {
                        case 0001: break
                        case 0002:
                           theResourceType = "Front Line"
                        case 0003:
                            theResourceType = "Reserve"
                        case 0004:
                           theResourceType = "Out of Service"
                        default: break
                    }
                theResourcesString = "\(theResourcesString): \(theResourceType)\n"
                theResourcesCombineString = "\(theResourcesCombineString)\(theResourcesString)\n"
                resourceA.append(theResourcesString)
            }
            return resourceA
        }
    }
//    MARK: -SAVE FOR USERFDRESOURCE-
    fileprivate func saveToCDForUFDResource(objectID: NSManagedObjectID) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"merge that"])
            }
            DispatchQueue.main.async { [weak self] in
                self?.nc.post(name: Notification.Name(rawValue: FJkFDRESOURCESMODIFIEDTOCLOUD),
                              object: nil, userInfo: ["objectID":objectID])
            }
        
            
            let indexPath1 = IndexPath(row: 8, section: 0)
            tableView.reloadRows(at: [indexPath1], with: .automatic)
            
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "StartShiftDashboardModalTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    //    MARK: -HEIGHT FOR UITEXTVIEW
    private func getDiscussionHeight() ->CGFloat {
        if startShiftStructure.ssDiscussion != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = startShiftStructure.ssDiscussion
            let estimatedSize = textView.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 110
            if discussionHeight < 110 {
                discussionHeight = 110
            }
        }
        return discussionHeight
    }
    
    //    MARK: -Data acquisition
    private func getTheLastSaved(entity:String,attribute:String,sort:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K != %@",attribute, "")
        let sectionSortDescriptor = NSSortDescriptor(key: sort, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [UserTime]
            let userTime = self.fetched.last as! UserTime
            self.objectID = userTime.objectID
        } catch let error as NSError {
            print("startshiftModal line 757 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func getUserFDResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        do {
            fetchedResources = try context.fetch(fetchRequest) as! [UserFDResources]
            if fetchedResources.count == 0 {
//                closeItUp()
            } else {
                for resource in fetchedResources {
                    let objectID = resource.objectID
                    var customImage: Bool = false
                    let imageType: Int64 = resource.fdResourceType
                    var name: String = ""
                    if let resourceName = resource.fdResource {
                        name = resourceName
                    }
                    if resource.customResource {
                            customImage = true
                    }
                    let r = UserFDResource.init(type: imageType, resource: name, objectID: objectID, custom: customImage)
                    r.resourceStatusImageName = resource.fdResource ??  ""
                    if let count = Int64(resource.fdResourcesPersonnelCount ?? "0") {
                        r.resourcePersonnelCount = count
                    }
                    r.resourceManufacturer = resource.fdManufacturer ?? ""
                    r.resourceID = resource.fdResourceID ?? ""
                    r.resourceShopNumber = resource.fdShopNumber ?? ""
                    r.resourceApparatus = resource.fdResourceApparatus ?? ""
                    r.resourceSpecialities = resource.fdResourcesSpecialties ?? ""
                    r.resourceDescription = resource.fdResourceDescription ?? ""
                    r.resourceYear = resource.fdYear ?? ""
                    resources.append(r)
                    fdResources.append(resource)
                }
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        
    }
    
    private func getThePlatoons() -> [UserPlatoon] {
        var platoons = [UserPlatoon]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserPlatoon" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "platoon", "")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
                platoons = try context.fetch(fetchRequest) as! [UserPlatoon]
            }  catch let error as NSError {
                    print("StartShiftModalTVC line 433 Fetch Error: \(error.localizedDescription)")
            }
        return platoons
    }
    //    MARK: -GetTheUser
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
                    startShiftStructure.ssPlatoonB = true
                    startShiftStructure.ssPlatoon = "Default"
                    
                    if let num = fju.fireStationStreetNumber {
                        fjuFireStationAddress = num
                    }
                    if fjuFireStationAddress != "" {
                        if let name = fju.fireStationStreetName {
                            fjuFireStationAddress += name
                        }
                        
                        if let city = fju.fireStationCity {
                            fjuFireStationAddress += city
                        }
                        
                        if let fsState = fju.fireStationState {
                            fjuFireStationAddress += ", \(fsState)"
                        }
                        
                        if let fsZip = fju.fireStationZipCode {
                            fjuFireStationAddress += fsZip
                        }
                        
                        /// location unarchived from secureCoding
                        if fju.fjuLocationSC != nil {
                            if let location = fju.fjuLocationSC {
                                guard let  archivedData = location as? Data else { return }
                                do {
                                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                                    let location:CLLocation = unarchivedLocation
                                    let latitude = String(location.coordinate.latitude)
                                    let longitude = String(location.coordinate.longitude)
                                    let locationString = "\nLocation:\nLatitude: \(latitude)\nLongitude: \(longitude)"
                                    fjuFireStationAddress += locationString
                                } catch {
                                    print("Unarchiver failed on arcLocation")
                                }
                            }
                        }

                    }
                    
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
                    
                } catch let error as NSError {
                    print("StartShiftModalTVC line 248 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("StartShiftModalTVC line 253 Fetch Error: \(error.localizedDescription)")
        }
    }
}

extension StartShiftDashbaordModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        startShiftStructure.ssDateTime = date
        let indexPath = IndexPath(row: 1, section: 0)
        let indexPath2 = IndexPath(row: 2, section: 0)
        showPicker.toggle()
        tableView.reloadRows(at: [indexPath,indexPath2], with: .automatic)
    }
}

extension StartShiftDashbaordModalTVC: DateTimeTVCellDelegate {
    func dateTimeBTapped() {
        showPicker.toggle()
        let indexPath = IndexPath(row: 2, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
