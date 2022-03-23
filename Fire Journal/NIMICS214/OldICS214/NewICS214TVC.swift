//
//  newICS214TVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/6/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData


@objc protocol NewICS214Delegate: AnyObject {
    @objc optional func newICS214Created(date:Date, objectID: NSManagedObjectID)
    func theICS214FormCancelled()
}

class NewICS214TVC: UITableViewController {
    
    //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    var incidentObjId: NSManagedObjectID!
    var modalCells:Array = [CellParts]()
    
    var ics214structure: ICS214FormStructure!
    
    var showPicker:Bool = false
    var dateType:Bool = false
    var fromDate: Date!
    
    var descriptionText: String = ""
    var userName: String = ""
    var userPosition: String = ""
    var userAgency: String = ""
    
    var masterGuid: String = ""
    var incidentGuid: String = ""
    var journalGuid: String = ""
    var formType: String = ""
    var incidentNumber: String = ""
    var incidentName: String = ""
    var incidentDate: String = ""
    var teamName: String = ""
    var nameOfTeam: String = ""
    var masterOrNot: Bool = false
    var counter: Int64!
    var localIncidentNumber: String = ""
    
    
    weak var delegate: NewICS214Delegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var nims: ICS214Form!
    var ics214Form: ICS214Form!
    var masterICS214Form: ICS214Form!
    var incident: Incident!
    var journal: Journal!
    var objectID: NSManagedObjectID!
    var titled:String!
    var fju: FireJournalUser!
    var incidentEntry: Incident!
    let nc = NotificationCenter.default
    let cellArray = [1,2,3,7,8,9]
    var incidentNotes: IncidentNotes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
                   let frame = self.view.frame
                   let height = frame.height - 44
                   self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
                   self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
           }
        roundViews()
        registerTheCells()
        
        ics214structure = ICS214FormStructure.init()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        getTheUser()
        
        if masterOrNot {
            getTheIncident()
        } else {
            getTheICSMaster()
        }
        
    }
    
    
    func registerTheCells() {
        
        tableView.register(UINib(nibName: "NewICS214HeaderCell", bundle: nil), forCellReuseIdentifier: "NewICS214HeaderCell")
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.register(UINib(nibName: "NewICS214LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "NewICS214LabelTextFieldCell")
        tableView.register(UINib(nibName: "NewICS214DateTimeCell", bundle: nil), forCellReuseIdentifier: "NewICS214DateTimeCell")
        tableView.register(UINib(nibName: "NewICS214DatePickerCell", bundle: nil), forCellReuseIdentifier: "NewICS214DatePickerCell")
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 125
        case 1,2,3:
        //            NewICS214LabelTextFieldCell
           return 85
       case 4:
       //            LabelCell
           return 60
       case 5:
           //            NewICS214DateTimeCell
           return 90
       case 6:
           //            NewICS214DatePickerCell
           if(showPicker) {
               return  132
           } else {
               return 0
           }
        case 7,8,9:
       //            NewICS214LabelTextFieldCell
              return 85
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214HeaderCell", for: indexPath) as! NewICS214HeaderCell
            cell.subjectL.text = "ICS 214 Activity Log"
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            cell.delegate = self
            cell.subjectL.text = "Event Type"
            cell.descriptionTF.textColor = UIColor.black
            cell.descriptionTF.text = ics214Form.ics214Effort
            cell.path = indexPath
            cell.tag = row
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            cell.delegate = self
            cell.subjectL.text = "Incident Number"
            cell.descriptionTF.textColor = UIColor.black
            cell.descriptionTF.text = ics214Form.ics214LocalIncidentNumber
            cell.path = indexPath
            cell.tag = row
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            cell.delegate = self
            cell.subjectL.text = "Incident Name"
            cell.descriptionTF.textColor = UIColor.black
            cell.descriptionTF.text = ics214Form.ics214IncidentName
            cell.path = indexPath
            cell.tag = row
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.modalTitleL.text = "2. Operational Period:"
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DateTimeCell", for: indexPath) as! NewICS214DateTimeCell
            cell.dName = "Date From:"
            cell.tName = "Time From:"
            cell.delegate = self
            if ics214Form.ics214FromTime != nil {
                   var theDate = ""
                   var theTime = ""
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "MM/dd/YYYY"
                   theDate = dateFormatter.string(from: ics214Form.ics214FromTime ?? Date())
                   dateFormatter.dateFormat = "HH:mm"
                   theTime = dateFormatter.string(from: ics214Form.ics214FromTime ?? Date())
                   cell.dateT = theDate
                   cell.timeT = theTime
               }
            cell.tag = 5
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DatePickerCell", for: indexPath) as! NewICS214DatePickerCell
            cell.delegate = self
            cell.tag = 6
            cell.path = indexPath
            cell.theDatePicker.date = ics214Form.ics214ToTime ?? Date()
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            cell.delegate = self
            cell.subjectL.text = "Name"
            cell.descriptionTF.textColor = UIColor.black
            cell.descriptionTF.text = ics214Form.ics214UserName
            cell.path = indexPath
            cell.tag = row
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            cell.delegate = self
            cell.subjectL.text = "ICS Position"
            cell.descriptionTF.textColor = UIColor.black
            cell.descriptionTF.text = ics214Form.ics214ICSPosition
            cell.path = indexPath
            cell.tag = row
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            cell.delegate = self
            cell.subjectL.text = "Home Agency"
            cell.descriptionTF.textColor = UIColor.black
            cell.descriptionTF.text = ics214Form.ics241HomeAgency
            cell.path = indexPath
            cell.tag = row
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
}

extension NewICS214TVC: NewICS214HeaderCellDelegate {
    
    func headerCellCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func headerCellSave() {
        buildAndSave() {
            self.delegate?.theICS214FormCancelled()
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension NewICS214TVC: NewICS214LabelTextFieldCellDelegate {
    
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int) {
        switch tag {
            case 1:
                ics214Form.ics214Effort = text
            case 2:
                ics214Form.ics214LocalIncidentNumber = text
            case 3:
                ics214Form.ics214IncidentName = text
            case 7:
                ics214Form.ics214UserName = text
            case 8:
                ics214Form.ics214ICSPosition = text
            case 9:
                ics214Form.ics241HomeAgency = text
            default: break
        }
    }
}

extension NewICS214TVC: NewICS214DatePickerCellDelegate {
    
    func theDatePickerChangedDate(_ date: Date, at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewICS214DatePickerCell
        let tag = cell.tag
        var path = IndexPath(row: 0, section: 0)
        switch tag {
        case 6:
            showPicker.toggle()
            ics214Form.ics214FromTime = date
            path = IndexPath(row: 5, section: 0)
        default:break
        }
        tableView.reloadRows(at: [path,indexPath], with: .automatic)
    }
    
    
}

extension NewICS214TVC: NewICS214DateTimeCellDelegate {
    
//    MARK: -DATE TIME CELL DELEGATE-
    func theTimeBTapped(tag: Int) {
        if tag == 5 {
            showPicker.toggle()
            let path = IndexPath(row: 6, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
        }
    }
    
}

extension NewICS214TVC {

//    MARK: -DATA GATHERING-
    
    func buildAndSave(completion: () -> () ) {
        getAllTextFields {
            let modDate = Date()
            if incident != nil {
                if incident.incidentLocationSC != nil {
                    ics214Form.ics214LocationSC = incident.incidentLocationSC
                }
                incident.incidentModDate = modDate
                incident.incidentBackedUp = false
                buildTheIncidentNotes()
            }
            buildTheJournalNotes()
            ics214Form.ics214BackedUp = false
            ics214Form.ics214ModDate = modDate
            ics214Form.fjpUserReference = fju.userGuid
            if incident != nil {
                ics214Form.ics214IncidentInfo = incident
                incident.ics214Detail = ics214Form
            }
            ics214Form.ics214FJUDetail = fju
            journal.journalICS214Details = ics214Form
            ics214Form.ics214JournalInfo = journal
            if let guid = ics214Form.ics214Guid {
                saveToCD(guid: guid)
            }
            completion()
        }
    }
    
    fileprivate func saveToCD(guid: String) {
           do {
               try context.save()
               DispatchQueue.main.async {
                   self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
               }
                let objectID = getTheLastICS214(guid: guid)
               DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkNEWICS214FormCreated), object: nil, userInfo: ["objectID":objectID])

               }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkICS214_NEW_TO_LIST),
                            object: nil,
                            userInfo: ["objectID": ""])
                }
                DispatchQueue.main.async {
                    let jobjectID = self.journal.objectID
                     self.nc.post(name:Notification.Name(rawValue:FJkCKModifyJournalToCloud), object: nil, userInfo: ["objectID":jobjectID])
                }
            if incident != nil {
                DispatchQueue.main.async {
                    let iobjectID = self.incident.objectID
                     self.nc.post(name:Notification.Name(rawValue:FJkCKModifyIncidentToCloud), object: nil, userInfo: ["objectID":iobjectID])
                }
            }
           } catch let error as NSError {
               print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
           }
       }
    
    private func getTheLastICS214(guid: String) ->NSManagedObjectID {
        var objectID: NSManagedObjectID = NSManagedObjectID()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate = NSPredicate(format: "%K != %@", "ics214Guid", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214Guid", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Form]
            let ics = fetched.last!
            objectID = ics.objectID
        } catch let error as NSError {
            print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
        }
        return objectID
    }
    
    func getAllTextFields(completion: () -> ()) {
        for c in cellArray {
            let indexPath = IndexPath(row:c, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! NewICS214LabelTextFieldCell
            _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
        }
        completion()
    }
    
    func buildTheIncidentNotes() {
        incidentNotes = incident.incidentNotesDetails
        var notes = ""
        if let note = incidentNotes.incidentNote {
            notes = note
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let timeStamp = dateFormatter.string(from: ics214Form.ics214FromTime ?? Date())
        var name = ics214Form.ics214IncidentName ?? ""
        let user = ics214Form.ics214UserName ?? ""
        if masterOrNot {
            name = name + "- Master"
        }
        incidentNotes.incidentNote = "\(notes)\nTime Stamp: \(timeStamp)\nICS 214 Activity Log added \(name) \nCreated by: \(user)"
    }
    
    func buildTheJournalNotes() {
        let dateFormatter = DateFormatter()
        let incidentDate = Date()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let timeStamp = dateFormatter.string(from: incidentDate)
        let user = ics214Form.ics214UserName ?? ""
        let name = ics214Form.ics214IncidentName ?? ""
        var summary = ""
        if let note = journal.journalSummary as? String {
            summary = note
        }
        if summary != "" {
            let summary = "\(summary)\nTime Stamp: \(timeStamp)\nICS 214 Activity Log: \(formType): \(teamName) Effort: \(name) entered by \(user)"
            journal.journalSummary = summary as NSObject
        } else {
            let summary = "Time Stamp: \(timeStamp)\nICS 214 Activity Log: \(formType): \(teamName) Effort: \(name) entered by \(user)"
            journal.journalSummary = summary as NSObject
        }
        let overview = "New ICS214 Activity Log entered"
        journal.journalOverview = overview as NSObject
        journal.journalModDate = Date()
        journal.journalPrivate = true
        journal.journalBackedUp = false
    }
    
//   MARK: -GRAB THE USER'S INFO FOR FORM-
   func getTheUser() {
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser")
        do {
            let userFetched = try context.fetch(userRequest) as! [FireJournalUser]
            if userFetched.count != 0 {
                fju = userFetched.last
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to find an Incident tied to this objectID to \(nserror.localizedDescription) \(nserror.userInfo)")
            return
        }
    }
    
//    MARK: -GET THE INCIDENT-
    ///  Build the ICS214 as master for campaign
    func getTheIncident() {
        incident = context.object(with: incidentObjId) as? Incident
        let resourceDate = Date()
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "30."+uuidA
        ics214Form = ICS214Form.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Form", in: context)!, insertInto: context)
        ics214Form.ics214Guid = uuidA1
        let uuidA2 = "31."+uuidA
        ics214Form.ics214MasterGuid = uuidA2
        if let iguid = incident.fjpIncGuidForReference {
            ics214Form.incidentGuid = iguid
        }
        ics214Form.ics214EffortMaster = true
        ics214Form.ics214TeamName = teamName
        ics214Form.ics214Count = 1
        ics214Form.ics214Completed = false
        ics214Form.ics214Effort = "Local Incident"
        ics214Form.ics214LocalIncidentNumber = incident.incidentNumber
        ics214Form.ics214SignatureAdded = false
        ics214Form.ics214IncidentName = ""
        let lastICS214 = theLastICS214()
        if let name = lastICS214.ics214UserName {
            ics214Form.ics214UserName = name
        } else {
            ics214Form.ics214UserName = ""
        }
        if let position = lastICS214.ics214ICSPosition {
            ics214Form.ics214ICSPosition = position
        } else {
            ics214Form.ics214ICSPosition = ""
        }
        if let agency = lastICS214.ics241HomeAgency {
            ics214Form.ics241HomeAgency = agency
        } else {
            ics214Form.ics241HomeAgency = ""
        }
        journal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        var uuidJ = NSUUID().uuidString.lowercased()
        let stringDate = dateFormatter.string(from: resourceDate)
        uuidJ = uuidJ+stringDate
        uuidJ = "01."+uuidJ
       journal.fjpJGuidForReference = uuidJ
        ics214Form.journalGuid = uuidJ
       journal.fjpJournalModifiedDate = resourceDate
       journal.journalEntryTypeImageName = "administrativeNewColor58"
       journal.journalEntryType = "Station"
        if let platoon = fju.tempPlatoon {
           journal.journalTempPlatoon = platoon
        }
        if let assignment = fju.tempAssignment {
           journal.journalTempAssignment = assignment
        }
        if let apparatus = fju.tempApparatus {
           journal.journalTempApparatus = apparatus
        }
        if let fireStation = fju.tempFireStation {
           journal.journalTempFireStation = fireStation
        }
        journal.journalEntryType = "Station"
        journal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        journal.journalDateSearch = dateFrom
        journal.journalCreationDate = resourceDate
        journal.journalModDate = resourceDate
        journal.journalPrivate = true
        journal.journalBackedUp = false
        journal.ics214Effort = "Local Incident"
        journal.journalHeader = "ICS 214 Activity Log: Local Incident"
        journal.ics214MasterGuid = uuidA2
        if let fjuGuid = fju.userGuid {
            journal.fjpUserReference = fjuGuid
        }
    }
    
//    MARK: -GET THE ICSMASTER-
    /// Build the ICS214 with masterGuid from Campaign
    func getTheICSMaster() {
        masterICS214Form = context.object(with: incidentObjId) as? ICS214Form
        if let guid = masterICS214Form.ics214MasterGuid {
            let count = countForMaster(master: guid)
            counter = Int64(count)
            counter = counter + Int64(1)
        }
        if let incidentGuid = masterICS214Form.incidentGuid {
            incident = getTheIncident(guid: incidentGuid)
        }
        ics214Form = ICS214Form.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Form", in: context)!, insertInto: context)
        let resourceDate = Date()
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "30."+uuidA
        ics214Form.ics214Guid = uuidA1
        ics214Form.ics214MasterGuid = masterICS214Form.ics214MasterGuid
        if incident != nil {
            if let iguid = incident.fjpIncGuidForReference {
                ics214Form.incidentGuid = iguid
            }
        } else {
            ics214Form.incidentGuid = ""
        }
        ics214Form.ics214EffortMaster = false
        ics214Form.ics214TeamName = teamName
        ics214Form.ics214Count = counter
        ics214Form.ics214Completed = false
        if let effort = masterICS214Form.ics214Effort {
            ics214Form.ics214Effort = effort
        }
        ics214Form.ics214LocalIncidentNumber = masterICS214Form.ics214LocalIncidentNumber
        ics214Form.ics214IncidentName = masterICS214Form.ics214IncidentName
        ics214Form.ics214UserName = masterICS214Form.ics214UserName
        ics214Form.ics214ICSPosition = masterICS214Form.ics214ICSPosition
        ics214Form.ics241HomeAgency = masterICS214Form.ics241HomeAgency
        ics214Form.ics214SignatureAdded = false
        if let jGuid = masterICS214Form.journalGuid {
            ics214Form.journalGuid = jGuid
            journal = getTheJournal(guid: jGuid)
            if let header = journal.journalHeader { print(header) } else {
                journal.journalHeader = "ICS 214 Activity Log: Local Incident"
            }
        }
    }
    
    func getTheJournal(guid: String) ->Journal {
        var theJournal: Journal = Journal()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
               let predicate = NSPredicate(format: "%K != %@", "fjpJGuidForReference", guid)
               fetchRequest.predicate = predicate
               let sectionSortDescriptor = NSSortDescriptor(key: "fjpJGuidForReference", ascending: true)
               let sortDescriptors = [sectionSortDescriptor]
               fetchRequest.sortDescriptors = sortDescriptors
               do {
                   let fetched = try context.fetch(fetchRequest) as! [Journal]
                   if !fetched.isEmpty {
                       theJournal = fetched.last!
                   }
               } catch let error as NSError {
                   print("NewICS214TVC line 680 Fetch Error: \(error.localizedDescription)")
               }
        return theJournal
    }
    //    MARK: -GET THE INCIDENT ASSOCIATED WITH THE MASTER GUID-
    /// - Parameter guid: incidentGuid from master ics214form
    /// - Returns: the incident Incident
    func getTheIncident(guid: String) -> Incident {
        var theIncident: Incident = Incident()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        let predicate = NSPredicate(format: "%K != %@", "fjpIncGuidForReference", guid)
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "fjpIncGuidForReference", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetched = try context.fetch(fetchRequest) as! [Incident]
            if !fetched.isEmpty {
                theIncident = fetched.last!
            }
        } catch let error as NSError {
            print("NewICS214TVC line 680 Fetch Error: \(error.localizedDescription)")
        }
        return theIncident

    }
    
//    MARK: -GET LAST ICS214-
    
    /// Grab the last build ICS214 to grab the user/position/agency
    /// - Returns: ICS214Form
    private func theLastICS214() -> ICS214Form {
        var lastICS214: ICS214Form = ICS214Form()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate = NSPredicate(format: "%K != %@", "ics214Guid", "")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Form]
            if !fetched.isEmpty {
                lastICS214 = fetched.last!
            }
        } catch let error as NSError {
            print("UpdateShiftCVC THEUSERTIMECOUNT line 57 Fetch Error: \(error.localizedDescription)")
        }
        return lastICS214
    }
    //    MARK: -COUNT FOR MASTER-
    /// Build the count for the campaign
    /// - Parameter master: String - the master guid
    /// - Returns: count of number of ics214's that use same master guid
    func countForMaster(master:String) -> Int {
        var counter:Int = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let predicate = NSPredicate(format: "%K == %@", "ics214MasterGuid", master)
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214MasterGuid", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Form]
            if !fetched.isEmpty {
                counter = fetched.count
            }
        } catch let error as NSError {
            print("UpdateShiftCVC THEUSERTIMECOUNT line 57 Fetch Error: \(error.localizedDescription)")
        }
        return counter
    }
    
}
