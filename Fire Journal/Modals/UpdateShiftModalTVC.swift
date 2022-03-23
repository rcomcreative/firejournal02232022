//
//  UpdateShiftModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/3/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol UpdateShiftModalTVCDelegate: AnyObject {
    func cancelUpdateShiftCalled()
    func updateShiftSaved(shift: MenuItems, UpdateShift: UpdateShiftData)
}

class UpdateShiftModalTVC: UITableViewController {
    
    //    MARK: PROPERTIES
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    weak var delegate: UpdateShiftModalTVCDelegate? = nil
    var theResourcesCombineString = ""
    
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
    var updateShiftStructure: UpdateShiftData!
    var updateShift = UpdateShift.init(updateTime: "")
    
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
        getTheUserFDResources()
        updateShiftStructure = UpdateShiftData.init()
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
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
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
            print("UpdateShiftModalTVC line 108 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -DISCUSSION HEIGHT
    private func getDiscussionHeight() ->CGFloat {
        if updateShiftStructure.upsDiscussion != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = updateShiftStructure.upsDiscussion
            let estimatedSize = textView.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 110
        }
        return discussionHeight
    }

    
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHTitleL.text = "Update Shift"
        let color = UIColor(red: 0.957, green: 0.518, blue: 0.159, alpha: 1.000)
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
        return 9
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
        if discussionHeight == 110 {
            discussionHeight = getDiscussionHeight()
        }
        return discussionHeight
        case 4:
            return 44
        case 5:
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
        case 6:
            if resourceTapped {
                return 82
            } else {
                return 0
            }
        case 7:
            return 100
        case 8:
           return 120
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let row = indexPath.row
           switch  row {
           case 0:
               let cell = tableView.dequeueReusableCell(withIdentifier: "startShiftOvertimeSwitchCell", for: indexPath) as! startShiftOvertimeSwitchCell
               cell.amOrOvertimeL.text = updateShiftStructure.upsAMReliefDefault
               cell.amOrOvertimeSwitch.onTintColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 1)
               cell.amOrOvertimeSwitch.backgroundColor = UIColor(red: 0.91, green: 0.48, blue: 0.23, alpha: 0.35)
               cell.amOrOvertimeSwitch.layer.cornerRadius = 16
               cell.startOrEndB = updateShiftStructure.upsAMReliefDefaultT
               cell.myShift = MenuItems.updateShift
               cell.delegate = self
               return cell
           case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
                cell.delegate = self
                cell.type = IncidentTypes.fire
                let theDate = updateShiftStructure.upsDateTime
                let stringDate = vcLaunch.fullDateString(date: theDate)
                cell.dateTimeTV.text = stringDate
                updateShift?.updateTime = stringDate
                cell.dateTimeL.text = "Date/Time"
                let image = UIImage(named: "ICONS_TimePiece orange")
                cell.dateTimeB.setImage(image, for: .normal)
                return cell
           case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
                return cell
           case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.delegate = self
                cell.myShift = MenuItems.updateShift
                cell.subjectL.text = "Discussion"
                cell.descriptionTV.text = updateShiftStructure.upsDiscussion
                cell.journalType = .endShift
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.modalTitleL.text = "Station Apparatus Status"
                cell.modalTitleL.font = cell.modalTitleL.font.withSize(24)
                return cell
            case 5:
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
            case 6:
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
           case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldDirectionalSwitchCell", for: indexPath) as! LabelTextFieldDirectionalSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Platoon"
                cell.myShift = MenuItems.updateShift
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
           case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelAnswerSwitchCell", for: indexPath) as! LabelAnswerSwitchCell
                cell.delegate = self
                cell.subjectL.text = "Fire Station"
                cell.myShift = MenuItems.updateShift
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
           default:
               let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
               return cell
           }
    }

}

extension UpdateShiftModalTVC {
    
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
                    updateShiftStructure.upsPlatoonB = true
                    updateShiftStructure.upsPlatoon = "Default"
                    if let platoon = fju.platoon {
                        updateShiftStructure.upsPlatoonTF = platoon
                    }
                    
                    updateShiftStructure.upsFireStationB = true
                    updateShiftStructure.upsFireStation = "Default"
                    if let fireStation = fju.fireStation {
                        updateShiftStructure.upsFireStationTF = fireStation
                    }
                    
                    updateShiftStructure.upsApparatusB = true
                    updateShiftStructure.upsApparatus = "Default"
                    if let apparatus = fju.initialApparatus {
                        updateShiftStructure.upsApparatusTF = apparatus
                    }
                    
