//
//  NewICS214ResourcesAssignedTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol NewICS214ResourcesAssignedTVCDelegate: AnyObject {
    func newICS214ResourcesAssignedCanceled()
    func newICS214ResourcesAssignedGroupToSave(crew: [UserAttendees])
}

class NewICS214ResourcesAssignedTVC: UITableViewController {
    
    weak var delegate: NewICS214ResourcesAssignedTVCDelegate? = nil
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var segueIdentifier: String = "NewICS214ContactsSegue"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    var _fetchedResultsController: NSFetchedResultsController<UserAttendees>? = nil
    var entity: String = "UserAttendees"
    let attribute: String = "attendee"
    var selected = [UserAttendees]()
    var newOfficer: UserAttendees!
    
    var imageAvailable: Bool = false
    var contactImage: UIImage!
    var validPhotos = [Photo]()
    
    var headerTitle: String = ""
    var alertUp: Bool = false
    var staffContactsVC: StaffContactsVC!
    
    lazy var photoProvider: PhotoProvider = {
        let provider = PhotoProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    var editVC: ICS214ResourceEditVC!
    
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
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        _ = getTheAttendeesData()
        registerCells()
        roundViews()
        
        tableView.allowsMultipleSelection = true
        
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "NewICS214Resource3TFCell", bundle: nil), forCellReuseIdentifier: "NewICS214Resource3TFCell")
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
    
    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("NewICS214ResourceHeaderV", owner: self, options: nil)?.first as! NewICS214ResourceHeaderV
        headerV.delegate = self
        headerV.backgroundV.image = UIImage(named: "EDF0F6-D8E7FA_CellBkgrnd4sq")
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 230
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214Resource3TFCell", for: indexPath) as! NewICS214Resource3TFCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    
    func configureCell(_ cell: NewICS214Resource3TFCell, at indexPath: IndexPath) {
        cell.crew =  _fetchedResultsController?.object(at: indexPath)
        cell.indexPath = indexPath
        cell.delegate = self
        
        //        MARK: if multiple selects already exist check against resource and mark as checked
        let contact = cell.crew?.attendee ?? ""
        let result = selected.filter { $0.attendee == contact}
        if !result.isEmpty {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! NewICS214Resource3TFCell
        cell.isSelected = true
        let name = cell.crew?.attendee ?? ""
        let crew = cell.crew ?? UserAttendees()
        let result = selected.filter { $0.attendee == name}
        if result.isEmpty {
            selected.append(crew)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! NewICS214Resource3TFCell
        cell.isSelected = false
        let crew = cell.crew
        selected = selected.filter { $0 != crew }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let detailTVC:NewICS214ContactsTVC = segue.destination as! NewICS214ContactsTVC
            detailTVC.delegate = self
            print(segueIdentifier)
        }
    }
}

extension NewICS214ResourcesAssignedTVC:  NewICS214Resource3TFCellDelegate {
    
    func theCrewMemberChanged(theCrew: UserAttendees, indexPath: IndexPath ) {
        let cell = tableView.cellForRow(at: indexPath) as! NewICS214Resource3TFCell
        let attendee = cell.crew
        if attendee?.objectID == _fetchedResultsController?.object(at: indexPath).objectID {
            _fetchedResultsController?.object(at: indexPath).attendee = attendee?.attendee
            _fetchedResultsController?.object(at: indexPath).attendeeHomeAgency = attendee?.attendeeHomeAgency
            _fetchedResultsController?.object(at: indexPath).attendeeICSPosition = attendee?.attendeeICSPosition
            saveToCoreData()
        }
        
    }
    
    func theEditButtonWasTapped(indexPath: IndexPath, crew: UserAttendees) {
        let objectID = crew.objectID
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "ICS214ResourceEdit", bundle: nil)
        editVC  = storyboard.instantiateViewController(identifier: "ICS214ResourceEditVC") as? ICS214ResourceEditVC
        let index = IndexPath(row: 12, section: 0)
        editVC.configure(objectID, index: index)
        editVC.transitioningDelegate = slideInTransitioningDelgate
        editVC.delegate = self
        if Device.IS_IPHONE {
            editVC.modalPresentationStyle = .formSheet
        } else {
            editVC.modalPresentationStyle = .custom
        }
        self.present(editVC, animated: true )
    }
    
}

