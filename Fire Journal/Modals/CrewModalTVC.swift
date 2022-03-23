//
//  CrewModalTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/25/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TheCrew {
    var entryState = EntryState.new
    var crew: String
    var crewString: String = ""
    var crewName: String
    var crewA: Array<String>
    var overTimeB: Bool = true
    var overTimeS: String = "AM Relief"
    var crewGuid: String = ""
    var crewDate: Date = Date()
    var objectID: NSManagedObjectID! = nil
    init(crew:String, crewName: String, crewA: Array<String>) {
        self.crew = crew
        self.crewName = crewName
        self.crewA = crewA
    }
    
    func createGuid() {
        self.crewDate = Date()
        let groupDate = GuidFormatter.init(date:crewDate)
        let grGuid:String = groupDate.formatGuid()
        self.crewGuid = "80."+grGuid
    }
    
    func joinCrew()->Array<String> {
        let group:Array<String> = crew.components(separatedBy: ", ")
        return group
    }
    
    func joinCrew2()->String {
        let group:String = crewA.joined(separator: ", ")
        return group
    }
    
    func overtimeSwitch(yesno: Bool) {
        self.overTimeB = yesno
        if yesno {
            self.overTimeS = "AM Relief"
        } else {
            self.overTimeS = "Overtime"
        }
    }
    
}

protocol CrewModalTVCDelegate: AnyObject {
    func theCrewModalCancelTapped()
    func theCrewModalChosenTapped(crew: TheCrew, objectID: NSManagedObjectID)
}

class CrewModalTVC: UITableViewController, UITextViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, CrewModalDataTVCDelegate
{
    
    @IBOutlet weak var viewForCrew: UIView!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UILabel!
    @IBOutlet weak var subject2L: UILabel!
    @IBOutlet weak var subject2TF: UITextField!
    @IBOutlet weak var subject3L: UILabel!
    @IBOutlet weak var subject3TFD: UITextField!
    @IBOutlet weak var switchL: UILabel!
    @IBOutlet weak var overtimeSwitch: UISwitch!
    @IBOutlet weak var subject4L: UILabel!
    @IBOutlet weak var subject4B: UIButton!
    @IBOutlet weak var subject5L: UILabel!
    @IBOutlet weak var subject5B: UIButton!
    @IBOutlet weak var horizontalBarIV: UIImageView!
    
