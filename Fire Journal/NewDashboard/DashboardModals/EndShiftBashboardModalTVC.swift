//
//  EndShiftBashboardModalTVC.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/30/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

protocol EndShiftDashboardModalTVCDelegate: AnyObject {
    func endShiftSave(shift: MenuItems, EndShift: EndShiftData)
    func endShiftCancel()
}

class EndShiftBashboardModalTVC: UITableViewController {
    //    MARK: -PROPERTIES-
    weak var delegate: EndShiftDashboardModalTVCDelegate? = nil
    var alertUp: Bool = false
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    var objectID:NSManagedObjectID!
    
    //    MARK: -STRUCTS-
    var endShiftStructure: EndShiftData!
    var theUser: UserEntryInfo!
    var endShift = EndShift.init(endTime: "")
    
    //    MARK: -DATA-
    var fjUserTime:UserTime!
    var fju:FireJournalUser!
    var fjuFireStationAddress: String = ""
    var fetched:Array<Any>!
    var supervisorAttendee: UserAttendees!
    
    //    MARK: -BOOL-
    var showPicker: Bool = false
    var updateCV: Bool = false
    var discussionHeight: CGFloat = 110
    var shiftAMorRelief = false
    var relieveOrSupervisor: String = ""
    var relievedByGuid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        endShiftStructure = EndShiftData.init()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        endShiftStructure.esAMReliefDefaultT = shiftAMorRelief
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
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "SwitchCenteredTVCell", bundle: nil), forCellReuseIdentifier: "SwitchCenteredTVCell")
        tableView.register(UINib(nibName: "DateTimeTVCell", bundle: nil), forCellReuseIdentifier: "DateTimeTVCell")
        tableView.register(UINib(nibName: "SubjectLabelTextFieldIndicatorTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldIndicatorTVCell")
        tableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ShiftModalHeaderV", owner: self, options: nil)?.first as! ShiftModalHeaderV
        headerV.delegate = self
        headerV.subjectL.text = "End\nShift"
        headerV.iconIV.image = UIImage(named: "ICONS_endShift")
        headerV.infoB.tintColor = UIColor(named: "FJRedColor")
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
        return 5
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
        case 3:
            return 88
        case 4:
            if discussionHeight == 110 {
                discussionHeight = getDiscussionHeight()
            }
            return discussionHeight
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCenteredTVCell", for: indexPath) as! SwitchCenteredTVCell
            cell.centerSwitch.tintColor = UIColor(named: "FJRedColor")
            cell.centerSwitch.isOn = shiftAMorRelief
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeTVCell", for: indexPath) as! DateTimeTVCell
            cell.subjectL.text = "Date/Time"
            cell.dateTimeB.tintColor = UIColor(named: "FJRedColor")
            let theDate = endShiftStructure.esDateTime
            let stringDate = vcLaunch.fullDateString(date: theDate)
             cell.dateTimeTF.text = stringDate
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell.subjectL.text = "Relieved By"
            cell.indicatorB.tintColor = UIColor(named: "FJRedColor")
            cell.subjectTF.text = endShiftStructure.esRelieving
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextViewTVCell", for: indexPath) as! SubjectLabelTextViewTVCell
            cell.subjectL.text = "Discussion"
            if endShiftStructure.esDiscussion != "" {
                cell.subjectTV.text = endShiftStructure.esDiscussion
            }
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.item
        switch row {
        case 3:
            relieveOrSupervisor = "Relieve"
            presentCrew(menuType: MenuItems.endShift, title: "Relieving", type: IncidentTypes.crew)
        default:
            break
        }
    }
    
}

extension EndShiftBashboardModalTVC: DateTimeTVCellDelegate {
    func dateTimeBTapped() {
        showPicker.toggle()
        let indexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension EndShiftBashboardModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        endShiftStructure.esDateTime = date
        let indexPath = IndexPath(row: 1, section: 0)
        let indexPath2 = IndexPath(row: 2, section: 0)
        showPicker.toggle()
        tableView.reloadRows(at: [indexPath,indexPath2], with: .automatic)
    }
}

extension EndShiftBashboardModalTVC: SwitchCenteredTVCellDelegate {
    func switchCenteredHasBeenTapped(switchB: Bool) {
        shiftAMorRelief.toggle()
        endShiftStructure.esAMReliefDefaultT = shiftAMorRelief
    }
}

extension EndShiftBashboardModalTVC: RelieveSupervisorModalTVCDelegate {
func relieveSupervisorModalCancel() {
    self.dismiss(animated: true, completion: nil)
}

func relieveSupervisorModalSave(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
    let crew = relieveSupervisor.first
    if !relieveOrSupervisor {} else {
        endShiftStructure.esRelieving = crew?.attendee ??  ""
        relievedByGuid = crew?.attendeeGuid ?? ""
        let indexPath = IndexPath(row: 3, section: 0)
        supervisorAttendee = crew
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    self.dismiss(animated: true, completion: nil)
}
}

extension EndShiftBashboardModalTVC:  NSFetchedResultsControllerDelegate {
    // MARK: -DATA-
    //    MARK: -PRESENT THE CONTACTS-
    //    MARK: -presentCrew for startShift
    func presentCrew(menuType:MenuItems, title:String, type:IncidentTypes){
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisorModal", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorModalTVC") as! RelieveSupervisorModalTVC
        dataTVC.delegate = self
        if relieveOrSupervisor == "Relieve" {
            dataTVC.relieveOrSupervisor = true
            dataTVC.headerTitle = "Relieved By"
        } else if relieveOrSupervisor == "Supervisor" {
            dataTVC.relieveOrSupervisor = false
            dataTVC.headerTitle = "Supervisor"
        }
        dataTVC.menuType = MenuItems.endShift
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    //    MARK: -DISCUSSION HEIGHT-
    //    MARK: -HEIGHT FOR UITEXTVIEW
    private func getDiscussionHeight() ->CGFloat {
        if endShiftStructure.esDiscussion != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = endShiftStructure.esDiscussion
            let estimatedSize = textView.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 110
            if discussionHeight < 110 {
                discussionHeight = 110
            }
        }
        return discussionHeight
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
                    
