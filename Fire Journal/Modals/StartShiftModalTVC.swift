//
//  StartShiftModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/12/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol StartShiftModalTVCDelegate: AnyObject {
    func cancelStartShiftCalled()
    func startShiftSaved(shift: MenuItems, startShift: StartShiftData)
}

class StartShiftModalTVC: UITableViewController {
    
    //    MARK: PROPERTIES
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    weak var delegate: StartShiftModalTVCDelegate? = nil
    var theResourcesCombineString = ""
    var discussionHeight: CGFloat = 110
    
    //    MARK: DATA
    var fjUserTime:UserTime! = nil
    var fju:FireJournalUser!
    var fdResources = [UserFDResources]()
    var fdResourceCount: Int = 0
    var fdResourcesA = [String]()
    var fdResource: UserFDResources!
    var fetched:Array<Any>!
    var theUserCrew: UserCrews!
    var theCrew: TheCrew!
    
    var objectID:NSManagedObjectID!
    
    //    MARK: STRUCTS
    var theUser: UserEntryInfo!
    var startShiftStructure: StartShiftData!
    var startShift = StartShift.init(startTime: "")
    
    //    MARK: BOOL
    var showPicker: Bool = false
    var resourceTapped: Bool = false
    var updateCV: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        device = Device.init()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        roundViews()
        registerCellsForTable()
        getTheUserFDResources()
        startShiftStructure = StartShiftData.init()
        theUser = UserEntryInfo.init(user:"")
        getTheUser()
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
    }
    
    func registerCellsForTable() {
        tableView.register(UINib(nibName: "StartShiftFDResourcesCell", bundle: nil), forCellReuseIdentifier: "StartShiftFDResourcesCell")
        tableView.register(UINib(nibName: "userFDResourcesCustomCell", bundle: nil), forCellReuseIdentifier: "userFDResourcesCustomCell")
        tableView.register(UINib(nibName: "UserFDResourcesCell", bundle: nil), forCellReuseIdentifier: "UserFDResourcesCell")
        tableView.register(UINib(nibName: "startShiftOvertimeSwitchCell", bundle: nil), forCellReuseIdentifier: "startShiftOvertimeSwitchCell")
        tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "LabelTextViewCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
        tableView.register(UINib(nibName: "LabelTextFieldDirectionalSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldDirectionalSwitchCell")
        tableView.register(UINib(nibName: "LabelAnswerSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelAnswerSwitchCell")
        tableView.register(UINib(nibName: "LabelDirectionalTVSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelDirectionalTVSwitchCell")
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
    }

    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHTitleL.text = "Start Shift"
        let color = UIColor(red: 0.130, green: 0.534, blue: 0.243, alpha: 1.000)
        headerV.contentView.backgroundColor = color
        
        headerV.myShift = MenuItems.personal
        headerV.delegate = self
        return headerV
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
        }
        return discussionHeight
    }
    
    //    MARK: -TABLEVIEW DELEGATION
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 44
        case 1:
            return 80
        case 2:
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case 3:
            return 95
        case 4:
            return 100
        case 5:
            return 85
        case 6:
            if discussionHeight == 110 {
                discussionHeight = getDiscussionHeight()
            }
            return discussionHeight
        case 7:
            return 44
        case 8:
            if fdResourceCount <= 5 {
                if Device.IS_IPAD {
                    return 113
                } else {
                    return 230
                }
            } else {
                if Device.IS_IPAD {
                    return 225
                } else {
                    return 380
                }
            }
        case 9:
            if resourceTapped {
                return 82
            } else {
                return 0
            }
        case 10:
            return 100
        case 11:
            return 100
        case 12:
            return 140
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch  row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
            cell.amOrOvertimeL.text = startShiftStructure.ssAMReliefDefaultT
            cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
            cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
            cell.amOrOvertimeSwitch.layer.cornerRadius = 16
            cell.startOrEndB = startShiftStructure.ssAMReliefDefault
            cell.myShift = MenuItems.startShift
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            let theDate = startShiftStructure.ssDateTime
            let stringDate = vcLaunch.fullDateString(date: theDate)
            cell.dateTimeTV.text = stringDate
            startShift?.startTime = stringDate
            cell.dateTimeL.text = "Date/Time"
            cell.type = .fire
            let image = UIImage(named: "ICONS_TimePiece green")
            cell.dateTimeB.setImage(image, for: .normal)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
            cell.delegate = self
            cell.subjectL.text = "Fire Station"
            cell.myShift = MenuItems.startShift
            cell.switchType = .fireStation
            cell.defaultOvertimeL.text = startShiftStructure.ssFireStation
            cell.switched = startShiftStructure.ssFireStationB
            cell.answerL.text = startShiftStructure.ssFireStationTF
            cell.defaultOvertimeSwitch.setOn(cell.switched, animated: true)
            cell.descriptionL.text = "Select or set up the Fire Station you’re working at today."
            cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
            cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
            cell.defaultOvertimeSwitch.layer.cornerRadius = 16
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
            cell.delegate = self
            cell.subjectL.text = "Platoon"
            cell.myShift = MenuItems.startShift
            cell.switchType = .platoon
            cell.descriptionTF.text = startShiftStructure.ssPlatoonTF
            cell.defaultOrNote = startShiftStructure.ssPlatoonB
            cell.defaultOvertimeL.text = startShiftStructure.ssPlatoon
            cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
            cell.instructionalL.text = "Select the platoon you’re working today"
            let image = UIImage(named: "Directional green")
            cell.directionalB.setImage(image, for: .normal)
            cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
            cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
            cell.defaultOvertimeSwitch.layer.cornerRadius = 16
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.delegate = self
            cell.theShift = MenuItems.startShift
            cell.subjectL.text = "Relieving"
            cell.descriptionTF.text = startShiftStructure.ssRelieving
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
            cell.delegate = self
            cell.myShift = MenuItems.startShift
            cell.subjectL.text = "Discussion"
            cell.descriptionTV.text = startShiftStructure.ssDiscussion
            cell.journalType = .startShift
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.modalTitleL.text = "Station Apparatus Status"
            cell.modalTitleL.font = cell.modalTitleL.font.withSize(24)
            return cell
        case 8:
            if fdResources.count != 0 {
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
            if resourceTapped {
                let custom = fdResource.customResource
                if custom {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "userFDResourcesCustomCell", for: indexPath) as! userFDResourcesCustomCell
                    cell.delegate = self
                    cell.showResources = true
                    cell.fdResources = fdResource
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UserFDResourcesCell", for: indexPath) as! UserFDResourcesCell
                    cell.delegate = self
                    cell.showResources = true
                    cell.fdResources = fdResource
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.modalTitleL.text = ""
                return cell
            }
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
            cell.delegate = self
            cell.subjectL.text = "Assignment"
            cell.myShift = MenuItems.startShift
            cell.switchType = .assignment
            cell.descriptionTF.text = startShiftStructure.ssAssignmentTF
            cell.defaultOrNote = startShiftStructure.ssAssignmentB
            cell.defaultOvertimeL.text = startShiftStructure.ssAssignment
            cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
            cell.instructionalL.text = "My assignment for this shift"
            let image = UIImage(named: "Directional green")
            cell.directionalB.setImage(image, for: .normal)
            cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
            cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
            cell.defaultOvertimeSwitch.layer.cornerRadius = 16
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
            cell.delegate = self
            cell.subjectL.text = "Apparatus"
            cell.myShift = MenuItems.startShift
            cell.switchType = .apparatus
            cell.descriptionTF.text = startShiftStructure.ssApparatusTF
            cell.defaultOrNote = startShiftStructure.ssApparatusB
            cell.defaultOvertimeL.text = startShiftStructure.ssApparatus
            cell.defaultOvertimeSwitch.setOn(cell.defaultOrNote, animated: true)
            cell.instructionalL.text = "My assigned apparatus"
             let image = UIImage(named: "Directional green")
            cell.directionalB.setImage(image, for: .normal)
            
            cell.defaultOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1)
            cell.defaultOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 0.35)
            cell.defaultOvertimeSwitch.layer.cornerRadius = 16
            return cell
        case 12:
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDirectionalTVSwitchCell", for: indexPath) as! LabelDirectionalTVSwitchCell
        cell.delegate = self
        cell.subjectL.text = "Crew"
        cell.myShift = .startShift
        cell.switchType = .crew
        let image = UIImage(named: "Directional green")
        cell.directionalB.setImage(image, for: .normal)
        cell.defaultOvertimeL.text = startShiftStructure.ssCrews
        if startShiftStructure.ssCrewsTF != "" {
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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }

}

