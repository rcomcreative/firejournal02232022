//
//  PersonalNewEntryModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/19/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CloudKit
import CoreData
import MapKit
import CoreLocation

protocol PersonalNewEntryModalTVCDelegate: AnyObject {
    func dismissPJModalTapped(shift: MenuItems)
    func personalJournalModalSaved(id:NSManagedObjectID,shift:MenuItems)
}

class PersonalNewEntryModalTVC: UITableViewController {

    //    MARK: PROPERTIES
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    weak var delegate: PersonalNewEntryModalTVCDelegate? = nil
    
    //    MARK: DATA
    var fju:FireJournalUser!
    var fetched:Array<Any>!
    var journalStructure: JournalData!
    var modalTitle: InfoBodyText = .newPersonalEntrySubject
    var modalInstructions: InfoBodyText = .newPersonalEntry
    var alertUp: Bool = false
    var showPicker: Bool = false
    var segmentType: MenuItems = .personal
    var userChanged:Bool = false
    let entity = "Journal"
    let attribute = "journalDateSearch"
    let sort = "journalCreationDate"
    var objectID:NSManagedObjectID!
    var overViewHeight: CGFloat = 220
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        registerCells()
        roundViews()
        journalStructure = JournalData.init()
        journalStructure.journalPrivatePublic = false
        getTheUser()
        setUpJournal()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    //    MARK: -RegisterCells
     ///RegisterCells
     private func registerCells() {
        tableView.register(UINib(nibName: "startShiftOvertimeSwitchCell", bundle: nil), forCellReuseIdentifier: "startShiftOvertimeSwitchCell")
         tableView.register(UINib(nibName: "LabelWithInfoCell", bundle: nil), forCellReuseIdentifier: "LabelWithInfoCell")
         tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
         tableView.register(UINib(nibName: "JournalSegmentCell", bundle: nil), forCellReuseIdentifier: "JournalSegmentCell")
         tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
         tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
         tableView.register(UINib(nibName: "LabelTextViewCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
         tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
         tableView.register(UINib(nibName: "LabelTextFieldWithDirectionCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldWithDirectionCell")
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
    
    //    MARK: -journalOverview resize UITextView
    private func getOverViewSize()->CGFloat {
        if journalStructure.journalOverview != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: overViewHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = journalStructure.journalOverview
            let estimatedSize = textView.sizeThatFits(size)
            
            overViewHeight = estimatedSize.height + 110
        }
        return overViewHeight
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
           headerV.modalHTitleL.text = ""
           let color = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1.0)
           headerV.contentView.backgroundColor = color
           headerV.myShift = MenuItems.journal
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
         return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
            case 0:
                return 44
            case 1:
                return 44
            case 2:
                return 85
            case 3:
                return 80
            case 4:
                if(showPicker) {
                    return 132
                } else {
                    return 0
                }
            case 5:
                if overViewHeight == 220 {
                    overViewHeight = getOverViewSize()
                }
                return overViewHeight
            case 6:
                return 85
            default: return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelWithInfoCell", for: indexPath) as! LabelWithInfoCell
            cell.subjectL.text = modalTitle.rawValue
            let color = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1.0)
            cell.infoB.tintColor = color
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
            cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.35)
            cell.amOrOvertimeSwitch.layer.cornerRadius = 16
            cell.startOrEndB = journalStructure.journalPrivatePublic
            cell.startOrEndB = false
            cell.amOrOvertimeSwitch.setOn(cell.startOrEndB,animated:true)
            cell.amOrOvertimeSwitch.isHidden = true
            cell.amOrOvertimeSwitch.alpha = 0.0
            cell.amOrOvertimeL.text = "Private"
            cell.myShift = MenuItems.personal
            cell.amOrOvertimeL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.delegate = self
            cell.theShift = MenuItems.journal
            cell.subjectL.text = "Topic/Title"
            if journalStructure.journalTitle != "" {
                cell.descriptionTF.text = journalStructure.journalTitle
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Roll Call",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            if journalStructure.journalCreationDate == "" {
                let myShift = MenuItems.journal
                journalStructure.journalCreationDate = journalTimeChosenDate(date:Date(), myShift: myShift)
            }
            cell.dateTimeTV.text = journalStructure.journalCreationDate
            cell.dateTimeL.text = "Date/Time"
            let image = UIImage(named: "ICONS_TimePiece")
            cell.dateTimeB.setImage(image, for: .normal)
            cell.type = IncidentTypes.journal
//            cell.dateTimeTV.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            cell.datePicker.tintColor = .systemBlue
        return cell
        case 5:
                   let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                   cell.delegate = self
                   cell.myShift = MenuItems.journal
                   cell.journalType = JournalTypes.overview
                   cell.subjectL.text = "Overview"
                   cell.descriptionTV.text = journalStructure.journalOverview
                   return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.delegate = self
            cell.theShift = MenuItems.journal
            cell.subjectL.text = "User"
            if journalStructure.journalUser != "" {
                cell.descriptionTF.text = journalStructure.journalUser
            } else {
                cell.descriptionTF.placeholder = "Mark Smith"
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    

}

extension PersonalNewEntryModalTVC: LabelTextViewCellDelegate {
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
            journalStructure.journalOverview = text

            let indexPath = IndexPath(row: 5, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
            let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
            let estimatedSize = cell.descriptionTV.sizeThatFits(size)
            
            overViewHeight = estimatedSize.height + 52.5
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
            journalStructure.journalOverview = text

            let indexPath = IndexPath(row: 5, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
            let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
            let estimatedSize = cell.descriptionTV.sizeThatFits(size)
            
            overViewHeight = estimatedSize.height + 52.5
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
        // MARK: TODO
    }
    
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {
        // MARK: TODO
    }
}

extension PersonalNewEntryModalTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        let myShift = MenuItems.journal
        if showPicker {
            showPicker = false
                if journalStructure.journalCreationDate == "" {
                    journalStructure.journalCreationDate = journalTimeChosenDate(date:Date(), myShift: myShift)
                }
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
    func journalTimeChosenDate(date: Date, myShift: MenuItems)->String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
           let journalDate = dateFormatter.string(from: date)
           return journalDate
       }
}

extension PersonalNewEntryModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
               let dateFrom = dateFormatter.string(from: date)
                   journalStructure.journalDate = date
                   journalStructure.journalCreationDate = dateFrom
               tableView.reloadData()
    }
    func chosenFromDate(date: Date) {}
    func chosenActivityDate(date: Date) {}
    func chosenSignatureDate(date: Date) {}
    func chosenIncidentDate(date: Date) {}
}

