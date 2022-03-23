//
//  SettingsMyResourcesTVC.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/5/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

protocol SettingsMyResourcesTVCDelegate: AnyObject {
    func settingsMyFireStationResourcesBackToSettings()
}

class SettingsMyResourcesTVC: UITableViewController {
    
    var resources = [UserFDResource]()
    var alertUp: Bool = false
    
    var resourceDescriptionHeight: CGFloat = 65
    var titleName: String = ""
    var settingsType: FJSettings!
    var compact: SizeTrait!
    let nc = NotificationCenter.default
    var collapsed:Bool = false
    weak var delegate: SettingsMyResourcesTVCDelegate? = nil
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var deletedGuid: String = ""
    
    var fetchedResources = [UserFDResources]()
    
    private var fetchedResultsController: NSFetchedResultsController<UserFDResources>? = nil
    var _fetchedResultsController: NSFetchedResultsController<UserFDResources> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [UserFDResources] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func buildResources() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        //        getUserFDResources()
        fetchTheResources()
        registerCells()
        
        tableView.rowHeight = UITableView.automaticDimension
        if  Device.IS_IPAD {
            tableView.estimatedRowHeight = 230
        } else {
            tableView.estimatedRowHeight = 285
        }
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.leftItemsSupplementBackButton = true
            let button3 = self.splitViewController?.displayModeButtonItem
            navigationItem.setLeftBarButtonItems([button3!, button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        default: break
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    //    MARK: -BAR BUTTON ACTIONS-
    @IBAction func updateTheData(_ sender: Any) {
        closeItUp()
    }
    
    func closeItUp() {
        if  Device.IS_IPHONE {
            delegate?.settingsMyFireStationResourcesBackToSettings()
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),object: nil, userInfo: ["sizeTrait":compact!])
        }
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        closeItUp()
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "SettingMyResourceTVCell", bundle: nil), forCellReuseIdentifier: "SettingMyResourceTVCell")
        tableView.register(UINib(nibName: "SettingMyResourcePhoneTVCell", bundle: nil), forCellReuseIdentifier: "SettingMyResourcePhoneTVCell")
        
    }
    
    //    MARK: - Table View Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("SettingsMyResourcesHeaderV", owner: self, options: nil)?.first as! SettingsMyResourcesHeaderV
        headerV.backgroundV.backgroundColor = ButtonsForFJ092018.gradient9Color2
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    // MARK: - Table view data source
    private func getDescriptionSize(description: String) ->CGFloat {
        if description != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: resourceDescriptionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = description
            let estimatedSize = textView.sizeThatFits(size)
            if Device.IS_IPAD {
                resourceDescriptionHeight = estimatedSize.height + 237
                if resourceDescriptionHeight < 330 {
                    resourceDescriptionHeight = 330
                }
            } else {
                resourceDescriptionHeight = estimatedSize.height + 250
                if resourceDescriptionHeight < 325 {
                    resourceDescriptionHeight = 325
                }
            }
        } else {
            if Device.IS_IPAD {
                resourceDescriptionHeight = 330
            } else {
                resourceDescriptionHeight = 325
            }
        }
        return resourceDescriptionHeight
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0...resources.count:
            let resource = resources[row]
            let desc = resource.resourceDescription
            resourceDescriptionHeight = getDescriptionSize(description: desc)
            return resourceDescriptionHeight
        default:
            return 44
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = _fetchedResultsController.sections
               {
                   let currentSection = sections[section]
                   return currentSection.numberOfObjects
               }
         return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = configureCell(at: indexPath)
        return cell
    }
    
    func configureCell( at indexPath: IndexPath)->UITableViewCell {
        if Device.IS_IPAD {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingMyResourceTVCell", for: indexPath) as! SettingMyResourceTVCell
            let row = indexPath.item
            cell.resource = resources[row]
            cell.row = row
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingMyResourcePhoneTVCell", for: indexPath) as! SettingMyResourcePhoneTVCell
            let row = indexPath.item
            cell.resource = resources[row]
            cell.row = row
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                //                let cell = tableView.cellForRow(at: indexPath) as! SettingMyResourcePhoneTVCell
                //                let objID = cell.resource?.objectID
                //                var resource = context.object(with: objID!) as? UserFDResources
                //                context.delete(resource! as NSManagedObject)
                let resource = _fetchedResultsController.object(at: indexPath)
                deletedGuid = resource.fdResourceGuid ?? ""
                bkgrdContext.delete(resource as NSManagedObject)
                saveDeleteToCoreDate()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}

extension SettingsMyResourcesTVC: SettingMyResourcePhoneTVCellDelegate {
    
    func phoneEditBTapped(row: Int) {
        let storyboard = UIStoryboard(name: "ResourceEdit", bundle: nil)
        let editVC  = storyboard.instantiateViewController(identifier: "ResourceVC") as! ResourceVC
        editVC.resource = resources[row]
        editVC.row = row
        editVC.delegate = self
        present(editVC, animated: true )
    }
    
    
}

extension SettingsMyResourcesTVC: SettingsMyResourcesHeaderVDelegate {
    func myResourcesInfoBTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let title: InfoBodyText = .myFireStationResourcesSupportNotesSubject
        let message: InfoBodyText = .myFireStationResourcesSupportNotes
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
}

extension SettingsMyResourcesTVC: SettingMyResourceTVCellDelegate {
    func editBTapped(row: Int) {
        //        let indexPath = IndexPath(row: row, section: 0)
        let storyboard = UIStoryboard(name: "ResourceEdit", bundle: nil)
        let editVC  = storyboard.instantiateViewController(identifier: "ResourceVC") as! ResourceVC
        editVC.resource = resources[row]
        editVC.row = row
        editVC.delegate = self
        present(editVC, animated: true )
    }
}

extension SettingsMyResourcesTVC: ResourceVCDelegate {
    func resourceSaveTapped(resource: UserFDResource,row: Int) {
        resources[row] = resource
        let firstStationResource = getTheFireStationResource(objectID: resource.objectID)
        saveTheEdittedFireStationResource(fireStationResource: firstStationResource, resource: resource, objectID:  resource.objectID )
        print(resources[row])
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func resourceCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTheFireStationResource(objectID: NSManagedObjectID) -> UserFDResources  {
        let fireStationResource = fetchedObjects.filter{ $0.objectID == objectID }
        return fireStationResource.first!
    }
    
    func saveTheEdittedFireStationResource(fireStationResource: UserFDResources, resource: UserFDResource, objectID: NSManagedObjectID ) {
        fireStationResource.fdManufacturer = resource.resourceManufacturer
        fireStationResource.fdResource = resource.resource
        fireStationResource.fdResourceApparatus = resource.resourceApparatus
        fireStationResource.fdResourceBackup = false
        fireStationResource.fdResourceDescription = resource.resourceDescription
        fireStationResource.fdResourceID = resource.resourceID
        fireStationResource.fdResourceImageName = resource.resource
        fireStationResource.fdResourceModDate = Date()
        fireStationResource.fdResourcesPersonnelCount = String(resource.resourcePersonnelCount)
        fireStationResource.fdResourcesSpecialties = resource.resourceSpecialities
        fireStationResource.fdResourceType = resource.resourceType
        fireStationResource.fdShopNumber = resource.resourceShopNumber
        fireStationResource.fdYear = resource.resourceYear
        saveToCoreData(objectID: objectID)
    }
    
    func saveToCoreData(objectID: NSManagedObjectID) {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsMyResourcesTVC merge that"])
            }
            DispatchQueue.main.async { [weak self] in
                self?.nc.post(name: Notification.Name(rawValue: FJkFDRESOURCESMODIFIEDTOCLOUD),
                              object: nil, userInfo: ["objectID":objectID])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "SettingsMyResourcesTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    func saveDeleteToCoreDate() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsMyResourcesTVC merge that"])
            }
            DispatchQueue.main.async { [weak self] in
                self?.nc.post(name: Notification.Name(rawValue: FJkFDRESOURCESDELETETOCLOUD),
                              object: nil, userInfo: ["guid": self?.deletedGuid as Any])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "SettingsMyResourcesTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    
    
}

extension SettingsMyResourcesTVC: NSFetchedResultsControllerDelegate {
    
    func fetchTheResources() {
        let fetchRequest: NSFetchRequest<UserFDResources> = UserFDResources.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.bkgrdContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("SettingMyFDResourcesTVC line 355 Fetch Error: \(error.localizedDescription)")
        }
        
        if fetchedObjects.isEmpty || fetchedObjects.count == 0 {
            closeItUp()
        } else {
            for resource in fetchedObjects {
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
                resources.append(r)
            }
        }
    }
    
    //    func getUserFDResources() {
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
    //        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
    //        let sortDescriptors = [sectionSortDescriptor]
    //        fetchRequest.sortDescriptors = sortDescriptors
    //        do {
    //            fetchedResources = try context.fetch(fetchRequest) as! [UserFDResources]
    //            if fetchedResources.count == 0 {
    //                closeItUp()
    //            } else {
    //                for resource in fetchedResources {
    //                    let objectID = resource.objectID
    //                    var customImage: Bool = false
    //                    let imageType: Int64 = resource.fdResourceType
    //                    var name: String = ""
    //                    if let resourceName = resource.fdResource {
    //                        name = resourceName
    //                    }
    //                    if resource.customResource {
    //                            customImage = true
    //                    }
    //                    let r = UserFDResource.init(type: imageType, resource: name, objectID: objectID, custom: customImage)
    //                    r.resourceStatusImageName = resource.fdResource ??  ""
    //                    if let count = Int64(resource.fdResourcesPersonnelCount ?? "0") {
    //                        r.resourcePersonnelCount = count
    //                    }
    //                    r.resourceManufacturer = resource.fdManufacturer ?? ""
    //                    r.resourceID = resource.fdResourceID ?? ""
    //                    r.resourceShopNumber = resource.fdShopNumber ?? ""
    //                    r.resourceApparatus = resource.fdResourceApparatus ?? ""
    //                    r.resourceSpecialities = resource.fdResourcesSpecialties ?? ""
    //                    r.resourceDescription = resource.fdResourceDescription ?? ""
    //                    resources.append(r)
    //                }
    //            }
    //        }  catch {
    //            let nserror = error as NSError
    //            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
    //            print(errorMessage)
    //        }
    //
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
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
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
