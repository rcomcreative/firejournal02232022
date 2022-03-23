//
//  RelieveSupervisorModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol RelieveSupervisorModalTVCDelegate: AnyObject {
    func relieveSupervisorModalCancel()
    func relieveSupervisorModalSave(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool )
}

class RelieveSupervisorModalTVC: UITableViewController {
    
//    MARK: -PROPERTIES-
    weak var delegate: RelieveSupervisorModalTVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    var _fetchedResultsController: NSFetchedResultsController<UserAttendees>? = nil
    var entity: String = "UserAttendees"
    let attribute: String = "attendee"
    var selected = [UserAttendees]()
    var relieveOrSupervisor: Bool = false
    var headerTitle: String = ""
    var alertUp: Bool = false
    let segue: String = "RelieveSupervisorToContactSegue"
    var menuType: MenuItems? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        let _ = getTheAttendeesData()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        roundViews()
        if menuType == MenuItems.journal || menuType == MenuItems.incidents {
            tableView.allowsMultipleSelection = true
        }
        tableView.register(UINib(nibName: "CrewCell", bundle: nil), forCellReuseIdentifier: "CrewCell")
//        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }

    // MARK: - Table view data source
       // MARK: - Table view data source// MARK: - Table View
       override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let headerV = Bundle.main.loadNibNamed("RelieveSupervisorHeaderV", owner: self, options: nil)?.first as! RelieveSupervisorHeaderV
           headerV.delegate = self
           headerV.relieveSupervisorSubjectL.text = headerTitle
           headerV.backgroundV.image = UIImage(named: "EDF0F6-D8E7FA_CellBkgrnd4sq")
           return headerV
       }
       
       override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 190
       }

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
        let result = selected.filter { $0.attendee == contact}
        if !result.isEmpty {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewCell
        cell.isSelected = true
        let name = cell.contact?.attendee ?? ""
        
        let result = selected.filter { $0.attendee == name}
        if result.isEmpty {
            selected.append(cell.contact!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewCell
        cell.isSelected = false
        let resource = cell.contact?.attendee ?? ""
        selected = selected.filter { $0.attendee != resource }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
            {
                var attendee = _fetchedResultsController?.object(at: indexPath)
                context.delete(attendee! as NSManagedObject)
                saveToCD()
                attendee = nil
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RelieveSupervisorToContactSegue" {
            let detailTVC:RelieveSupervisorContactsTVC = segue.destination as! RelieveSupervisorContactsTVC
            detailTVC.delegate = self
        }
    }

}

extension RelieveSupervisorModalTVC: RelieveSupervisorContactsTVCDelegate {
    func cancelContactsBTapped() {
//        <#code#>
    }
    
    func saveContactsBTapped(crew: [CrewFromContact] ) {
        for ( _, item ) in crew.enumerated() {
            let group = item
            let name = group.name
            let result = selected.filter { $0.attendee == name}
            if result.isEmpty {
               let fjUserAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
               fjUserAttendee.attendee = name
               fjUserAttendee.attendeeEmail = group.email
               fjUserAttendee.attendeePhone = group.phone
               fjUserAttendee.attendeeModDate = group.attendeeDate
               fjUserAttendee.attendeeGuid = group.attendeeGuid
               fjUserAttendee.defaultCrewMember = group.overtimeB
               saveUAToCD(guid:group.attendeeGuid)
            }
        }
//        tableView.reloadData()
    }
    
    
}

extension RelieveSupervisorModalTVC: RelieveSupervisorHeaderVDelegate {
    
    func relieveSupervisorTextEditing(text: String) {
    }
    
    func buildNewUserAttendee(name: String) {
        let group = CrewFromContact.init(name: name, phone: "", email: "", crew: [] )
        group.createGuid()
        let fjUserAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
        fjUserAttendee.attendee = name
        fjUserAttendee.attendeeEmail = group.email
        fjUserAttendee.attendeePhone = group.phone
        fjUserAttendee.attendeeModDate = group.attendeeDate
        fjUserAttendee.attendeeGuid = group.attendeeGuid
        fjUserAttendee.defaultCrewMember = group.overtimeB
        saveUAToCD(guid: group.attendeeGuid)
    }
    
    func relieveSupervisorInfoTapped() {
        if !alertUp {
                presentAlert()
            }
        }

    func presentAlert() {
        var alert: UIAlertController!
        if relieveOrSupervisor {
            let title: InfoBodyText = .relievingSupportNotesSubject
            let message: InfoBodyText = .relievingSupportNotes
            alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        } else {
            let title: InfoBodyText = .supervisorSupportNotesSubject
            let message: InfoBodyText = .supervisorSupportNotes
            alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        }
        switch menuType {
        case .journal:
            let title: InfoBodyText = .journalCrewSupportNotesSubject
            let message: InfoBodyText = .journalCrewSupportNotes
            alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        case .incidents:
            let title: InfoBodyText = .incidentCrewSupportNotesSubject
            let message: InfoBodyText = .incidentCrewSupportNotes
            alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        default: break
        }
            
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
    }
    
    func relieveSupervisorAddNewMember(member: String) {
        self.resignFirstResponder()
        let name = member
        if name != "" {
            buildNewUserAttendee(name: name)
        }
    }
    
    func relieveSupervisorAddFromContacts() {
        performSegue(withIdentifier: segue, sender: self)
    }
    
    func relieveSupervisorCancelTapped() {
        delegate?.relieveSupervisorModalCancel()
    }
    
    func relieveSupervisorSaveTapped(member: String) {
        delegate?.relieveSupervisorModalSave(relieveSupervisor: selected, relieveOrSupervisor: relieveOrSupervisor )
    }

}

extension RelieveSupervisorModalTVC: NSFetchedResultsControllerDelegate {
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"RelieveSupervisorModalTVC merge that"])
            }
        } catch let error as NSError {
            print("RelieveSupervisorModalTVC line 196 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveUAToCD(guid: String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"RelieveSupervisorModal TVC merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSaved(guid: guid)
                self.nc.post(name: NSNotification.Name(rawValue: FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        } catch let error as NSError {
            print("RelieveSupervisorModal line 284 Fetch Error: \(error.localizedDescription)")
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
            let fetched = try context.fetch(fetchRequest) as! [UserAttendees]
            let attendee = fetched.last!
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
    
    private func getTheAttendeesData() -> NSFetchedResultsController<UserAttendees> {
        
        let fetchRequest: NSFetchRequest<UserAttendees> = UserAttendees.fetchRequest()
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","attendee","")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("CrewModalDataTVC line 178 Fetch Error: \(error.localizedDescription)")
        }
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.beginUpdates()
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
           switch type {
           case .insert:
               let sectionIndexSet = NSIndexSet(index: sectionIndex)
               self.tableView.insertSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
           case .delete:
               let sectionIndexSet = NSIndexSet(index: sectionIndex)
               self.tableView.deleteSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
           default: break
           }
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
           return sectionName
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
       {
           switch type
           {
           case NSFetchedResultsChangeType.insert:
               print("NSFetchedResultsChangeType.insert detected")
               if let indexPath = newIndexPath {
                   tableView.insertRows(at: [indexPath], with: .fade)
                   //                saveToCD()
               }
           case NSFetchedResultsChangeType.delete:
               print("NSFetchedResultsChangeType.Delete detected")
               if let deleteIndexPath = indexPath
               {
                   tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
               }
           case NSFetchedResultsChangeType.update:
               print("NSFetchedResultsChangeType.update detected")
               if let indexPath = indexPath, let _ = tableView.cellForRow(at: indexPath) {
//                   _ = configureCell(at: indexPath)
                   //                saveToCD()
               }
           case NSFetchedResultsChangeType.move:
               print("NSFetchedResultsChangeType.Move detected")
               if let deleteIndexPath = indexPath {
                   self.tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
               }
               
               // Note that for Move, we insert a row at the __newIndexPath__
               if let insertIndexPath = newIndexPath {
                   self.tableView.insertRows(at: [insertIndexPath], with: UITableView.RowAnimation.fade)
               }
           default: break
           }
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
       {
           tableView.endUpdates()
       }
}
