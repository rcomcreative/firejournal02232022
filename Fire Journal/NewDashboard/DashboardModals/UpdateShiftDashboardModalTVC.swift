//
//  UpdateShiftDashboardModalTVC.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/30/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation


protocol UpdateShiftDashboardModalTVCDelegate: AnyObject {
    func updateShiftCancel()
    func updateShiftSave(shift: MenuItems, UpdateShift: UpdateShiftData)
}

class UpdateShiftDashboardModalTVC: UITableViewController {
    
    //    MARK: -PROPERTIES-
    weak var delegate: UpdateShiftDashboardModalTVCDelegate? = nil
    var alertUp: Bool = false
    var context:NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var device:Device!
    var theResourcesCombineString = ""
    var fdResourceCount: Int = 0
    
    var objectID:NSManagedObjectID!
    
    //    MARK: -STRUCTS-
    var theUser: UserEntryInfo!
    var updateShiftStructure: UpdateShiftData!
    var updateShift = UpdateShift.init(updateTime: "")
    
    //    MARK: -DATA-
    var fjUserTime:UserTime!
    var fju:FireJournalUser!
    var fjuFireStationAddress: String = ""
    var fdResources = [UserFDResources]()
    var fdResource: UserFDResources!
    var fetched:Array<Any>!
    var fetchedResources = [UserFDResources]()
    var resources = [UserFDResource]()
    var supervisorAttendee: UserAttendees!
    
    //    MARK: -BOOL-
    var showPicker: Bool = false
    var resourceTapped: Bool = false
    var updateCV: Bool = false
    var discussionHeight: CGFloat = 110
    var shiftAMorRelief = false
    var relieveOrSupervisor: String = ""
    var supervisorGuid: String = ""
    var utGuid: String = ""
    var newSupervisor: Bool = false
    
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
        updateShiftStructure = UpdateShiftData.init()
        updateShiftStructure.upsAMReliefDefaultT = shiftAMorRelief
        theUser = UserEntryInfo.init(user:"")
        roundViews()
        registerCells()
        getTheUser()
        utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID) ?? ""
        theUserTimeCount(entity: "UserTime", guid: utGuid)
        if fjUserTime.updateShiftSupervisor == nil {
            if fjUserTime.startShiftSupervisor == nil { } else {
                if fjUserTime.startShiftSupervisor != "" {
                    updateShiftStructure.upsSupervisor = fjUserTime.startShiftSupervisor!
                }
            }
        } else {
            if fjUserTime.updateShiftSupervisor != "" {
                updateShiftStructure.upsSupervisor = fjUserTime.updateShiftSupervisor ?? ""
            }
        }
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ShiftModalHeaderV", owner: self, options: nil)?.first as! ShiftModalHeaderV
        headerV.delegate = self
        headerV.subjectL.text = "Update\nShift"
        headerV.iconIV.image = UIImage(named: "ICONS_updateShift")
        headerV.infoB.tintColor = UIColor(named: "FJOrangeColor")
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
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 88
        case 1:
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case 2:
            return 88
        case 3:
            return 44
        case 4:
            if fdResources.count != 0 {
                return 240
            } else {
                return 90
            }
        case 5:
            if discussionHeight == 110 {
                discussionHeight = getDiscussionHeight()
            }
            return discussionHeight
        case 6:
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeTVCell", for: indexPath) as! DateTimeTVCell
            cell.subjectL.text = "Date/Time"
            let theDate = updateShiftStructure.upsDateTime
            let stringDate = vcLaunch.fullDateString(date: theDate)
            cell.dateTimeTF.text = stringDate
            cell.dateTimeB.tintColor = UIColor(named: "FJOrangeColor")
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldTVCell", for: indexPath) as! SubjectLabelTextFieldTVCell
            cell.subjectL.text = "Fire Station"
            cell.subjectTF.text = updateShiftStructure.upsFireStationTF
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLCell", for: indexPath) as! SubjectLCell
            cell.subjectL.text = "Station Apparatus Status"
            return cell
        case 4:
            if resources.count != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StartShiftFDResourcesCell", for: indexPath) as! StartShiftFDResourcesCell
                cell.delegate = self
                cell.fdResourcesCount = fdResourceCount
                cell.fdResources = fdResources
                if updateCV {
                    cell.startShiftCV.reloadData()
                    updateCV = false
                }
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
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextViewTVCell", for: indexPath) as! SubjectLabelTextViewTVCell
            cell.subjectL.text = "Discussion"
            if updateShiftStructure.upsDiscussion != "" {
                cell.subjectTV.text = updateShiftStructure.upsDiscussion
            }
            cell.delegate = self
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectLabelTextFieldIndicatorTVCell", for: indexPath) as! SubjectLabelTextFieldIndicatorTVCell
            cell.subjectL.text = "Supervisor"
            cell.subjectTF.text = ""
            if newSupervisor {
                if updateShiftStructure.upsSupervisor != "" {
                    cell.subjectTF.text = updateShiftStructure.upsSupervisor
                }
            } else {
                if updateShiftStructure.upsSupervisor != "" {
                    cell.subjectTF.text = updateShiftStructure.upsSupervisor
                }
            }
            cell.indicatorB.tintColor = UIColor(named: "FJOrangeColor")
            //           cell.subjectTF.text = updateShiftStructure.upsSupervisor
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.item
        switch row {
        case 6:
            relieveOrSupervisor = "Supervisor"
            presentCrew(menuType: MenuItems.startShift, title: "Supervisor", type: IncidentTypes.crew)
        default:
            break
        }
    }
    
    
}

