//
//  CrewModalDataTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/25/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol CrewModalDataTVCDelegate: AnyObject {
    func crewModalDataCancelled()
    func crewModalDataSaved(crew:Array<String>)
}

class CrewModalDataTVC: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate,ContactsModalDataTVCDelegate,CellHeaderCancelSaveDelegate {
    
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var subject1L: UILabel!
    @IBOutlet weak var subject2L: UILabel!
    @IBOutlet weak var subject3L: UILabel!
    @IBOutlet weak var subject4L: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var addToListB: UIButton!
    @IBOutlet weak var getContactsB: UIButton!
    let segue: String = "getContactsSegue"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    weak var delegate: CrewModalDataTVCDelegate? = nil
    
    var frontOrOverB: Bool = true
    var headerTitle:String = ""
    var myShift: MenuItems!
    var incidentType: IncidentTypes!
    var entity: String = "UserAttendees"
    let attribute: String = "attendee"
    var selected: Array<String> = []
    var fetched:Array<Any>!
    var group: ResourcesItem!
    
    @IBAction func cancelBTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.crewModalDataCancelled()
    }
    @IBAction func saveBTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.crewModalDataSaved(crew: selected)
    }
    @IBAction func addToListBTapped(_ sender: Any) {
        let name = nameTF.text ?? ""
        nameTF.text = ""
        let group = CrewFromContact.init(name: name, phone: "", email: "", crew: [] )
        if name != "" {
            let fjUserAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
            group.createGuid()
            fjUserAttendee.attendee = name
            fjUserAttendee.attendeeEmail = group.email
            fjUserAttendee.attendeePhone = group.phone
            fjUserAttendee.attendeeModDate = group.attendeeDate
            fjUserAttendee.attendeeGuid = group.attendeeGuid
            fjUserAttendee.defaultCrewMember = group.overtimeB
            saveToCD(guid: group.attendeeGuid)
        }
        tableView.reloadData()
    }
    @IBAction func getContactsBTapped(_ sender: Any) {
        performSegue(withIdentifier: segue, sender: self)
    }
    

    
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = getTheAttendeesData()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        
        tableView.register(UINib(nibName: "CrewCell", bundle: nil), forCellReuseIdentifier: "CrewCell")
        roundViews()
        getContactsB.layer.cornerRadius = 6
        getContactsB.layer.masksToBounds = true
        
        tableView.allowsMultipleSelection = true
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }

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
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewCell", for: indexPath) as! CrewCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: CrewCell, at indexPath: IndexPath) {
        cell.contact =  _fetchedResultsController?.object(at: indexPath)
    
        //        MARK: if multiple selects already exist check against resource and mark as checked
        let contact = cell.contact?.attendee ?? ""
        let result = selected.filter { $0 == contact}
        if !result.isEmpty {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewCell
        cell.isSelected = true
        let name = cell.contact?.attendee ?? ""
        
        let result = selected.filter { $0 == name}
        if result.isEmpty {
            selected.append(name)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewCell
        cell.isSelected = false
        let resource = cell.contact?.attendee ?? ""
        selected = selected.filter { $0 != resource }
    }
    
    //    MARK: -Delegate CellHeaderCancelSave
    func cellCancelled() {
        self.dismiss(animated: true, completion: nil)
        delegate?.crewModalDataCancelled()
    }
    
    func cellSaved() {
        self.dismiss(animated: true, completion: nil)
        delegate?.crewModalDataSaved(crew: selected)
    }

    //    MARK: -ContactModalDataTVCDelegates
    func contactModalDataCancelled() {
//        <#code#>
    }
    
    func contactModalDataSaved(crew: Array<CrewFromContact>) {
        for ( _, item ) in crew.enumerated() {
            let group = item
            let name = group.name
            let result = selected.filter { $0 == name}
            if result.isEmpty {
                selected.append(name)
            }
            //            TODO: save each CrewFromContact to UserAttendee
            let fjUserAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
            group.createGuid()
            fjUserAttendee.attendee = name
            fjUserAttendee.attendeeEmail = group.email 
            fjUserAttendee.attendeePhone = group.phone 
            fjUserAttendee.attendeeModDate = group.attendeeDate
            fjUserAttendee.attendeeGuid = group.attendeeGuid
            fjUserAttendee.defaultCrewMember = group.overtimeB
            saveToCD(guid: group.attendeeGuid)
        }
        tableView.reloadData()
    }
    
    fileprivate func saveToCD(guid: String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Crew Modal Data TVC merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSaved(guid: guid)
                self.nc.post(name: NSNotification.Name(rawValue: FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        } catch let error as NSError {
            print("CrewModalDataTVC line 382 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func getTheLastSaved(guid:String) -> NSManagedObjectID{
        var objectID: NSManagedObjectID  = NSManagedObjectID()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@","attendeeGuid", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "attendeeGuid", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [UserAttendees]
            let attendee = self.fetched.last as! UserAttendees
            objectID = attendee.objectID
        } catch let error as NSError {
            print("IncidentPOVNotesTVC line 490 Fetch Error: \(error.localizedDescription)")
        }
        return objectID
    }
    
    var fetchedResultsController: NSFetchedResultsController<UserAttendees> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<UserAttendees>? = nil
    
    private func getTheAttendeesData() -> NSFetchedResultsController<UserAttendees> {
        
        let fetchRequest: NSFetchRequest<UserAttendees> = UserAttendees.fetchRequest()
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","attendee","")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("CrewModalDataTVC line 234 Fetch Error: \(error.localizedDescription)")
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getContactsSegue" {
            let detailTVC:ContactsModalDataTVC = segue.destination as! ContactsModalDataTVC
            detailTVC.delegate = self
        }
    }

}