extension StartShiftModalTVC {
    //    MARK: -Data acquisition
    private func getTheUserFDResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 10
        do {
            fdResources = try context.fetch(fetchRequest) as! [UserFDResources]
            
            if fdResources.count == 0 {
                print("hey we have zero")
            } else {
                for resource in fdResources {
                    if fdResource == nil {
                        fdResource = resource
                    }
                    let result = fdResourcesA.filter { $0 == resource.fdResource}
                    if result.isEmpty {
                        if fdResourcesA.count < 10 {
                            fdResourcesA.append(resource.fdResource!)
                            fdResourceCount = fdResourceCount+1
                        }
                    }
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

extension StartShiftModalTVC: LabelDirectionalTVSwitchCellDelegate {
    func tvDirectionalTapped(myShift: MenuItems) {
        presentCrew(menuType: myShift, title: "Crew", type: .crew)
    }
    
    func tvSwitchTapped(myShift: MenuItems, defaultOvertimeB: Bool) {
        //        MARK: TODO
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
}

extension StartShiftModalTVC: CrewModalTVCDelegate {
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
    
    
}

extension StartShiftModalTVC: LabelAnswerSwitchCellDelegate {
    func defaultOvertimeSwitchTapped(switched: Bool, type: MenuItems, switchType: SwitchTypes) {
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
        default: break
        }
    }
    
    func answerLEditing(text: String, myShift: MenuItems, switchType: SwitchTypes) {
        //        MARK: TODO
    }
    
    func answerLDidEndEditing(text: String, switchType: SwitchTypes) {
        switch switchType {
        case .platoon:
            startShiftStructure.ssPlatoonTF = text
        case .fireStation:
            startShiftStructure.ssFireStationTF = text
        case .assignment:
            startShiftStructure.ssAssignmentTF = text
        case .apparatus:
            startShiftStructure.ssApparatusTF = text
        default: break
        }
    }
    
    
}

extension StartShiftModalTVC: LabelTextFieldDirectionalSwitchCellDelegate {
    func directionalButTapped(switchType: SwitchTypes, type: MenuItems) {
        switch switchType {
        case .apparatus:
            presentModal(menuType: type, title: "Apparatus", type: .apparatus)
        case .assignment:
            presentModal(menuType: type, title: "Assignment", type: .assignment)
        case .platoon:
//            presentModal(menuType: type, title: "Platoon", type: .platoon)
            let platoons = getThePlatoons()
            let storyboard = UIStoryboard(name: "Platoons", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! PlatoonsVC
            vc.platoons = platoons
            vc.delegate = self
            present(vc, animated: true )
        default:break
        }
    }
    
    func defaultOvertimeDirectionalSwitchTapped(switched: Bool, type: MenuItems, switchType: SwitchTypes) {
        switch switchType {
        case .apparatus:
            startShiftStructure.ssApparatusB = switched
        case .assignment:
            startShiftStructure.ssAssignmentB = switched
        case .platoon:
            startShiftStructure.ssPlatoonB = switched
        default:break
        }
    }
    
    func descriptionTextFieldDoneEditing() {
        //        MARK: TODO
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
    
    
}

extension StartShiftModalTVC: DataModalTVCDelegate {
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
            startShiftStructure.ssPlatoonTF = theUser.platoon
            startShiftStructure.ssPlatoonB = theUser.platoonDefault
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
}

extension StartShiftModalTVC: LabelTextViewCellDelegate {
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
            startShiftStructure.ssDiscussion = text

            let indexPath = IndexPath(row: 6, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
            let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
            let estimatedSize = cell.descriptionTV.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 52.5
            tableView.beginUpdates()
            cell.descriptionTV.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    if Device.IS_IPAD {
                        constraint.constant = estimatedSize.height
                    } else {
                        if estimatedSize.height < 400 {
                            constraint.constant = estimatedSize.height
                        } else {
                            constraint.constant = 400
                        }
                    }
                }
                
            }
            tableView.endUpdates()
            
        }
        
        func textViewDoneEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
            startShiftStructure.ssDiscussion = text

            let indexPath = IndexPath(row: 6, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
            let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
            let estimatedSize = cell.descriptionTV.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 52.5
            tableView.beginUpdates()
            cell.descriptionTV.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    if Device.IS_IPAD {
                        constraint.constant = estimatedSize.height
                    } else {
                        if estimatedSize.height < 400 {
                            constraint.constant = estimatedSize.height
                        } else {
                            constraint.constant = 400
                        }
                    }
                }
                
            }
            tableView.endUpdates()
    }
    
    func textViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {
        //        MARK: TODO
    }
    
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {
        //        MARK: TODO
    }
    
    
}

extension StartShiftModalTVC: LabelTextFieldCellDelegate {
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
        //        MARK: TODO
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
        //        MARK: TODO
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        startShiftStructure.ssRelieving = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems) {
        startShiftStructure.ssRelieving = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
        //        MARK: TODO
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
        //        MARK: TODO
    }
    
    
}

extension StartShiftModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        startShiftStructure.ssDateTime = date
        tableView.reloadData()
    }
}

