//
//  SettingsDataTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/21/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol SettingsDataDelegate: AnyObject {
    func settingsDataBackToSettings()
}

class SettingsDataTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    //    MARK: -SettingsUserHeaderDelegate
    

    
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var settingType:FJSettings!
    var tags:UserTags!
    var rank:UserRank!
    var platoon:UserPlatoon!
    var resources:UserResources!
    var streetTypes:NFIRSStreetType!
    var localIncidentTypes:UserLocalIncidentType!
    var subject:String = ""
    var descriptionText:String = ""
    var newEntry:String = ""
    
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    weak var delegate:SettingsDataDelegate? = nil
    var alertUp: Bool = false
    var objectID: NSManagedObjectID!
    var theUser: FireJournalUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeader()
        
        _ = getTheData()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        if objectID != nil {
            theUser = context.object(with: objectID) as? FireJournalUser
            vcLaunch.userID = objectID
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            var buttonArray = [UIBarButtonItem]()
            
            navigationItem.leftItemsSupplementBackButton = true
            if let button3 = self.splitViewController?.displayModeButtonItem {
                buttonArray.append(button3)
                buttonArray.append(button1)
            } else {
                buttonArray.append(button1)
            }
            
            navigationItem.setLeftBarButtonItems(buttonArray, animated: true)
            
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
        
//        self.title = titleName
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
    }
    
    
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact SETTING DATA")
            case .regular:
                print("regular SETTING DATA")
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func configureHeader() {
        switch settingType {
        case .tags?:
            subject = "Fire Journal Tags"
            descriptionText = "At various places within Fire Journal, you have the option of adding Tags. This will assit you in finding or categorizing your incidents and other activities. If you cannot find a tag you’d like to use, create it here, in Settings. Add the name of the new tag in the field below, then tap on the + button. Do this as often as you need to.To delete a tag, swipe left."
            entity = "UserTags"
            attribute = "userTag"
            sortAttribute = "userTag"
        case .rank?:
            subject = "Fire Journal Rank"
            descriptionText = "If you do not find the appropriate rank when using Forms, Incidents, or other aspects of Fire Journal, you may add a new rank within Settings. Simply type in the rank in the field below, then tap on the + button. To delete a rank, swipe left."
            entity = "UserRank"
            attribute = "rank"
            sortAttribute = "rank"
        case .platoon?:
            subject = "Fire Journal Platoon"
            descriptionText = "If you do not find the appropriate Platoon when using Dashboard, Forms, Incidents, or other aspects of Fire Journal, you may add a new Platoon within Settings. Simply type in the Platoon in the field below, then tap on the + button. To delete a Platoon, swipe left."
            entity = "UserPlatoon"
            attribute = "platoon"
            sortAttribute = "platoon"
        case .resources?:
            subject = "Fire Department Resources"
            descriptionText = "Fire Journal is set up to allow you to not only manage what you do in managing your fire station and incidents, but to also manage the apparatus (resources) within your fire station - using the ID assigned by your Departent. For example, BC1 may relate to Battalion Chief for the Battalion 1 district. You may edit the list below to better conform to your Department. Simply type in the resource in the field below, then tap on the + button. To delete a resource, swipe left."
            entity = "UserResources"
            attribute = "resource"
            sortAttribute = "resource"
        case .streetTypes?:
            subject = "NFIRS Street Types"
            descriptionText = "The list below indicates the NFIRS required listing of street types used when completing an NFIRS or NIMS form. You should not need to modify this list, unless a new street type is added. To do so, just enter the type in the same format as shown below in the field provided. To delete a street type, simply swipe left on the selected street type."
            entity = "NFIRSStreetType"
            attribute = "streetType"
            sortAttribute = "streetType"
        case .localIncidentTypes?:
            subject = "Fire Journal Local Incident Types"
            descriptionText = "In addition to the incident types required for NFIRS and other official state and federal forms, your Department may have its own locally named terms for incidents. You may adjust the list below to fit those requirements. Simple type in the local incident name in the field below, then tap on the + button. To delete a name, swipe left."
            entity = "UserLocalIncidentType"
            attribute = "localIncidentTypeName"
            sortAttribute = "localIncidentTypeName"
        default:
            break
        }
    }
    
    @IBAction func goBackToSettings(_ sender: Any) { 
        if collapsed {
            delegate?.settingsDataBackToSettings()
        } else {
            if let id = objectID {
                nc.post(name:Notification.Name(rawValue: FJkSETTINGS_FROM_MASTER),
                        object: nil,
                        userInfo: ["sizeTrait":compact,"userObjID": id])
                }
        }
    }
    
    @IBAction func updateTheData(_ sender: Any) {
        if collapsed {
            delegate?.settingsDataBackToSettings()
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"SettingsDataTVC merge that"])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "SettingsDataTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
        }
    }

    // MARK: - Table view data source
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("SettingsUserHeaderV", owner: self, options: nil)?.first as! SettingsUserHeaderV
        let color = ButtonsForFJ092018.gradient9Color2
        headerV.colorV.backgroundColor = color
        headerV.subjectL.text = subject
        headerV.addToListB.tintColor = UIColor.white
        headerV.saveButton.isHidden = true
        headerV.saveButton.isEnabled = false
        headerV.saveButton.alpha = 0.0
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 88
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }

    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch settingType {
        case .tags?:
            let tags:UserTags =  _fetchedResultsController?.object(at: indexPath) as! UserTags
            cell.textLabel?.text = tags.userTag
        case .rank?:
            let rank:UserRank =  _fetchedResultsController?.object(at: indexPath) as! UserRank
            cell.textLabel?.text = rank.rank
        case .platoon?:
            let platoon:UserPlatoon =  _fetchedResultsController?.object(at: indexPath) as! UserPlatoon
            cell.textLabel?.text = platoon.platoon
        case .resources?:
            let resources:UserResources =  _fetchedResultsController?.object(at: indexPath) as! UserResources
            cell.textLabel?.text = resources.resource
        case .streetTypes?:
            let streetType:NFIRSStreetType =  _fetchedResultsController?.object(at: indexPath) as! NFIRSStreetType
            cell.textLabel?.text = streetType.streetType
        case .localIncidentTypes?:
            let incidentType:UserLocalIncidentType =  _fetchedResultsController?.object(at: indexPath) as! UserLocalIncidentType
            cell.textLabel?.text = incidentType.localIncidentTypeName
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                var attendee = _fetchedResultsController?.object(at: indexPath)
                context.delete(attendee! as! NSManagedObject)
                saveToCD()
                attendee = nil
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    private func getTheData() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",self.attribute,"")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: self.sortAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsDataTVC getTheData() Unresolved error \(nserror)"
            print(errorMessage)
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkPERSISTENT_STORE_ERROR_REPORTING), object: nil, userInfo:["errorMessage":errorMessage])
//            }
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
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