extension UpdateShiftDashboardModalTVC: ShiftModalHeaderVDelegate {
    func shiftModalSaveBTapped() {
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
        delegate?.updateShiftSave(shift: MenuItems.updateShift , UpdateShift: updateShiftStructure)
    }
    
    func shiftModalCancelBTapped() {
        delegate?.updateShiftCancel()
    }
    
    func shiftModalInfoBTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let message: InfoBodyText = .updateShiftSupportNotes
        let title: InfoBodyText = .updateShiftSupportNotesSubject
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension UpdateShiftDashboardModalTVC: RelieveSupervisorModalTVCDelegate {
    func relieveSupervisorModalCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorModalSave(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
        let crew = relieveSupervisor.first
        if relieveOrSupervisor {} else {
            updateShiftStructure.upsSupervisor = crew?.attendee ??  ""
            supervisorGuid = crew?.attendeeGuid ?? ""
            let indexPath = IndexPath(row: 6, section: 0)
            supervisorAttendee = crew
            newSupervisor.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension UpdateShiftDashboardModalTVC: NSFetchedResultsControllerDelegate {
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
        dataTVC.menuType = MenuItems.updateShift
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
    //    MARK: -Data acquisition
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
        let sDate:String = searchDate.formatTheDateAndTime()
        fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        fjuJournal.journalEntryType = "Station"
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fju.userGuid
        let journalTitle = "Update Shift \(sDate)"
        fjuJournal.journalHeader = journalTitle
        
        let overview:String = "Update Shift:\nDate/Time:\(sDate)\nDisscussion:\(updateShiftStructure.upsDiscussion)\nSupervisor:\(updateShiftStructure.upsSupervisor)\nFire Station:\(updateShiftStructure.upsFireStationTF) - \(updateShiftStructure.upsFireStation)\nResources: \(resourcesString)\nAddress:\n\(fjuFireStationAddress)"
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
        
        //        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        //        _ = theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            fjUserTime.userUpdateShiftTime = updateShiftStructure.upsDateTime
            fjUserTime.updateShiftStatus = updateShiftStructure.upsAMReliefDefaultT
            fjUserTime.updateShiftFireStation = updateShiftStructure.upsFireStationTF
            fjUserTime.updateShiftResources = updateShiftStructure.upsResourcesCombine
            fjUserTime.updateShiftDiscussion = updateShiftStructure.upsDiscussion
            fjUserTime.updateShiftSupervisor = updateShiftStructure.upsSupervisor
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"UPDATESHIFT merge that"])
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
    func getDiscussion() {
        let indexPath = IndexPath(row: 5, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SubjectLabelTextViewTVCell
        updateShiftStructure.upsDiscussion = cell.subjectTV.text
    }
    
    //    MARK: -BUILD RESOURCES FOR JOURNAL-
    func buildTheResourcesForJournalEntry()->[String] {
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
            
            
            let indexPath1 = IndexPath(row: 4, section: 0)
            tableView.reloadRows(at: [indexPath1], with: .automatic)
            
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "StartShiftDashboardModalTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    //    MARK: -HEIGHT FOR UITEXTVIEW
    private func getDiscussionHeight() ->CGFloat {
        if updateShiftStructure.upsDiscussion != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = updateShiftStructure.upsDiscussion
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
            print("updateshiftModal line 311 Fetch Error: \(error.localizedDescription)")
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
            print("UpdateShiftModalTVC line 433 Fetch Error: \(error.localizedDescription)")
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
                    updateShiftStructure.upsPlatoonB = true
                    updateShiftStructure.upsPlatoon = "Default"
                    
                    
                    if let platoon = fju.platoon {
                        updateShiftStructure.upsPlatoonTF = platoon
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
                    
                    if let num = fju.fireStationStreetNumber {
                        fjuFireStationAddress = num
                    }
                    if fjuFireStationAddress != "" {
                        if let name = fju.fireStationStreetName {
                            fjuFireStationAddress += name
                        }
                        
                        if let city = fju.fireStationCity {
                            fjuFireStationAddress += " \(city)"
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
                    
                    
                    updateShiftStructure.upsFireStationB = true
                    updateShiftStructure.upsFireStation = "Default"
                    if let fireStation = fju.fireStation {
                        updateShiftStructure.upsFireStationTF = fireStation
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

extension UpdateShiftDashboardModalTVC: DateTimeTVCellDelegate {
    func dateTimeBTapped() {
        showPicker.toggle()
        let indexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension UpdateShiftDashboardModalTVC: DatePickerCellDelegate {
    func chosenToDate(date: Date) {
        updateShiftStructure.upsDateTime = date
        let indexPath = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 1, section: 0)
        showPicker.toggle()
        tableView.reloadRows(at: [indexPath,indexPath2], with: .automatic)
    }
}

extension UpdateShiftDashboardModalTVC: SwitchLeftAlignedTVCellDelegate {
    func switchLeftAlignedHasBeenTapped(switchB: Bool) {
        shiftAMorRelief.toggle()
        updateShiftStructure.upsAMReliefDefaultT = shiftAMorRelief
    }
}

extension UpdateShiftDashboardModalTVC: StartShiftFDResourcesCellDelegate {
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

extension UpdateShiftDashboardModalTVC: FDResourceEditVCDelegate {
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

extension UpdateShiftDashboardModalTVC: FDResourceCustomEditVCDelegate {
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

extension UpdateShiftDashboardModalTVC: SubjectLabelTextViewTVCellDelegate {
    func subjectLabelTextViewEditing(text: String) {
        updateShiftStructure.upsDiscussion = text
    }
    
    func subjectLabelTextViewDoneEditing(text: String) {
        self.resignFirstResponder()
        updateShiftStructure.upsDiscussion = text
        updateTheTextViewCell()
    }
    
    func updateTheTextViewCell() {
        let indexPath = IndexPath(row: 5, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SubjectLabelTextViewTVCell
        let size = CGSize(width: cell.subjectTV.frame.width, height: .infinity)
        cell.subjectTV.text = updateShiftStructure.upsDiscussion
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

