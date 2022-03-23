//
//  SettingsUserFDResourcesTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit


protocol SettingsUserFDResourcesTVCDelegate: AnyObject {

    func userFDResourcesBackToSettings()
}

class SettingsUserFDResourcesTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
    var fdResources: UserFDResources!
    var fdResourcesA = [String]()
    var subject:String = ""
    var descriptionText:String = ""
    var newEntry:String = ""
    
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    var selected: Array<String> = []
    var alertUp: Bool = false
    var theResources: Array<String>!
    var customResource: Bool = false
    var theResourceName: String = ""
    var fju: FireJournalUser!
    weak var delegate: SettingsUserFDResourcesTVCDelegate? = nil
    var count: Int = 0
    var closed: Bool = false
    var resources = [String]()
    var displayOrders = [Int]()
    var fetchedResources = [UserResources]()
    
    var userResourcesFetched: Array<UserResources>!
    var objectID: NSManagedObjectID!
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var firstRun: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        getTheFireJournalUser()
        getUserFDResources()
        configureHeader()
        
        
        //        MARK: - NEED DATA FOR TABLE
        _ = getTheData()
        tableView.allowsMultipleSelection = true
        
        if firstRun {} else {
            switch compact {
            case .compact:
                let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
                let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheData(_:)))
                
                navigationItem.setLeftBarButtonItems([button1], animated: true)
                
                navigationItem.setRightBarButtonItems([button2], animated: true)
            case .regular:
//                let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
//                let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheData(_:)))
//
//                navigationItem.leftItemsSupplementBackButton = true
//                let button3 = self.splitViewController?.displayModeButtonItem
//                navigationItem.setLeftBarButtonItems([button3!, button1], animated: true)
//
//                navigationItem.setRightBarButtonItems([button2], animated: true)
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
        }
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        tableView.register(UINib(nibName: "UserResourceCell", bundle: nil), forCellReuseIdentifier: "UserResourceCell")
        tableView.register(UINib(nibName: "SettingsCustomFDResourceCell", bundle: nil), forCellReuseIdentifier: "SettingsCustomFDResourceCell")
        tableView.register(UINib(nibName: "SettingsFDResourcesCell", bundle: nil), forCellReuseIdentifier: "SettingsFDResourcesCell")
    }
    
    
    @IBAction func updateTheData(_ sender: Any) {
        closed = true
        if fdResourcesA.isEmpty {
            for select in selected {
                createNewUserFDResources(resource: select)
            }
        } else {
            for select in selected {
                let result = fdResourcesA.filter { $0 == select}
                if result.isEmpty {
                    let resource: String = select
                    createNewUserFDResources(resource: resource)
                }
            }
        }
        updateUserResource()
    }
    
    func removeFromFDResourceWhenDeSelected(resource: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@","fdResource",resource)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            let fetchedResources = try bkgrdContext.fetch(fetchRequest) as! [UserFDResources]
            
            if fetchedResources.count != 0 {
                for resource in fetchedResources {
                    if let guid = resource.fdResourceGuid {
                        DispatchQueue.main.async { [weak self] in
                            self?.nc.post(name:Notification.Name(rawValue:FJkFDRESOURCESDELETETOCLOUD),
                                          object: nil,
                                          userInfo: ["guid":guid])
                        }
                    }
                    bkgrdContext.delete(resource)
                    do {
                        try bkgrdContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsUsretFDResources merge that"])
                        }
                        //                        FJkFDRESOURCESDELETETOCLOUD
                    }   catch let error as NSError {
                        let nserror = error
                        
                        let errorMessage = "SettingsUsretFDResources saveToCD() Unresolved error \(nserror)"
                        print(errorMessage)
                    }
                }
                
                getUserFDResources()
            }
            
        } catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        updateUserResource()
        
    }
    
    func getUserFDResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetchedResources = try context.fetch(fetchRequest) as! [UserFDResources]
            
            if fetchedResources.count == 0 {
                print("hey we have zero")
            } else {
                for resource in fetchedResources {
                    let result = fdResourcesA.filter { $0 == resource.fdResource}
                    if result.isEmpty {
                        fdResourcesA.append(resource.fdResource!)
                        if count < 10 {
                            selected.append(resource.fdResource!)
                            count = count+1
                        }
                    }
                }
                print(selected)
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources")
        let sectionSortDescriptor2 = NSSortDescriptor(key: "displayOrder", ascending: false)
        let sortDescriptors2 = [sectionSortDescriptor2]
        fetchRequest2.sortDescriptors = sortDescriptors2
        do {
            let fetchedForm = try context.fetch(fetchRequest2) as! [UserResources]
            for fetched in fetchedForm {
                let result = fdResourcesA.filter { $0 == fetched.resource}
                if !result.isEmpty {
                    fetched.fdResource = true
                    saveToCData()
                }
            }
        } catch {
            let errorMessage = "class UserResourcesOperation: FJOperation saveToCoreData context was unable to save due to \(error.localizedDescription) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        
    }
    
    func getTheFireJournalUser() {
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser")
        do {
            let userFetched = try context.fetch(userRequest) as! [FireJournalUser]
            if userFetched.count != 0 {
                fju = userFetched.last!
            }
        } catch let error as NSError {
            print("fJU error line 188 \(error.localizedDescription)")
        }
    }
    
    func markAllUserResourcesAsFDResourceFalse() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources")
        fetchRequest.fetchBatchSize = 20
        do {
            let userResource = try bkgrdContext.fetch(fetchRequest) as! [UserResources]
            if userResource.count != 0 {
                for resource in userResource {
                    resource.fdResource = false
                    saveToCData()
                }
            }
        } catch let error as NSError {
            print("fJU error line 188 \(error.localizedDescription)")
        }
    }
    
    func updateUserResource() {
        markAllUserResourcesAsFDResourceFalse()
        for select in selected {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources")
            
            var predicate = NSPredicate.init()
            predicate = NSPredicate(format: "%K == %@","resource",select)
            
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 20
            
            let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 1
            do {
                let userResource = try bkgrdContext.fetch(fetchRequest) as! [UserResources]
                if userResource.count != 0 {
                    let resource = userResource.last!
                    resource.fdResource = true
                    saveToCData()
                } else {
                    let newResource = TheResource.init(resource:select)
                    newResource.createGuid()
                    newResource.getDisplayOrder()
                    _ = newResource.addNewResource()
                    saveToCData()
                }
            } catch let error as NSError {
                print("fJU error line 188 \(error.localizedDescription)")
            }
        }
        if closed {
            closeItUp()
        }
    }
    
    func closeItUp() {
        if collapsed {
            delegate?.userFDResourcesBackToSettings()
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                    object: nil,
                    userInfo: ["sizeTrait":compact])
        }
    }
    
    func createNewUserFDResources(resource: String) {
        getFDResourceImageName(resource: resource)
        let modDate = Date()
        let fdResource = TheFDResource.init(fdResource: resource, fdResourceDate: modDate)
        
        let userFDResource = UserFDResources.init(entity: NSEntityDescription.entity(forEntityName: "UserFDResources", in: bkgrdContext)!, insertInto: bkgrdContext)
        userFDResource.fdResource = resource
        userFDResource.customResource = customResource
        userFDResource.fdResourceBackup = false
        let guid = fdResource.createFDResourceGuid()
        userFDResource.fdResourceGuid = guid
        userFDResource.fdResourceImageName = theResourceName
        userFDResource.fdResourceModDate = modDate
        userFDResource.fdResourceCreationDate = modDate
        userFDResource.auserReferenceSC = fju.aFJUReferenceSC
        userFDResource.fdResourceType = 0002
        saveToCD(guid: guid)
    }
    
    func getFDResourceImageName(resource: String) {
        theResources = theFDResources.allCases.map{ $0.rawValue }
        let result = theResources.filter { $0 == resource}
        if result.isEmpty {
            customResource = true
            theResourceName = "Custom"
        } else {
            customResource = false
            theResourceName = resource
        }
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
    
    @IBAction func goBackToSettings(_ sender: Any) {
        if collapsed {
            delegate?.userFDResourcesBackToSettings()
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),object: nil, userInfo: ["sizeTrait":compact])
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func saveToCoreDate(guid: String) {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsUserFDResources merge that"])
            }
            getTheLastSaved(guid: guid)
            print(self.objectID as Any)
//            DispatchQueue.main.async {
//                self.nc.post(name:Notification.Name(rawValue:FJkUSERRESOURCENEWTOCLOUD),
//                             object: nil,
//                             userInfo: ["objectID":self.objectID as NSManagedObjectID])
//            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "SettingsUserFDResources saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    func saveToCData() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsUserFDResources merge that"])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "SettingsUserFDResources saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    fileprivate func saveToCD(guid: String) {
        do {
            print(selected)
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsUserFDResources merge that"])
            }
            getTheLastSavedFDResource(guid: guid)
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkFDRESOURCESNEWTOCLOUD),
                             object: nil,
                             userInfo: ["objectID":self.objectID as NSManagedObjectID])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "SettingsUsretFDResources saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    func getTheLastSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources" )
        let predicate = NSPredicate(format: "%K == %@", "resourceGuid", guid)
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "resourceModificationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 1
        do {
            self.fetched = try bkgrdContext.fetch(fetchRequest) as! [UserResources]
            if fetched.isEmpty {} else {
                let uFDResource = self.fetched.last as! UserResources
                self.objectID = uFDResource.objectID
            }
        } catch let error as NSError {
            print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func getTheLastSavedFDResource(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources" )
        let predicate = NSPredicate(format: "%K == %@", "fdResourceGuid", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResourceCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            self.fetched = try bkgrdContext.fetch(fetchRequest) as! [UserFDResources]
            if fetched.isEmpty {} else {
                let uFDResource = self.fetched.last as! UserFDResources
                self.objectID = uFDResource.objectID
            }
        } catch let error as NSError {
            print("SettingsUserFDResourcesTVC Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func configureHeader() {
        subject = "Fire/EMS Resources"
        
        entity = "UserResources"
        attribute = "resource"
        sortAttribute = "resource"
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("SettingsUserHeaderV", owner: self, options: nil)?.first as! SettingsUserHeaderV
        let color = ButtonsForFJ092018.gradient9Color2
        headerV.colorV.backgroundColor = color
        headerV.subjectL.text = subject
        headerV.addToListB.tintColor = UIColor.white
//        headerV.descriptionTV.text = descriptionText
        if firstRun {
            headerV.saveButton.isHidden = false
            headerV.saveButton.alpha = 1.0
            headerV.saveButton.isEnabled = true
        } else {
            headerV.saveButton.isHidden = true
            headerV.saveButton.alpha = 0.0
            headerV.saveButton.isEnabled = false
        }
        headerV.delegate = self
        return headerV
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 88
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        return 94
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = _fetchedResultsController?.object(at: indexPath) as? UserResources
        if resource!.resourceCustom {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCustomFDResourceCell", for: indexPath) as! SettingsCustomFDResourceCell
            configureCustomCell(cell, at: indexPath,resource: resource!)
            return cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsFDResourcesCell", for: indexPath) as! SettingsFDResourcesCell
            configureSettingsFDResourceCell(cell, at: indexPath,resource: resource!)
        return cell
        }
    }
    
    func configureCustomCell(_ cell: SettingsCustomFDResourceCell, at indexPath: IndexPath, resource: UserResources) {
        cell.resource = resource
        let result = selected.filter { $0 == resource.resource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func configureSettingsFDResourceCell(_ cell: SettingsFDResourcesCell, at indexPath: IndexPath, resource: UserResources) {
        cell.resource = resource
        let result = selected.filter { $0 == resource.resource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func configureCell(_ cell: UserResourceCell, at indexPath: IndexPath) {
        cell.resource =  _fetchedResultsController?.object(at: indexPath) as? UserResources
        let resource = cell.resource?.resource ?? ""
        let result = selected.filter { $0 == resource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resource = _fetchedResultsController?.object(at: indexPath) as? UserResources
        if resource!.resourceCustom {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsCustomFDResourceCell
            let name = cell.resource?.resource ?? ""
            count = count+1
            let result = selected.filter { $0 == name}
            if result.isEmpty {
                print("here is count: \(count) and selected.count \(selected.count)")
                if count < 11 {
                    selected.append(name)
                    cell.isSelected = true
                    print("here is selected.count \(selected.count) \(selected)")
                } else {
                    count = 10
                    cell.isSelected = false
                    if !alertUp {
                        let title: InfoBodyText = .fireEMSResourcesSupportSubject
                        let message: InfoBodyText = .fireEMSResourcesSupport
                        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                            self.alertUp = false
                        })
                        alert.addAction(okAction)
                        alertUp = true
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsFDResourcesCell
            let name = cell.resource?.resource ?? ""
            count = count+1
            let result = selected.filter { $0 == name}
            if result.isEmpty {
                print("here is count: \(count) and selected.count \(selected.count)")
                if count < 11 {
                    selected.append(name)
                    cell.isSelected = true
                    print("here is selected.count \(selected.count) \(selected)")
                } else {
                    count = 10
                    cell.isSelected = false
                    if !alertUp {
                        let title: InfoBodyText = . fireEMSResourcesSupportSubject
                        let message1: InfoBodyText = .fireEMSResourcesSupport
                        let message2: InfoBodyText = .fireEMSResourcesSupport2
                        let message = "\(message1.rawValue) \(name) \(message2.rawValue)"
                        let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                            self.alertUp = false
                        })
                        alert.addAction(okAction)
                        alertUp = true
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let resource = _fetchedResultsController?.object(at: indexPath) as? UserResources
        if resource!.resourceCustom {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsCustomFDResourceCell
            count = count-1
            cell.isSelected = false
            let theResource = cell.resource?.resource ?? ""
            selected = selected.filter { $0 != theResource }
            fdResourcesA = fdResourcesA.filter { $0 != theResource }
            removeFromFDResourceWhenDeSelected(resource: theResource)
            print("here is the new \(selected)")
        } else {
             let cell = tableView.cellForRow(at: indexPath)! as! SettingsFDResourcesCell
            count = count-1
            cell.isSelected = false
            let theResource = cell.resource?.resource ?? ""
            selected = selected.filter { $0 != theResource }
            fdResourcesA = fdResourcesA.filter { $0 != theResource }
            removeFromFDResourceWhenDeSelected(resource: theResource)
            print("here is the new \(selected)")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var resource = _fetchedResultsController?.object(at: indexPath) as? UserResources
        var uResource = ""
        if resource!.resourceCustom {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsCustomFDResourceCell
            uResource = cell.resource!.resource!
        } else {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsFDResourcesCell
            uResource = cell.resource!.resource!
        }
        selected = selected.filter { $0 != uResource }
        fdResourcesA = fdResourcesA.filter { $0 != uResource }
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                context.delete(resource!)
                saveToCData()
                removeFromFDResourceWhenDeSelected(resource: uResource)
                resource = nil
                tableView.reloadData()
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
        
        let fdResourceDescriptor = NSSortDescriptor(key: "fdResource", ascending: false)
        let sectionSortDescriptor = NSSortDescriptor(key: self.sortAttribute, ascending: true)
        let sortDescriptors = [fdResourceDescriptor,sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsUserFDResourcesTVC getTheData() Unresolved error \(nserror)"
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
//                saveToCoreDate()
            }
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
        case NSFetchedResultsChangeType.update: break
//            print("NSFetchedResultsChangeType.update detected")
            
//            let resource = _fetchedResultsController?.object(at: indexPath!) as? UserResources
//            if resource!.resourceCustom {
//                
//                if let indexPath = indexPath {
//                    let cell = tableView.cellForRow(at: indexPath) as! SettingsCustomFDResourceCell
//                    configureCustomCell(cell, at: indexPath, resource: resource!)
//                }
//            } else {
//                if let indexPath = indexPath {
//                    let cell = tableView.cellForRow(at: indexPath) as! SettingsFDResourcesCell
//                    configureSettingsFDResourceCell(cell, at: indexPath, resource: resource!)
//                }
//            }
//            saveToCD()
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

extension SettingsUserFDResourcesTVC: SettingsUserHeaderDelegate {
    
    func addNewItemTapped(new: String) {
        let newResource = TheResource.init(resource: new)
        newResource.createGuid()
        newResource.getDisplayOrder()
        let resource = newResource.addNewResource()
        selected.append(resource)
        let guid = newResource.resourceGuid
        saveToCoreDate(guid: guid)
    }
    
    func saveButtonTapped() {
        updateTheData(self)
    }
    
    func userHeaderInfoBTapped() {
        if !alertUp {
                presentTheAlert()
            }
        }
                    
        func presentTheAlert() {
            let title: InfoBodyText = .fireEMSResourcesSubject
            let message: InfoBodyText = .fireEMSResources
            let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
}