    @IBAction func cancelBTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveBTapped(_ sender: Any) {
        if subject2TF.text == "" {
            let alertMessage:String = "To save a crew you need to give the crew a name."
            let title:String = "Crew"
            let alert = UIAlertController.init(title: title, message: alertMessage, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "I Agree", style: .default, handler: {_ in
                
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            if let name = subject2TF.text {
                crewWithName.crewName = name
            }
            if let crew = subject3TFD.text {
                crewWithName.crew = crew
            }
            if ((userCrews?.objectID) != nil) {
                updateTheData()
            } else {
                let fjUserCrew = UserCrews.init(entity: NSEntityDescription.entity(forEntityName: "UserCrews", in: context)!, insertInto: context)
                fjUserCrew.crew = crewWithName.crew
                fjUserCrew.crewName = crewWithName.crewName
                crewWithName.createGuid()
                fjUserCrew.entryState = crewWithName.entryState.rawValue
                fjUserCrew.crewGuid = crewWithName.crewGuid
                fjUserCrew.crewDateModified = crewWithName.crewDate
                fjUserCrew.crewDateCreated = crewWithName.crewDate
                fjUserCrew.crewDefault = crewWithName.overTimeB
                let defaultOrNot = crewWithName.overTimeB
                if defaultOrNot {
                    fju.crewDefault = defaultOrNot
                    fju.defaultCrewGuid = crewWithName.crewGuid
                    fju.defaultCrew = crewWithName.crew
                    fju.deafultCrewName = crewWithName.crewName
                } else {
                    fju.crewDefault = defaultOrNot
                    fju.crewOvertime = crewWithName.crew
                    fju.crewOvertimeGuid = crewWithName.crewGuid
                    fju.crewOvertimeName = crewWithName.crewName
                }
                saveToCD()
                let isSaved: Bool = fjUserCrew.objectID.isTemporaryID
                if isSaved {
                    
                } else {
                    delegate?.theCrewModalChosenTapped(crew: crewWithName, objectID: fjUserCrew.objectID)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func updateTheData() {
        userCrews.crew = crewWithName.crew
        userCrews.crewName = crewWithName.crewName
        userCrews.crewDateModified = crewWithName.crewDate
        userCrews.crewDateCreated = crewWithName.crewDate
        userCrews.crewDefault = crewWithName.overTimeB
        let defaultOrNot = crewWithName.overTimeB
        if defaultOrNot {
            fju.crewDefault = defaultOrNot
            fju.defaultCrewGuid = crewWithName.crewGuid
            fju.defaultCrew = crewWithName.crew
            fju.deafultCrewName = crewWithName.crewName
        } else {
            fju.crewDefault = defaultOrNot
            fju.crewOvertime = crewWithName.crew
            fju.crewOvertimeGuid = crewWithName.crewGuid
            fju.crewOvertimeName = crewWithName.crewName
        }
        saveToCD()
        delegate?.theCrewModalChosenTapped(crew: crewWithName, objectID: userCrews.objectID)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func overtimeSwitchTapped(_ sender: Any) {
        if overtimeSwitch.isOn {
            crewWithName.overtimeSwitch(yesno: true)
            switchL.text = group.overtimeS
        } else {
            group.overtimeSwitch(yesno: false)
            switchL.text = group.overtimeS
        }
    }
    @IBAction func subject4BTapped(_ sender: Any) {
    }
    @IBAction func subject5Tapped(_ sender: Any) {
    }
    var crew:CrewFromContact!
    var crewWithName:TheCrew!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    
    var frontOrOverB: Bool = true
    var headerTitle:String = ""
    var myShift: MenuItems!
    var incidentType: IncidentTypes!
    var entity: String = "UserCrews"
    let entity2: String = "UserAttendees"
    var attribute: String = "crewName"
    let attribute2: String = "attendee"
    var crews: Array<NSManagedObject> = []
    var selected: Array<String> = []
    var fetched:Array<Any>!
    var fju:FireJournalUser!
    var group: ResourcesItem!
    let segue: String = "UserCrewsToDataSegue"
    var userCrews: UserCrews!
    
    weak var delegate: CrewModalTVCDelegate? = nil
    
    private func getTheData()->Array<NSManagedObject> {
        var fetch = [UserAttendees]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity2 )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",attribute2,"")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: attribute2 , ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            fetch = try context.fetch(fetchRequest) as! [UserAttendees]
            return fetch
        } catch let error as NSError {
            print("CrewModalTVC line 260 Fetch Error: \(error.localizedDescription)")
        }
        return fetch
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        viewForCrew.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 555.00)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        
        tableView.register(UINib(nibName: "CrewModalCell", bundle: nil), forCellReuseIdentifier: "CrewModalCell")
        
        crew = CrewFromContact.init(name: "", phone: "", email: "",crew: [])
        crewWithName = TheCrew.init(crew: "", crewName: "", crewA: [])
        _ = getTheUserCrewsData()
        getTheUserData()
        roundViews()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
//        subject4B.setBackgroundImage(ButtonsForFJ092018.imageOfResourceGroupNew, for: .normal)
//        subject5B.setBackgroundImage(ButtonsForFJ092018.imageOfSmallBluePlusButt, for: .normal)
//        subject4B.layer.cornerRadius = 5
//        subject4B.layer.masksToBounds = true
//        subject4B.setNeedsDisplay()
    }
    //    MARK: -CrewModalDataTVCDelegate
    func crewModalDataCancelled() {
        //        self.dismiss(animated: true, completion: nil)
    }
    
    func crewModalDataSaved(crew: Array<String>) {
        self.crew.attendees = crew
        self.crewWithName.crewA = crew
        self.crewWithName.crew = self.crewWithName.joinCrew2()
        self.crew.attendeesString = self.crew.joinAttendees()
        subject3TFD.text = self.crewWithName.crew
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        subject2TF.text = text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        subject2TF.text = text
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Crew Modal TVC merge that"])
            }
            DispatchQueue.main.async {
               print("here we go to FJkFJUserModifiedSendToCloud")
                self.nc.post(name:Notification.Name(rawValue:FJkFJUserModifiedSendToCloud),
                        object: nil,
                        userInfo: ["objectID":self.fju.objectID])
            }
        } catch let error as NSError {
            print("CrewModalTVC line 335 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<UserCrews> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<UserCrews>? = nil
    
    private func getTheUserCrewsData() -> NSFetchedResultsController<UserCrews> {
        
        let fetchRequest: NSFetchRequest<UserCrews> = UserCrews.fetchRequest()
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","crewName","")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "crewName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("CrewModalTVC line 369 Fetch Error: \(error.localizedDescription)")
        }
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
        case NSFetchedResultsChangeType.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case NSFetchedResultsChangeType.move:
            print("NSFetchedResultsChangeType.Move detected")
        case NSFetchedResultsChangeType.update:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            tableView.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
        default: break
        }
    }
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
//    {
//        tableView.endUpdates()
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = _fetchedResultsController?.sections
        {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewModalCell", for: indexPath) as! CrewModalCell
            configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: CrewModalCell, at indexPath: IndexPath) {
        cell.crew = _fetchedResultsController?.object(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewModalCell
        cell.isSelected = true
        userCrews = _fetchedResultsController?.object(at: indexPath)
        crewWithName.objectID = userCrews.objectID
        crewWithName.crew = userCrews.crew ?? ""
        crewWithName.crewName = userCrews.crewName ?? ""
        crewWithName.crewGuid = userCrews.crewGuid ?? ""
        crewWithName.overTimeB = userCrews.crewDefault
        crewWithName.entryState = .update
        selected = crewWithName.joinCrew()
        subject2TF.text = crewWithName.crewName
        subject3TFD.text = crewWithName.crew
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewModalCell
        cell.isSelected = false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            userCrews = _fetchedResultsController?.object(at: indexPath)
            context.delete(userCrews)
            saveToCD()
            userCrews = nil
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserCrewsToDataSegue" {
            let detailTVC:CrewModalDataTVC = segue.destination as! CrewModalDataTVC
            let attendees = getTheData()
            detailTVC.delegate = self
            detailTVC.fetched = attendees
            if !selected.isEmpty {
                detailTVC.selected = selected
            }
        }
    }
    
    private func getTheUserData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            self.fju = fetched.last
        } catch let error as NSError {
            print("CrewModalTVC line 495 Fetch Error: \(error.localizedDescription)")
        }
    }

    

}
