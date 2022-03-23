//
//  SettingsCrewTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/21/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol SettingsCrewDelegate: AnyObject {
    func crewSettingsToSettings()
    func crewAskingForContactList(settings:FJSettings)
}

class SettingsCrewTVC: UITableViewController,CrewMemberHeaderVDelegate, NSFetchedResultsControllerDelegate,CrewMemberEditCellDelegate,SettingsContactsDelegate {
    
    //    MARK: -SettinsContactsDelegate
    func settingsContactCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func settingsContactSaved(crew: Array<CrewFromContact>) {
        self.dismiss(animated: true, completion: nil)
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
        }
        tableView.reloadData()
    }
    
    //    MARK: -CrewMemberEditCellDelegate
    func theCrewSaveButtonTapped(_ modelID: NSManagedObjectID, attendee: UserAttendees, textOne: String, textTwo: String, textThree: String, textFour: String, textFive: String) {
        print(attendee)
        attendee.attendee = textOne
        attendee.attendeePhone = textTwo
        attendee.attendeeEmail = textThree
        attendee.attendeeHomeAgency = textFour
        attendee.attendeeICSPosition = textFive
        tableView.reloadData()
    }
    
    
    
    func addNewMemberBTapped(crew: String) {
        let attendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
        attendee.attendee = crew
        let attendeeDate = Date()
        let groupDate = GuidFormatter.init(date:attendeeDate)
        let grGuid:String = groupDate.formatGuid()
        let attendeeGuid = "79."+grGuid
        attendee.attendeeGuid = attendeeGuid
        attendee.attendeeModDate = attendeeDate
        attendee.attendeeBackUp = false
        tableView.reloadData()
    }
    
    
    func getTheContactsList() {
        if collapsed {
            delegate?.crewAskingForContactList(settings: FJSettings.contacts)
        } else {
        nc.post(name:Notification.Name(rawValue:FJkSETTINGSCONTACTSCalled),
                object: nil,
                userInfo: ["sizeTrait":compact])
        }
    }
    
    
    
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    weak var delegate:SettingsCrewDelegate? = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fetched:Array<Any>!
    var attendees:UserAttendees!
    var settingType:FJSettings!
    var segue:String = "SettingsContactsSegue"
    var selected: Array<String> = []
    var splitVC: UISplitViewController?
    
    var compact:SizeTrait = .regular
    var collapsed:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = getTheAttendeesData()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            navigationItem.setLeftBarButtonItems([ button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.leftItemsSupplementBackButton = true
            let button3 = splitVC?.displayModeButtonItem
            navigationItem.setLeftBarButtonItems([button3!, button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        }
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            //            let backgroundImage = UIImage(named: "headerBar2")
            //            self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
        self.title = titleName
        
         tableView.register(UINib(nibName: "CrewMemberEditCellTableViewCell", bundle: nil), forCellReuseIdentifier: "CrewMemberEditCellTableViewCell")
        
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
    }
    
    
    
    @objc func compactOrRegular(ns: Notification) {
//        if let userInfo = ns.userInfo as! [String: Any]?
//        {
//            compact = userInfo["compact"] as? SizeTrait ?? .regular
//            switch compact {
//            case .compact:
//                print("compact SETTING CREW")
//            case .regular:
//                print("regular SETTING CREW")
//            }
//        }
//        
//        self.tableView.reloadData()
    }
    
    
    @IBAction func goBackToSettings(_ sender: Any) {
        if collapsed {
            delegate?.crewSettingsToSettings()
        } else {
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
        }
    }
    @IBAction func updateTheData(_ sender: Any) {
        if collapsed {
            delegate?.crewSettingsToSettings()
        } else {
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
        }
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Settings Crew merge that"])
            }
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsCrewTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkPERSISTENT_STORE_ERROR_REPORTING), object: nil, userInfo:["errorMessage":errorMessage])
//            }
        }
    }
    
    // MARK: - Table view data source
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("CrewMemberHeaderV", owner: self, options: nil)?.first as! CrewMemberHeaderV
        let color = ButtonsForFJ092018.blueGradientColor2
        headerV.colorV.backgroundColor = color
        headerV.subjetL.text = "Crew Members"
        headerV.descriptionTV.text = "Type in a new crew member name, or select from your contacts. To delete swipe left. Build your crew in the Dashboard area. The list of members here will show in the list of members to build your crew."
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
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
        return 212
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewMemberEditCellTableViewCell", for: indexPath) as! CrewMemberEditCellTableViewCell
        configureCell(cell, at: indexPath)
        return cell
    }

    func configureCell(_ cell: CrewMemberEditCellTableViewCell, at indexPath: IndexPath) {
        cell.attendee =  _fetchedResultsController?.object(at: indexPath)
        cell.text1 = cell.attendee.attendee ?? ""
        cell.text2 = cell.attendee.attendeePhone ?? ""
        cell.text3 = cell.attendee.attendeeEmail ?? ""
        cell.text4 = cell.attendee.attendeeHomeAgency ?? ""
        cell.text5 = cell.attendee.attendeeICSPosition ?? ""
        cell.textOneTF.text = cell.attendee.attendee ?? ""
        cell.textTwoTF.text = cell.attendee.attendeePhone ?? ""
        cell.textThreeTF.text = cell.attendee.attendeeEmail ?? ""
        cell.textFourTF.text = cell.attendee.attendeeHomeAgency ?? ""
        cell.textFiveTF.text = cell.attendee.attendeeICSPosition ?? ""
        cell.modelID = cell.attendee.objectID
        cell.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                var attendee = _fetchedResultsController?.object(at: indexPath)
                context.delete(attendee!)
                saveToCD()
                attendee = nil
            }
        } else if editingStyle == .insert { }
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
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsCrewTVC getTheAttendeeData() Unresolved error \(nserror)"
            print(errorMessage)
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
                saveToCD()
            }
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
        case NSFetchedResultsChangeType.update:
//            print("NSFetchedResultsChangeType.update detected")
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CrewMemberEditCellTableViewCell {
                configureCell(cell, at: indexPath)
                saveToCD()
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