extension StartShiftModalTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
}

extension StartShiftModalTVC: StartShiftOvertimeSwitchDelegate {
    func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems) {
        startShiftStructure.ssAMReliefDefaultT = type
        startShiftStructure.ssAMReliefDefault = startOrEnd
    }
}

extension StartShiftModalTVC: ModalHeaderSaveDismissDelegate {
   
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    
    func modalDismiss() {
        delegate?.cancelStartShiftCalled()
    }
    
    func modalSave(myShift: MenuItems) {
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
        delegate?.startShiftSaved(shift: MenuItems.startShift, startShift: startShiftStructure)
    }
}

extension StartShiftModalTVC: StartShiftFDResourcesCellDelegate {
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

extension StartShiftModalTVC: UserFDResourceCellDelegate {
    func theNotCustomSaveBWasTapped(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = false
        updateCV = true
        saveToCDForUFDResource(objectID: fdResource.objectID)
    }
}

extension StartShiftModalTVC: userFDResourcesCustomCellDelegate {
    func theSaveBWasTapped(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = false
        updateCV = true
        saveToCDForUFDResource(objectID: fdResource.objectID)
    }
    //     MARK: -break out the UserResources for the StartShift Journal Entry
    func buildTheResourcesForJournalEntry()->[String] {
        getTheUserFDResources()
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
//    fdResources
    //    MARK: - save handling
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
        let overview:String = "Start Shift:\n\(startShiftStructure.ssAMReliefDefaultT)\nDate/Time:\(sDate)\nRelieving:\(startShiftStructure.ssRelieving)\nDisscussion:\(startShiftStructure.ssDiscussion)\nPlatoon:\(startShiftStructure.ssPlatoonTF) - \(startShiftStructure.ssPlatoon)\nFire Station:\(startShiftStructure.ssFireStationTF) - \(startShiftStructure.ssFireStation)\nAssignment: \(startShiftStructure.ssAssignmentTF) - \(startShiftStructure.ssAssignment)\rApparatus: \(startShiftStructure.ssApparatusTF) - \(startShiftStructure.ssApparatus)\nResources: \(resourcesString)Crew:\(startShiftStructure.ssCrewsTF) - \(startShiftStructure.ssCrews)"
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
            fjUserTime.userStartShiftTime = journalModDate
            fjUserTime.entryState = EntryState.update.rawValue
            fjUserTime.userTimeBackup = false
        }
        
        saveToCD()
    }
    
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
            print("ModalTVC line 1721 Fetch Error: \(error.localizedDescription)")
        }
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
            
            let errorMessage = "StartShiftModalTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"merge that"])
            }
            getTheUserFDResources()
            self.tableView.reloadData()

        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "StartShiftModalTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
}

extension StartShiftModalTVC: FDResourceEditVCDelegate {
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

extension StartShiftModalTVC: FDResourceCustomEditVCDelegate {
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

extension StartShiftModalTVC: PlatoonsVCDelegate {
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
