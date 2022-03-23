//
//  IncidentPOVNotesTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/2/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData


protocol IncidentPOVNotesDelegate: AnyObject {
    func incidentPOVNotesCanceled()
    func incidentPOVNotesSaved(data:IncidentData)
}

class IncidentPOVNotesTVC: UITableViewController,NSFetchedResultsControllerDelegate {
    
    var incidentStructure: IncidentData!
    var journalStructure: JournalData!
    //    MARK: Objects
    var modalTitle: String = ""
    var modalInstructions: String = ""
    let userDefaults = UserDefaults.standard
    var fjUserTime:UserTime! = nil
    var fju:FireJournalUser!
    var journal:Journal!
    var incident:Incident!
    weak var delegate: IncidentPOVNotesDelegate? = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //    MARK: -PROPERTIES
    var showPicker:Bool = false
    var fetched:Array<Any>!
    var objectID:NSManagedObjectID!
    var guidOrNot: Bool = false
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var fjIncident:Incident!
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var timeStamped: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        roundViews()
        registerCells()
        
        journalStructure = JournalData.init()
        
        self.title = ""
        modalTitle = "Incident Support Journal Entry"
        modalInstructions = "Use this journal entry for any comments or notes that should be independent and confidential from any incident you’re responding to.\n\nUse the incident notes for public comments.Use this form to create a private journal entry, and add as many additional notes relative to the incident as may be required. All entries will be time stamped."
        