extension SettingsDataTVC: SettingsUserHeaderDelegate {
    
    func userHeaderInfoBTapped() {
       if !alertUp {
                presentTheAlert()
            }
        }
                    
        func presentTheAlert() {
            let title = "\(subject) Support Notes"
            let alert = UIAlertController.init(title: title, message: descriptionText, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    
    func saveButtonTapped(){}
    func addNewItemTapped(new: String) {
        newEntry = new
        let modDate = Date()
        switch settingType {
        case .tags?:
            let tag = UserTags.init(entity: NSEntityDescription.entity(forEntityName: "UserTags", in: context)!, insertInto: context)
            tag.userTag = newEntry
            let guidDate = GuidFormatter.init(date:modDate)
            let guid = guidDate.formatGuid()
            tag.userTagGuid = "74."+guid
            tag.userTagModDate = modDate
            tag.entryState = EntryState.new.rawValue
            tag.userTagBackup = false
        case .rank?:
            let rank = UserRank.init(entity: NSEntityDescription.entity(forEntityName: "UserRank", in: context)!, insertInto: context)
            rank.rank = newEntry
            let guidDate = GuidFormatter.init(date:modDate)
            let guid = guidDate.formatGuid()
            rank.rankGuid = "70."+guid
            rank.rankModDate = modDate
            rank.entryState = EntryState.new.rawValue
            rank.rankBackUp = false
        case .platoon?:
            let platoon = UserPlatoon.init(entity: NSEntityDescription.entity(forEntityName: "UserPlatoon", in: context)!, insertInto: context)
            platoon.platoon = newEntry
            let guidDate = GuidFormatter.init(date:modDate)
            let guid = guidDate.formatGuid()
            platoon.platoonGuid = "67."+guid
            platoon.platoonModDate = modDate
            platoon.entryState = EntryState.new.rawValue
            platoon.platoonBackUp = false
        case .resources?:
            let resource = UserResources.init(entity: NSEntityDescription.entity(forEntityName: "UserResources", in: context)!, insertInto: context)
            resource.resource = newEntry
            let guidDate = GuidFormatter.init(date:modDate)
            let guid = guidDate.formatGuid()
            resource.resourceGuid = "72."+guid
            resource.resourceModificationDate = modDate
            resource.entryState = EntryState.new.rawValue
            resource.resourceBackUp = false
        case .streetTypes?:
            let streetType = NFIRSStreetType.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSStreetType", in: context)!, insertInto: context)
            streetType.streetType = newEntry
            let guidDate = GuidFormatter.init(date:modDate)
            let guid = guidDate.formatGuid()
            streetType.streetTypeGuid = "50."+guid
            streetType.nfirsSTModDate = modDate
            streetType.entryState = EntryState.new.rawValue
            streetType.nfirsSTBackedUp = false
        case .localIncidentTypes?:
            let incidentType = UserLocalIncidentType.init(entity: NSEntityDescription.entity(forEntityName: "UserLocalIncidentType", in: context)!, insertInto: context)
            incidentType.localIncidentTypeName = newEntry
            let guidDate = GuidFormatter.init(date:modDate)
            let guid = guidDate.formatGuid()
            incidentType.localIncidentGuid = "52."+guid
            incidentType.localIncidentTypeModDate = modDate
            incidentType.entryState = EntryState.new.rawValue
            incidentType.localIncidentTypeBackUp = false
        default: break
        }
    }
}