extension NewICS214ResourcesAssignedTVC: ICS214ResourceEditVCDelegate {
    
    func cancelResourceEditVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveResourceEdit(_ userAttendeesOID: NSManagedObjectID, index: IndexPath) {
        editVC.dismiss(animated: true, completion: {
            if let member = self.context.object(with: userAttendeesOID) as? UserAttendees {
            member.attendeeModDate = Date()
            member.attendeeBackUp = false
            }
            self.saveToCoreData()
            self.tableView.reloadRows(at: [index], with: .automatic)
        })
    }
    
    
}

extension NewICS214ResourcesAssignedTVC: NewICS214AssignedResourceEditVCDelegate {
    func theCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theAssignedResourceEditSaveTapped(member: UserAttendees, path: IndexPath) {
        member.attendeeModDate = Date()
        member.attendeeBackUp = false
        saveToCoreData()
        tableView.reloadRows(at: [path], with: .automatic)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension NewICS214ResourcesAssignedTVC: NewICS214ResourceHeaderVDelegate {
    
    func newICS214ResourceInfoTapped() {
        presentAlert()
    }
    
    func presentAlert() {
        var alert: UIAlertController!
        let title: InfoBodyText = .newICS214CrewSupportNotesSubject
        let message: InfoBodyText = .newICS214CrewSupportNotes
        alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func newICS214ResourceAddNewMember(member: String) {
        self.resignFirstResponder()
        let name = member
        if name != "" {
            buildNewUserAttendee(name: name)
        }
    }
    
    func newICS214ResourceAddFromContacts() {
//        performSegue(withIdentifier: segueIdentifier, sender: self)
        let storyBoard : UIStoryboard = UIStoryboard(name: "StaffContact", bundle:nil)
        staffContactsVC = storyBoard.instantiateViewController(withIdentifier: "StaffContactsVC") as? StaffContactsVC
        staffContactsVC.delegate = self
        staffContactsVC.modalPresentationStyle = .formSheet
        self.present(staffContactsVC, animated: true, completion: nil)
    }
    
    func newICS214ResourceCancelTapped() {
        delegate?.newICS214ResourcesAssignedCanceled()
    }
    
    func newICS214ResourceSaveTapped() {
        delegate?.newICS214ResourcesAssignedGroupToSave(crew: selected)
    }
    
    func newICS214ResourceTextEditing(text: String) {}
    
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
    
}

extension NewICS214ResourcesAssignedTVC: StaffContactsVCDelegate {
    
    func staffChosen(_ staff: NewStaff) {
        newOfficer = nil
        var name: String = ""
        var phone: String = ""
        var email: String = ""
        if staff.fullName != "" {
            name = staff.fullName
        }
        if staff.phone != "" {
            phone = staff.phone
        }
        if staff.email != "" {
            email = staff.email
        }
        let group = CrewFromContact.init(name: name, phone: phone, email: email , crew: [] )
        group.createGuid()
        newOfficer = UserAttendees.init(context: context)
        newOfficer.attendee = group.name
        newOfficer.attendeeEmail = group.email
        newOfficer.attendeePhone = group.phone
        newOfficer.attendeeModDate = group.attendeeDate
        newOfficer.attendeeGuid = group.attendeeGuid
        newOfficer.defaultCrewMember = group.overtimeB
        if staff.officerImage != nil {
            imageAvailable = true
            contactImage = staff.officerImage
            contactImageToURL()
        }
        saveToCD(guid: group.attendeeGuid, withCompletion: ({
            self.staffContactsVC.dismiss(animated: true, completion: nil)
           tableView.reloadData()
        })())
    }
    
    func contactImageToURL() {
        guard let image = contactImage, let data = image.jpegData(compressionQuality: 1) else {
            print("No image found")
            self.imageAvailable = false
            fatalError("###\(#function): Failed to get JPG data and URL of the picked image!")
        }
        let guid = UUID()
        let fileName = guid.uuidString + ".jpg"
        let url = CloudKitManager.attachmentFolder.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: url.path){
            
            do {
                try data.write(to: url)
                print("file saved")
                self.photoProvider.addPhotoStaff(imageData: data, imageURL: url, staff: self.newOfficer, taskContext: self.photoProvider.persistentContainer.viewContext, shouldSave: true, logo: false)
                self.contactImage = image
                self.imageAvailable = true
                guard let attachment = self.newOfficer.photo else { return }
                self.validPhotos.append(attachment)
                DispatchQueue.main.async {
                    print("we're all done here")
                }
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    
}

extension NewICS214ResourcesAssignedTVC: NewICS214ContactsTVCDelegate {
    func newICS214ContactsExit() {
    }
    
    func newICS214ContactsSave(crew: [CrewFromContact]) {
        print(crew)
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
                
                saveToCD(guid: group.attendeeGuid, withCompletion: ({
                    self.dismiss(animated: true, completion: nil)
                   tableView.reloadData()
                })())
            }
        }
    }
    
    func getTheNewestAttendeeAddToSelected(guid: String)->UserAttendees {
        var attendee: UserAttendees!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K = %@","attendeeGuid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let attend = try context.fetch(fetchRequest) as! [UserAttendees]
            if !attend.isEmpty {
                attendee = attend.last!
            }
            
        }  catch {
            let nserror = error as NSError
            let errorMessage = "NewICS214Resources getTheAttendees line 81 Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        return attendee
    }
    
    
}

extension NewICS214ResourcesAssignedTVC: NSFetchedResultsControllerDelegate {
    
    fileprivate func saveUAToCD(guid: String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214ResourcesAssignedTVC merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSaved(guid: guid)
                self.nc.post(name: NSNotification.Name(rawValue: FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        } catch let error as NSError {
            print("NewICS214ResourcesAssignedTVC line 325 Fetch Error: \(error.localizedDescription)")
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
    
    fileprivate func saveToCoreData() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214ResourcesAssignedTVC merge that"])
            }
        } catch let error as NSError {
            print("NewICS214ResourcesAssignedTVC line 140 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveToCD(guid: String, withCompletion completion: ()) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214ResourcesAssignedTVC merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSaved(guid: guid)
                self.nc.post(name: NSNotification.Name(rawValue: FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        } catch let error as NSError {
            print("NewICS214ResourcesAssignedTVC line 140 Fetch Error: \(error.localizedDescription)")
        }
        completion
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
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
//    {
//        switch type
//        {
//        case NSFetchedResultsChangeType.delete:
//            print("NSFetchedResultsChangeType.Delete detected")
//            if let deleteIndexPath = indexPath
//            {
//                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
//            }
//        case NSFetchedResultsChangeType.insert:
//            if let indexPath = newIndexPath {
//                tableView.insertRows(at: [indexPath], with: .fade)
//            }
//        case NSFetchedResultsChangeType.move:
//            print("NSFetchedResultsChangeType.Move detected")
//        case NSFetchedResultsChangeType.update:
//            if let indexPath = newIndexPath {
//                tableView.insertRows(at: [indexPath], with: .fade)
//            }
//            tableView.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
//        default: break
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
//    {
//        tableView.endUpdates()
//    }
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
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//            case .insert:
//                let sectionIndexSet = NSIndexSet(index: sectionIndex)
//                self.tableView.insertSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
//        case .delete:
//            let sectionIndexSet = NSIndexSet(index: sectionIndex)
//            self.tableView.deleteSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
//        default: break
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
//        return sectionName
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
//    {
//        switch type
//        {
//        case NSFetchedResultsChangeType.delete:
//            print("NSFetchedResultsChangeType.Delete detected")
//            if let deleteIndexPath = indexPath
//            {
//                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
//            }
//
//        case NSFetchedResultsChangeType.move:
//            print("NSFetchedResultsChangeType.Move detected")
//            if let deleteIndexPath = indexPath {
//                self.tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
//            }
//
//            // Note that for Move, we insert a row at the __newIndexPath__
//            if let insertIndexPath = newIndexPath {
//                self.tableView.insertRows(at: [insertIndexPath], with: UITableView.RowAnimation.fade)
//            }
//        default: break
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
//    {
//        tableView.endUpdates()
//    }
    
}