                    endShiftStructure.esPlatoonB = true
                    endShiftStructure.esPlatoon = "Default"
                    
                    
                    if let platoon = fju.platoon {
                        endShiftStructure.esPlatoonTF = platoon
                    }
                    
                    endShiftStructure.esApparatusB = true
                    endShiftStructure.esApparatus = "Default"
                    if let apparatus = fju.initialApparatus {
                        endShiftStructure.esApparatusTF = apparatus
                    }
                    
                    endShiftStructure.esAssignmentB = true
                    endShiftStructure.esAssignment = "Default"
                    if let assignment = fju.initialAssignment {
                        endShiftStructure.esAssignmentTF = assignment
                    }
                    
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
                        
                        /// location unarchived from secureCodeing
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
                    
                    if let fireStation = fju.fireStation {
                        endShiftStructure.esFireStationTF = fireStation
                    }
                    
                } catch let error as NSError {
                    print("UpdateShiftModalTVC line 248 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("UpdateShiftModalTVC line 253 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -SAVE-
    private func saveEndShift(){
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
        let journalTitle = "End Shift \(sDate)"
        fjuJournal.journalHeader = journalTitle
        var endShift:String = ""
        if endShiftStructure.esAMReliefDefaultT {
            endShift = "AM Relief"
        } else {
            endShift = "Overtime"
        }
        let overview:String = "End Shift:\n\(endShift)\nDate/Time:\(sDate)\nRelieving:\(endShiftStructure.esRelieving)\nDisscussion:\(endShiftStructure.esDiscussion)\n\nFire Station:\(endShiftStructure.esFireStationTF)\nAddress:\(fjuFireStationAddress)"
        fjuJournal.journalOverview = overview as NSObject
        
        fjuJournal.journalTempFireStation = endShiftStructure.esFireStationTF
        fjuJournal.journalFireStation = endShiftStructure.esFireStationTF
        fjuJournal.journalTempPlatoon = endShiftStructure.esPlatoonTF
        fjuJournal.journalTempApparatus = endShiftStructure.esApparatusTF
        fjuJournal.journalTempAssignment = endShiftStructure.esAssignmentTF
        
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
        
        fjuJournal.journalPrivate = true
        
        let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        fjuJournal.addToJournalTagDetails(fjuJournalTags)
        
        
        fju.tempFireStation = endShiftStructure.esFireStationTF
        if fju.fireStation == "" {
            fju.fireStation  = endShiftStructure.esFireStationTF
        }
        fju.fjpUserModDate = journalModDate
        fju.fjpUserBackedUp = false
        fjuJournal.fireJournalUserInfo = fju
        
        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            fjUserTime.endShiftStatus = endShiftStructure.esAMReliefDefaultT
            fjUserTime.enShiftRelievedBy = endShiftStructure.esRelieving
            fjUserTime.endShiftDiscussion = endShiftStructure.esDiscussion
            fjUserTime.userEndShiftTime = endShiftStructure.esDateTime
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
            print("EndShiftModalTVC line 305 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"EndShiftModal TVC merge that"])
            }
            
            let entity = "UserTime"
            let attribute = "userTimeGuid"
            let sort = "userStartShiftTime"
            getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                        object: nil,
                        userInfo: ["objectID":self.objectID as NSManagedObjectID])
            }
            
        } catch let error as NSError {
            print("ModalTVC line 1679 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -GET LAST SAVED-
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
               print("EndShiftModalTVC line 108 Fetch Error: \(error.localizedDescription)")
           }
       }
    
}

extension EndShiftBashboardModalTVC: ShiftModalHeaderVDelegate {
    func shiftModalSaveBTapped() {
        saveEndShift()
        let entity = "UserTime"
        let attribute = "userTimeGuid"
        let sort = "userStartShiftTime"
        getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkENDSHIFTFORDASH),
                    object: nil,
                    userInfo: ["endShift":self.endShiftStructure!])
        }
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                    object: nil,
                    userInfo: ["objectID":self.objectID!])
        }
        delegate?.endShiftSave(shift: MenuItems.endShift, EndShift: endShiftStructure )
    }
    
    func shiftModalCancelBTapped() {
        delegate?.endShiftCancel()
    }
    
    func shiftModalInfoBTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let message: InfoBodyText = .endShiftRecorded
        let title: InfoBodyText = .endShiftRecordedSubject
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
}

extension EndShiftBashboardModalTVC: SubjectLabelTextViewTVCellDelegate {
    func subjectLabelTextViewEditing(text: String) {
        endShiftStructure.esDiscussion = text
    }
    
    func subjectLabelTextViewDoneEditing(text: String) {
        self.resignFirstResponder()
        endShiftStructure.esDiscussion = text
        updateTheTextViewCell()
    }
    
    func updateTheTextViewCell() {
        let indexPath = IndexPath(row: 4, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SubjectLabelTextViewTVCell
        let size = CGSize(width: cell.subjectTV.frame.width, height: .infinity)
        cell.subjectTV.text = endShiftStructure.esDiscussion
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