                    updateShiftStructure.upsAssignmentB = true
                    updateShiftStructure.upsAssignment = "Default"
                    if let assignment = fju.initialAssignment {
                        updateShiftStructure.upsAssignmentTF = assignment
                    }
                    
                    updateShiftStructure.upsResourcesB = true
                    updateShiftStructure.upsResources = "Front Line"
                    if let resources = fju.defaultResources {
                        updateShiftStructure.upsResourcesTF = resources
                    }
                    
                } catch let error as NSError {
                    print("UpdateShiftModalTVC line 248 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("UpdateShiftModalTVC line 253 Fetch Error: \(error.localizedDescription)")
        }
    }
}

    //  MARK: -FD RESOURCES CELL DELEGATES

extension UpdateShiftModalTVC: StartShiftFDResourcesCellDelegate {
    func aResourceHasBeenTappedForEditing(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = true
//        tableView.reloadData()
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



extension UpdateShiftModalTVC: UserFDResourceCellDelegate {
    func theNotCustomSaveBWasTapped(resource: UserFDResources) {
        fdResource = resource
        resourceTapped = false
        updateCV = true
        saveToCDForUFDResource(objectID: fdResource.objectID)
    }
}

extension UpdateShiftModalTVC: userFDResourcesCustomCellDelegate {
    
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
    func getDiscussion() {
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
        updateShiftStructure.upsDiscussion = cell.descriptionTV.text
    }
    
    private func saveUpdateShift() {
        let resources = buildTheResourcesForJournalEntry()
        if updateShiftStructure.upsDiscussion == "" {
            getDiscussion()
        }
        let resourcesString = resources.reduce("", +)
        updateShiftStructure.upsResourcesCombine = theResourcesCombineString
        updateShiftStructure.upsResourcesTF = resourcesString
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
        let overview:String = "Update Shift:\n\(updateShiftStructure.upsAMReliefDefaultT)\nDate/Time:\(sDate)\nDisscussion:\(updateShiftStructure.upsDiscussion)\nPlatoon:\(updateShiftStructure.upsPlatoonTF) - \(updateShiftStructure.upsPlatoon)\nFire Station:\(updateShiftStructure.upsFireStationTF) - \(updateShiftStructure.upsFireStation)\nResources: \(resourcesString)"
        fjuJournal.journalOverview = overview as NSObject
        
        fjuJournal.journalTempPlatoon = updateShiftStructure.upsPlatoonTF
        fjuJournal.journalTempFireStation = updateShiftStructure.upsFireStationTF
        fjuJournal.journalFireStation = updateShiftStructure.upsFireStationTF
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
        
        fjuJournal.journalPrivate = true
        
        let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        fjuJournal.addToJournalTagDetails(fjuJournalTags)
        
        fju.platoonDefault = updateShiftStructure.upsPlatoonB
        fju.tempPlatoon = updateShiftStructure.upsPlatoonTF
        fju.tempFireStation = updateShiftStructure.upsFireStationTF
        if fju.fireStation == "" {
            fju.fireStation  = updateShiftStructure.upsFireStationTF
        }
        fju.tempResources = updateShiftStructure.upsResourcesCombine
        fju.defaultResources = updateShiftStructure.upsResourcesCombine
        fju.defaultResourcesName = ""
        fju.fjpUserModDate = journalModDate
        fju.fjpUserBackedUp = false
        fjuJournal.fireJournalUserInfo = fju
        
        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            fjUserTime.updateShiftStatus = updateShiftStructure.upsAMReliefDefaultT
            fjUserTime.updateShiftFireStation = updateShiftStructure.upsFireStationTF
            fjUserTime.updateShiftPlatoon = updateShiftStructure.upsPlatoonTF
            fjUserTime.updateShiftResources = updateShiftStructure.upsResourcesCombine
            fjUserTime.updateShiftDiscussion = updateShiftStructure.upsDiscussion
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
        
            
            let indexPath1 = IndexPath(row: 5, section: 0)
            let indexPath2 = IndexPath(row: 6, section: 0)
            tableView.reloadRows(at: [indexPath1,indexPath2], with: .automatic)
            
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

    // MARK: -CELL DELEGATES-
extension UpdateShiftModalTVC: LabelTextViewCellDelegate {
    
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
            updateShiftStructure.upsDiscussion = text

            let indexPath = IndexPath(row: 3, section: 0)
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
            updateShiftStructure.upsDiscussion = text

            let indexPath = IndexPath(row: 3, section: 0)
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


extension UpdateShiftModalTVC: LabelAnswerSwitchCellDelegate {
    func defaultOvertimeSwitchTapped(switched: Bool, type: MenuItems, switchType: SwitchTypes) {
        switch switchType {
        case .fireStation:
            updateShiftStructure.upsFireStationB = switched
            if switched {
                updateShiftStructure.upsFireStation = "Default"
            } else {
                updateShiftStructure.upsFireStation = "Overtime"
            }
        default: break
        }
    }
    
    func answerLEditing(text: String, myShift: MenuItems, switchType: SwitchTypes) {
        //        MARK: TODO
    }
    
    func answerLDidEndEditing(text: String, switchType: SwitchTypes) {
        switch switchType {
        case .fireStation:
            updateShiftStructure.upsFireStationTF = text
        default: break
        }
    }
    
    
}

extension UpdateShiftModalTVC: LabelTextFieldDirectionalSwitchCellDelegate {
    func directionalButTapped(switchType: SwitchTypes, type: MenuItems) {
        switch switchType {
        case .apparatus:
            presentModal(menuType: type, title: "Apparatus", type: .apparatus)
        case .assignment:
            presentModal(menuType: type, title: "Assignment", type: .assignment)
        case .platoon:
            let platoons = getThePlatoons()
                       let storyboard = UIStoryboard(name: "Platoons", bundle: nil)
                       let vc = storyboard.instantiateInitialViewController() as! PlatoonsVC
                       vc.platoons = platoons
                       vc.delegate = self
                       present(vc, animated: true )
        default:break
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
    
    func defaultOvertimeDirectionalSwitchTapped(switched: Bool, type: MenuItems, switchType: SwitchTypes) {
        switch switchType {
        case .apparatus:
            updateShiftStructure.upsApparatusB = switched
        case .assignment:
            updateShiftStructure.upsAssignmentB = switched
        case .platoon:
            updateShiftStructure.upsPlatoonB = switched
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
        modalTVC.myShift = MenuItems.updateShift
        modalTVC.userInfo = type
        modalTVC.modalPresentationStyle = .custom
        self.present(modalTVC, animated: true, completion: nil)
    }
    
}

extension UpdateShiftModalTVC: DataModalTVCDelegate {
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
            updateShiftStructure.upsPlatoonTF = theUser.platoon
            updateShiftStructure.upsPlatoonB = theUser.platoonDefault
        default:
            print("none")
        }
        tableView.reloadData()
    }
}

extension UpdateShiftModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        updateShiftStructure.upsDateTime = date
        tableView.reloadData()
    }
}

extension UpdateShiftModalTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
}

extension UpdateShiftModalTVC: StartShiftOvertimeSwitchDelegate {
    func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems) {
        updateShiftStructure.upsAMReliefDefault = type
        updateShiftStructure.upsAMReliefDefaultT = startOrEnd
    }
}

extension UpdateShiftModalTVC: ModalHeaderSaveDismissDelegate {
    
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    
    func modalDismiss() {
        delegate?.cancelUpdateShiftCalled()
    }
    
    func modalSave(myShift: MenuItems) {
        saveUpdateShift()
        let entity = "UserTime"
        let attribute = "userTimeGuid"
        let sort = "userStartShiftTime"
        getTheLastSaved(entity: entity, attribute: attribute, sort: sort)
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkUPDATESHIFTFORDASH),
                    object: nil,
                    userInfo: ["updateShift":self.updateShiftStructure!])
        }
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkCKMODIFIEDSTARTENDTOCLOUD),
                    object: nil,
                    userInfo: ["objectID":self.objectID!])
        }
        delegate?.updateShiftSaved(shift: MenuItems.updateShift, UpdateShift: updateShiftStructure)
    }
}

extension UpdateShiftModalTVC: PlatoonsVCDelegate {
    func platoonsCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func platoonsVCChosen(platoon: UserPlatoon) {
        theUser.platoon = platoon.platoon ?? ""
        theUser.platoonGuid = platoon.platoonGuid ?? ""
        theUser.platoonDefault = platoon.defaultPlatoon
        updateShiftStructure.upsPlatoonTF = theUser.platoon
        updateShiftStructure.upsPlatoonB = theUser.platoonDefault
        let indexPath = IndexPath(row: 7, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UpdateShiftModalTVC: FDResourceEditVCDelegate {
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

extension UpdateShiftModalTVC: FDResourceCustomEditVCDelegate {
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
