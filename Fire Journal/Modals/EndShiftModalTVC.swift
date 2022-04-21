//
//  EndShiftModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/17/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol EndShiftModalTVCDelegate: AnyObject {
    func endShiftCancelTapped()
    func endShiftUpdated(shift: MenuItems, EndShift: EndShiftData)
}

class EndShiftModalTVC: UITableViewController {
    
    //    MARK: PROPERTIES
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    weak var delegate: EndShiftModalTVCDelegate? = nil
    
    //    MARK: DATA
    var fjUserTime:UserTime! = nil
    var fju:FireJournalUser!
    var fdResources = [UserFDResources]()
    var fdResourceCount: Int = 0
    var fdResourcesA = [String]()
    var fdResource: UserFDResources!
    var fetched:Array<Any>!
    
    var objectID:NSManagedObjectID!
    
    //    MARK: STRUCTS
    var theUser: UserEntryInfo!
    var endShiftStructure: EndShiftData!
    var endShift = EndShift.init(endTime: "")
    
    //    MARK: BOOL
    var showPicker: Bool = false
    var resourceTapped: Bool = false
    var updateCV: Bool = false
    var discussionHeight: CGFloat = 110

    override func viewDidLoad() {
        super.viewDidLoad()
        device = Device.init()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        roundViews()
        registerCellsForTable()
        endShiftStructure = EndShiftData.init()
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
        tableView.register(UINib(nibName: "startShiftOvertimeSwitchCell", bundle: nil), forCellReuseIdentifier: "startShiftOvertimeSwitchCell")
        tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "LabelTextViewCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
    }
    
    //    MARK: -DISCUSSION HEIGHT
    private func getDiscussionHeight() ->CGFloat {
        if endShiftStructure.esDiscussion != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = endShiftStructure.esDiscussion
            let estimatedSize = textView.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 110
        }
        return discussionHeight
    }

    // MARK: - Table view data source
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHTitleL.text = "End Shift"
        let color = UIColor.systemRed
        headerV.contentView.backgroundColor = color
        
        headerV.myShift = MenuItems.personal
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
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
            return 80
        case 2:
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case 3:
                return 85
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
            cell.amOrOvertimeL.text = endShiftStructure.esAMReliefDefault
            cell.amOrOvertimeSwitch.onTintColor = UIColor.systemRed
            cell.amOrOvertimeSwitch.backgroundColor = UIColor.systemRed
            cell.amOrOvertimeSwitch.layer.cornerRadius = 16
            cell.startOrEndB = endShiftStructure.esAMReliefDefaultT
            cell.myShift = MenuItems.endShift
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            cell.type = IncidentTypes.fire
            let theDate = endShiftStructure.esDateTime
            let stringDate = vcLaunch.fullDateString(date: theDate)
            cell.dateTimeTV.text = stringDate
            endShift.endTime = stringDate
            cell.dateTimeL.text = "Date/Time"
            let image = UIImage(named: "ICONS_TimePiece red")
            cell.dateTimeB.setImage(image, for: .normal)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                       cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.delegate = self
            cell.theShift = MenuItems.startShift
            cell.subjectL.text = "Relieved By"
            cell.descriptionTF.text = endShiftStructure.esRelieving
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
            cell.delegate = self
            cell.myShift = MenuItems.endShift
            cell.subjectL.text = "Discussion"
            cell.descriptionTV.text = endShiftStructure.esDiscussion
            cell.journalType = .endShift
            return cell
        default:
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        return cell
        }
    }

}

extension EndShiftModalTVC {
    //    MARK: -GATHER THE DATA
    
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
            delegate?.endShiftUpdated(shift: MenuItems.endShift, EndShift: endShiftStructure)
            
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
                       
                       endShiftStructure.esFireStationB = true
                       endShiftStructure.esFireStation = "Default"
                       if let fireStation = fju.fireStation {
                           endShiftStructure.esFireStationTF = fireStation
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
                       
                       endShiftStructure.esResourcesB = true
                       endShiftStructure.esResources = "Front Line"
                       if let resources = fju.defaultResources {
                           endShiftStructure.esResourcesTF = resources
                       }
                       
                   } catch let error as NSError {
                       print("EndShiftModalTVC line 248 Fetch Error: \(error.localizedDescription)")
                   }
               }
               
           } catch let error as NSError {
               print("EndShiftModalTVC line 253 Fetch Error: \(error.localizedDescription)")
           }
       }
    
}

extension EndShiftModalTVC: LabelTextViewCellDelegate {
    
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
            endShiftStructure.esDiscussion = text

            let indexPath = IndexPath(row: 4, section: 0)
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
            endShiftStructure.esDiscussion = text

            let indexPath = IndexPath(row: 4, section: 0)
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
    
    func textViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {}
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {}
}

extension EndShiftModalTVC: LabelTextFieldCellDelegate {
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        endShiftStructure.esRelieving = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        endShiftStructure.esRelieving = text
    }
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
}

extension EndShiftModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        endShiftStructure.esDateTime = date
        tableView.reloadData()
    }
}

extension EndShiftModalTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
}

extension EndShiftModalTVC: StartShiftOvertimeSwitchDelegate {
    func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems) {
        endShiftStructure.esAMReliefDefault = type
        endShiftStructure.esAMReliefDefaultT = startOrEnd
    }
}

extension EndShiftModalTVC: ModalHeaderSaveDismissDelegate {
    
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    
    
    func modalDismiss() {
        delegate?.endShiftCancelTapped()
    }
    
    func modalSave(myShift: MenuItems) {
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
            delegate?.endShiftUpdated(shift: MenuItems.endShift, EndShift: endShiftStructure)
        }
    
}