extension PersonalNewEntryModalTVC: LabelTextFieldCellDelegate {
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
         journalStructure.journalTitle = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        journalStructure.journalTitle = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
}

extension PersonalNewEntryModalTVC: LabelWithInfoCellDelegate {
    func theInfoBTapped() {
        if !alertUp {
            let alert = UIAlertController.init(title: modalTitle.rawValue, message: modalInstructions.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension PersonalNewEntryModalTVC {
    
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
                    if !fetched.isEmpty {
                        fju = fetched.last as? FireJournalUser
                        journalStructure.journalUser = fju.userName ?? ""
                        journalStructure.journalFireStation = fju.fireStation ?? ""
                        journalStructure.journalPlatoon = fju.tempPlatoon ?? ""
                        journalStructure.journalAssignment = fju.tempAssignment ?? ""
                        journalStructure.journalApparatus = fju.tempApparatus ?? ""
                    }
                } catch let error as NSError {
                    print("JournalModalTV line 69 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("ModalTVC line 1806 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
        //    MARK: -SetUpJournal
    private func setUpJournal() {
        self.title = "Journal"
        var address = ""
        if fju != nil {
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
        }
    }
    
}

extension PersonalNewEntryModalTVC: ModalHeaderSaveDismissDelegate {
    
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    
    func modalDismiss() {
        delegate?.dismissPJModalTapped(shift: MenuItems.personal)
    }

    func modalSave(myShift: MenuItems) {
        let count = 2
        let indexPath = IndexPath(row: count, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextFieldCell
        _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
         if journalStructure.journalTitle == "" {
                   if !alertUp {
                    let title: InfoBodyText = .journalEntryErrorSubject
                    let message: InfoBodyText = .journalEntryError
                    let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
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
           }
           
           //    MARK: -SAVE THE JOURNAL ENTRY
           /// SaveTheJournal builds JournalModal
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
                       
//            MARK: -LOCATION-
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
                       
                       fjuJournal.journalCreationDate = journalModDate
                       fjuJournal.journalModDate = journalModDate
                       fjuJournal.journalDateSearch = sDate
                       fjuJournal.fjpIncReference = ""
                       fjuJournal.fjpUserReference = fju.userGuid
                       fjuJournal.journalOverview = journalStructure.journalOverview as NSObject
                       fjuJournal.journalTempPlatoon = journalStructure.journalPlatoon
                       fjuJournal.journalTempApparatus = journalStructure.journalApparatus
                       fjuJournal.journalTempAssignment = journalStructure.journalAssignment
                       fjuJournal.journalTempFireStation = journalStructure.journalFireStation
                       fjuJournal.journalFireStation = journalStructure.journalFireStation
                       fjuJournal.journalBackedUp = false
                       fjuJournal.journalPhotoTaken = false
                       
            //            MARK: -LOCATION-
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
                       self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"JournalModalTVC merge that"])
                   }
                   
                       
                       getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
                   
                       DispatchQueue.main.async {
                           nc.post(name:Notification.Name(rawValue:FJkCKNewJournalCreated),
                                   object: nil,
                                   userInfo: ["objectID":self.objectID!])
                       }
                   delegate?.personalJournalModalSaved(id: objectID, shift: MenuItems.personal)
                  
               } catch let error as NSError {
                   print("PersaonalNewEntryModalTVC line 588 Fetch Error: \(error.localizedDescription)")
               }
           }
    
    private func getTheLastSaved(entity:String,attribute:String,sort:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", attribute, "")
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
            print("PersonalNewEntryModalTVC line 608 Fetch Error: \(error.localizedDescription)")
        }
    }
}