        getTheUser()
        if guidOrNot {
            getTheJournalEntry()
        }
        if incidentStructure.incidentGuid != "" {
            getTheIncident()
            journalStructure.journalPrivatePublic = false
            journalStructure.journalPrivatePublicText = "Private"
            journalStructure.journalType = "Station"
        }
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)

    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "ControllerLabelCell", bundle: nil), forCellReuseIdentifier: "ControllerLabelCell")
        tableView.register(UINib(nibName: "LabelTextViewCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
        tableView.register(UINib(nibName: "LabelTextFieldCell",bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "LabelCell",bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.register(UINib(nibName: "TextViewCell",bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UINib(nibName: "startShiftOvertimeSwitchCell",bundle: nil), forCellReuseIdentifier: "startShiftOvertimeSwitchCell")
        tableView.register(UINib(nibName: "LabelTextViewTimeStampCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewTimeStampCell")
        tableView.register(UINib(nibName: "DatePickerCell",bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "LabelDateTimeButtonCell",bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    

    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHTitleL.text = ""
        let color = ButtonsForFJ092018.fillColor38

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
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 44
        case 1:
            return 145
        case 2:
            return 30
        case 3:
            return 85
        case 4:
            return 80
        case 5:
            if(showPicker) {
                return 132
            } else {
                return 0
            }
        case 6:
            if(guidOrNot) {
                return 400
            } else {
                return 250
            }
        case 7:
            return 85
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            if Device.IS_IPHONE {
                cell.modalTitleL.font = cell.modalTitleL.font.withSize(20)
                cell.modalTitleL.adjustsFontSizeToFitWidth = true
                cell.modalTitleL.setNeedsDisplay()
            }
            cell.modalTitleL.text = modalTitle
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.modalInstructions.text = modalInstructions
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
            cell.delegate = self
            cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
            cell.amOrOvertimeSwitch.layer.cornerRadius = 16
            cell.startOrEndB = false
            cell.amOrOvertimeSwitch.setOn(cell.startOrEndB,animated:true)
            cell.amOrOvertimeSwitch.isHidden = true
            cell.amOrOvertimeSwitch.alpha = 0.0
            cell.amOrOvertimeL.text = "Private"
            cell.amOrOvertimeL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.delegate = self
            cell.theShift = MenuItems.personal
            cell.subjectL.text = "Topic/Title"
            cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            if journalStructure.journalTitle != "" {
                cell.descriptionTF.text = journalStructure.journalTitle
            } else {
                var incidentNum = ""
                var incidentDateTime = ""
                let incidentPOV = "POV Notes"
                let num: String? = incidentStructure.incidentNumber
                if let number = num {
                    incidentNum = number
                }
                let dt: String? = incidentStructure.incidentFullAlarmDateS
                if let dateTime = dt {
                    incidentDateTime = dateTime
                }
                cell.descriptionTF.text = "Incident #\(incidentNum) \(incidentDateTime) \(incidentPOV)"
                journalStructure.journalTitle = "Incident #\(incidentNum) \(incidentDateTime) \(incidentPOV)"
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            var incidentDate = ""
            if journalStructure.journalCreationDate == "" {
                incidentDate = incidentStructure.incidentFullAlarmDateS
            } else {
                incidentDate = journalStructure.journalCreationDate
            }
            cell.dateTimeTV.text = incidentDate
            cell.dateTimeL.text = "Date/Time"
            let image = UIImage(named: "ICONS_TimePiece red")
            cell.dateTimeB.setImage(image, for: .normal)
            cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            cell.type = IncidentTypes.personal
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewTimeStampCell", for: indexPath) as! LabelTextViewTimeStampCell
            cell.delegate = self
            cell.myShift = MenuItems.personal
            cell.descriptionTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            if !guidOrNot {
                cell.journalType = JournalTypes.overview
                cell.subjectL.text = "Overview"
                cell.descriptionTV.text = journalStructure.journalOverview
                cell.timeB.isHidden = true
                cell.timeB.alpha = 0.0
                cell.timeB.isEnabled = false
            } else {
                cell.journalType = JournalTypes.discussion
                cell.subjectL.text = "Discussion"
                cell.descriptionTV.text = journalStructure.journalDiscussion
                let image = UIImage.init(named: "ICONS_TimePiece red")
                cell.timeB.setImage(image, for: .normal)
                cell.timeB.isHidden = false
                cell.timeB.alpha = 1.0
                cell.timeB.isEnabled = true
                timeStamped = false
            }
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.delegate = self
            cell.theShift = MenuItems.personal
            cell.subjectL.text = "User"
            cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            if journalStructure.journalUser != "" {
                cell.descriptionTF.text = journalStructure.journalUser
            } else {
                cell.descriptionTF.placeholder = "Mark Smith"
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! startShiftOvertimeSwitchCell
            return cell
        }
        
    }

}

extension IncidentPOVNotesTVC {
    
    private func getTheJournalEntry() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal")
        var predicate = NSPredicate.init()
        let guid = incidentStructure.incidentPersonalJournalReference
        predicate = NSPredicate(format: "%K == %@","fjpJGuidForReference", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let count = try context.count(for:fetchRequest)
            if count != 0 {
                do {
                    fetched = try context.fetch(fetchRequest) as! [Journal]
                    journal = fetched.last as? Journal
                    journalStructure.journalUser = fju.userName ?? ""
                    journalStructure.journalFireStation = fju.fireStation ?? ""
                    journalStructure.journalPlatoon = fju.tempPlatoon ?? ""
                    journalStructure.journalAssignment = fju.tempAssignment ?? ""
                    journalStructure.journalApparatus = fju.tempApparatus ?? ""
                    journalStructure.journalPrivatePublicText = "PRIVATE"
                    journalStructure.journalTitle = journal.journalHeader ?? ""
                    journalStructure.journalCreationDate = journal.journalDateSearch ?? ""
                    journalStructure.journalDiscussion = journal.journalDiscussion as? String ?? ""
                } catch let error as NSError {
                    print("IncidentPOVNotesTVC line 303 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("IncidentPOVNotesTVC line 308 Fetch Error: \(error.localizedDescription)")
        }
        
    }
    
    private func getTheIncident() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident")
        var predicate = NSPredicate.init()
        let guid = incidentStructure.incidentGuid
        predicate = NSPredicate(format: "%K == %@","fjpIncGuidForReference", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let count = try context.count(for:fetchRequest)
            if count != 0 {
                do {
                    fetched = try context.fetch(fetchRequest) as! [Incident]
                    incident = fetched.last as? Incident
                    
                } catch let error as NSError {
                    print("IncidentPOVNotesTVC line 333 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("IncidentPOVNotesTVC line 338 Fetch Error: \(error.localizedDescription)")
        }
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
                    journalStructure.journalUser = fju.userName ?? ""
                    journalStructure.journalFireStation = fju.fireStation ?? ""
                    journalStructure.journalPlatoon = fju.tempPlatoon ?? ""
                    journalStructure.journalAssignment = fju.tempAssignment ?? ""
                    journalStructure.journalApparatus = fju.tempApparatus ?? ""
                    
                } catch let error as NSError {
                    print("IncidentPOVNotesTVC line 366 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("IncidentPOVNotesTVC line 371 Fetch Error: \(error.localizedDescription)")
        }
    }
}

extension IncidentPOVNotesTVC: StartShiftOvertimeSwitchDelegate {
    func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems) {
        //        MARK:<#code#>
    }
}

extension IncidentPOVNotesTVC: ModalHeaderSaveDismissDelegate {
    

    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    


    func modalDismiss() {
        delegate?.incidentPOVNotesCanceled()
    }
    
    func modalSave(myShift: MenuItems) {
        if guidOrNot {
            journal.journalHeader = journalStructure.journalTitle
            journal.journalDateSearch = journalStructure.journalCreationDate
            journal.journalDiscussion = journalStructure.journalDiscussion as NSObject
            saveToCD()
        } else {
            
            let username = fju.userName ?? ""
            let timeStamp = vcLaunch.timeStamp(date: Date(), user: username)
            let indexPath = IndexPath(row: 6, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
            journalStructure.journalOverview = cell.descriptionTV.text
            let text = journalStructure.journalOverview
            journalStructure.journalOverview = "\(text) \n\(timeStamp)"
            
            let journalModDate = Date()
            createThePOVGuid(modDate: journalModDate)
            let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
            
            fjuJournal.fjpJGuidForReference = journalStructure.journalGuid
            fjuJournal.fjpIncReference = journalStructure.journalIncidentGuid
            fjuJournal.fjpUserReference = fju.userGuid
            fjuJournal.journalHeader = journalStructure.journalTitle
            let searchDate = FormattedDate.init(date:journalModDate)
            _ = searchDate.formatTheDate()
            fjuJournal.journalStreetNumber = incidentStructure.incidentStreetNum
            fjuJournal.journalStreetName = incidentStructure.incidentStreetName
            fjuJournal.journalCity = incidentStructure.incidentCity
            fjuJournal.journalState = incidentStructure.incidentState
            fjuJournal.journalZip = incidentStructure.incidentZip
            
//            MARK: -LOCATION-
            /// journalLocation archived by secureCoding
            if  incidentStructure.incidentLocation != nil {
                if let location = incidentStructure.incidentLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        fjuJournal.journalLocationSC = data as NSObject
                    } catch {
                        print("got an error here")
                    }
                }
            }
            fjuJournal.journalPrivate = journalStructure.journalPrivatePublic
            fjuJournal.journalEntryType = journalStructure.journalType
            fjuJournal.journalEntryTypeImageName = "ICONS_BBLUELOCK"
            fjuJournal.journalCreationDate = journalModDate
            fjuJournal.journalModDate = journalModDate
            fjuJournal.journalDateSearch = journalStructure.journalCreationDate
            
            fjuJournal.journalOverview = journalStructure.journalOverview as NSObject
            fjuJournal.journalDiscussion = journalStructure.journalDiscussion as NSObject
            fjuJournal.journalNextSteps = journalStructure.journalNextSteps as NSObject
            fjuJournal.journalSummary = journalStructure.journalSummary as NSObject
            fjuJournal.journalTempPlatoon = journalStructure.journalPlatoon
            fjuJournal.journalTempApparatus = journalStructure.journalApparatus
            fjuJournal.journalTempAssignment = journalStructure.journalAssignment
            fjuJournal.journalTempFireStation = journalStructure.journalFireStation
            fjuJournal.journalFireStation = journalStructure.journalFireStation
            fjuJournal.journalBackedUp = false
            fjuJournal.journalPhotoTaken = false
            
            let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
            fjuJournal.addToJournalTagDetails(fjuJournalTags)
            
            fjuJournal.fireJournalUserInfo = fju
            
            incident.fjpPersonalJournalReference = incidentStructure.incidentPersonalJournalReference
            
            fjuJournal.incidentDetails = incident
            
            saveToCD()
            
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"IncidentPOVNotesTVC merge that"])
            }
                let entity = "Journal"
                let attribute = "journalDateSearch"
                let sort = "journalCreationDate"
                getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKNewJournalCreated),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
            
            delegate?.incidentPOVNotesSaved(data: incidentStructure)
            
        } catch let error as NSError {
            print("IncidentPOVNotesTV line 470 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func getTheLastSaved(entity:String,attribute:String,sort:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value: false))
        let sectionSortDescriptor = NSSortDescriptor(key: sort, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [Journal]
                let journal = self.fetched.last as! Journal
                self.objectID = journal.objectID
        } catch let error as NSError {
            print("IncidentPOVNotesTVC line 490 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func createThePOVGuid(modDate: Date) {
        let jGuidDate = GuidFormatter.init(date:modDate)
        let jGuid:String = jGuidDate.formatGuid()
        incidentStructure.incidentPersonalJournalReference = "01.INCPOV."+jGuid
        journalStructure.journalGuid = "01.INCPOV."+jGuid
        journalStructure.journalIncidentGuid = incidentStructure.incidentGuid
    }
    
            
}

extension IncidentPOVNotesTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
    
    func journalTimeChosenDate(date: Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
        let journalDate = dateFormatter.string(from: date)
        return journalDate
    }
}

extension IncidentPOVNotesTVC: LabelTextFieldCellDelegate {
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        journalStructure.journalTitle = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems) {
        journalStructure.journalTitle = text
        tableView.reloadData()
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
        //        MARK:<#code#>
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
        //        MARK:<#code#>
    }
}

extension IncidentPOVNotesTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let journalDate = dateFormatter.string(from: date)
        journalStructure.journalCreationDate = journalDate
        let indexPath = IndexPath(row: 4, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelDateTimeButtonCell
        cell.dateTimeTV.text = journalDate
    }
}

extension IncidentPOVNotesTVC: DatePickerDelegate {
    func alarmTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func arrivalTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func controlledTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func lastUnitTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func nfirsSecMOfficersChosenDate(date: Date, incidentType: IncidentTypes) {
        //        MARK:<#code#>
    }
    
    func nfirsSecMMembersChosenDate(date: Date, incidentType: IncidentTypes) {
        //        MARK:<#code#>
    }
}

extension IncidentPOVNotesTVC: LabelTextViewTimeStampCellDelegate {
    
    func timeStampTapped(type:JournalTypes) {
        timeStamped = true
        let username = fju.userName ?? ""
        let timeStamp = vcLaunch.timeStamp(date: Date(), user: username)
        print(timeStamp)
        switch type {
        case .overview:
            if journalStructure.journalOverview == "" {
                let indexPath = IndexPath(row: 6, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
                _ = cell.textViewShouldEndEditing(cell.descriptionTV)
            }
            let text = journalStructure.journalOverview
            journalStructure.journalOverview = "\(text) \n \(timeStamp)"
        case .discussion:
            let indexPath = IndexPath(row: 6, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
            if journalStructure.journalDiscussion == "" {
                _ = cell.textViewShouldEndEditing(cell.descriptionTV)
                cell.buttonTapped = true
            }
            journalStructure.journalDiscussion = cell.descriptionTV.text
            let text = journalStructure.journalDiscussion
            journalStructure.journalDiscussion = "\(text) \n \(timeStamp)"
            cell.buttonTapped = false
//            timeStamped = false
            tableView.reloadData()
        case .nextSteps:
            let text = journalStructure.journalNextSteps
            journalStructure.journalNextSteps = "\(text) \n \(timeStamp)"
        case .summary:
            let text = journalStructure.journalSummary
            journalStructure.journalSummary = "\(text) \n \(timeStamp)"
        default:
            print("no time")
        }
        tableView.reloadData()
    }
    
    func tsTextViewEdited(text: String, journalType: JournalTypes, myShift: MenuItems) {
        //        MARK:<#code#>
    }
    
    func tsTextViewEndedEditing(text: String, journalType: JournalTypes, myShift: MenuItems) {
        switch journalType {
        case .overview:
            let overview = journalStructure.journalOverview+" "+text
            journalStructure.journalOverview = overview
        case .discussion:
            let indexPath = IndexPath(row: 6, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
            if !timeStamped {
                let discussion = cell.descriptionTV.text
                journalStructure.journalDiscussion = discussion ?? ""
                tableView.reloadData()
            }
        case .nextSteps:
            let nextStep = journalStructure.journalNextSteps+" "+text
            journalStructure.journalNextSteps = nextStep
        case .summary:
            let summary = journalStructure.journalSummary+" "+text
            journalStructure.journalSummary = summary
        default:
            print("none")
        }
    }
    
    
}
