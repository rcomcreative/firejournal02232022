//
//  SettingsProfileDataTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/26/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol SettingsProfileDataDelegate: AnyObject {
    func settingsProfileDataCanceled()
    func settingsProfileDataChosen(type:FJSettings,_ object:String )
}

class SettingsProfileDataTVC: UITableViewController,NSFetchedResultsControllerDelegate {

    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate:SettingsProfileDataDelegate? = nil
    var fetched:Array<Any>!
    var type:FJSettings!
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var fju: FireJournalUser!
    
    var compact:SizeTrait = .regular
    
    
    lazy var fdidProvider: UserFDIDProvider = {
        let provider = UserFDIDProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var fdidContext: NSManagedObjectContext!
    
    var userObjtID: NSManagedObjectID!
    var theUser: FireJournalUser!
    var theFDIDs = [UserFDID]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = titleName
        
        guard let _ = userObjtID else {
            delegate?.settingsProfileDataCanceled()
            return
        }
        theUser = context.object(with: userObjtID) as? FireJournalUser
        
        fdidContext = fdidProvider.persistentContainer.newBackgroundContext()
        if let fdid = fdidProvider.getTheFDIDForCityState(context: fdidContext, userID: userObjtID) {
            if fdid.isEmpty {
                if let fdids = fdidProvider.buildTheFDIDs(theGuidDate: Date(), backgroundContext: fdidContext) {
                    if  let fdid = fdidProvider.getTheFDIDForCityState(context: fdidContext, userID: userObjtID) {
                        theFDIDs = fdid
                    }
                }
            } else {
                theFDIDs = fdid
            }
        }
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        
            let button1 = UIBarButtonItem(title: "My Profile", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            navigationItem.setLeftBarButtonItems([button1], animated: true)
        
        let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "FJBlueColor"),
            .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
        ]
        button1.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
        button1.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "FJBlueColor")
            self.navigationController?.navigationBar.isTranslucent = true
        } else {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
        self.title = titleName
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        tableView.register(UINib(nibName: "FDIDCell", bundle: nil), forCellReuseIdentifier: "FDIDCell")
        
    }
    
    
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact: break
            case .regular: break
            }
        }
        
        self.tableView.reloadData()
    }
    
    func manageEntities() {
        switch type {
        case .platoon?:
            entity = "UserPlatoon"
            attribute = "platoon"
            sortAttribute = "platoon"
        case .rank?:
            entity = "UserRank"
            attribute = "rank"
            sortAttribute = "rank"
        case .assignment?:
            entity = "UserAssignments"
            attribute = "assignment"
            sortAttribute = "assignment"
        case .fdid?:
            entity = "UserFDID"
            attribute = "hqState"
            sortAttribute = "hqCity"
            tableView.register(UINib(nibName: "FDIDCell", bundle: nil), forCellReuseIdentifier: "FDIDCell")
        case .apparatus?:
            entity = "UserApparatusType"
            attribute = "apparatus"
            sortAttribute = "apparatus"
        default: break
        }
        _ = getTheData()
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        if Device.IS_IPHONE {
            switch compact {
            case .compact:
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            case .regular:
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkPROFILE_FROM_MASTER),
                                 object: nil,
                                 userInfo: ["sizeTrait":self.compact])
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkPROFILE_FROM_MASTER),
                             object: nil,
                             userInfo: ["sizeTrait":self.compact])
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        launchNC.removeNC()
    }
    
    func saveToUser(newEntry:String,fireDepartment:String) {
        let modDate = Date()
        switch type {
        case .fdid?:
            theUser.fdid = newEntry
            if theUser.fireDepartment == "" {
                theUser.fireDepartment = fireDepartment
            }
        default:break
        }
        theUser.fjpUserModDate = modDate
        theUser.fjpUserBackedUp = false
        saveToCD()
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Settings Profile Data TVC here"])
            }
            
            if Device.IS_IPHONE {
                switch compact {
                case .compact:
                    delegate?.settingsProfileDataCanceled()
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                case .regular:
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkPROFILE_FROM_MASTER),
                                     object: nil,
                                     userInfo: ["sizeTrait": self.compact])
                        self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let objectID = self.theUser.objectID
                    self.nc.post(name:Notification.Name(rawValue: FJkPROFILE_FROM_MASTER),
                                 object: nil,
                                 userInfo: ["sizeTrait":self.compact, "userObjID":  objectID])
                    self.dismiss(animated: true, completion: nil)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsProfileDataTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theFDIDs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .fdid?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FDIDCell", for: indexPath) as! FDIDCell
            configureFDIDCell(cell, at: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            configureCell(cell, at: indexPath)
            return cell
        }
    }
    
    func configureFDIDCell(_ cell: FDIDCell, at indexPath: IndexPath) {
        let fdid: UserFDID = theFDIDs[indexPath.row]
        if let number = fdid.fdidNumber {
            cell.fdid = number
        }
        if let dept = fdid.fireDepartmentName {
            cell.depart = dept
        }
        if let theCity = fdid.hqCity {
            cell.city = theCity
        }
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch type {
        case .platoon?:
            let platoon:UserPlatoon =  _fetchedResultsController?.object(at: indexPath) as! UserPlatoon
            cell.textLabel?.text = platoon.platoon
        case .rank?:
            let rank:UserRank =  _fetchedResultsController?.object(at: indexPath) as! UserRank
            cell.textLabel?.text = rank.rank
        case .assignment?:
            let assignment:UserAssignments =  _fetchedResultsController?.object(at: indexPath) as! UserAssignments
            cell.textLabel?.text = assignment.assignment
        case .apparatus?:
            let apparatus:UserApparatusType =  _fetchedResultsController?.object(at: indexPath) as! UserApparatusType
            cell.textLabel?.text = apparatus.apparatus
        default:break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var newEntry:String = ""
        var fireDepartment:String = ""
        switch type {
        case .platoon?:
            let cellChecked = tableView.cellForRow(at: indexPath)
            newEntry = cellChecked?.textLabel?.text ?? ""
        case .rank?:
            let cellChecked = tableView.cellForRow(at: indexPath)
            newEntry = cellChecked?.textLabel?.text ?? ""
        case .assignment?:
            let cellChecked = tableView.cellForRow(at: indexPath)
            newEntry = cellChecked?.textLabel?.text ?? ""
        case .fdid?:
            let cellChecked = tableView.cellForRow(at: indexPath)  as! FDIDCell
            newEntry = cellChecked.fdidL.text ?? ""
            fireDepartment = cellChecked.deptL.text ?? ""
        case .apparatus?:
            let cellChecked = tableView.cellForRow(at: indexPath)
            newEntry = cellChecked?.textLabel?.text ?? ""
        default: break
        }
        saveToUser(newEntry:newEntry, fireDepartment: fireDepartment)
    }
    
    private func getTheUser(entity: String, attribute: String, sortAttribute: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", attribute, "")
        let sectionSortDescriptor = NSSortDescriptor(key: sortAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if self.fetched.isEmpty {
                print("no user available")
            } else {
                self.fju = self.fetched.last as? FireJournalUser
            }
        } catch let error as NSError {
            print("SettingsProfileDataTVC line 382 Fetch Error: \(error.localizedDescription)")
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
        var predicate2 = NSPredicate.init()
        switch type {
        case .fdid?:
            sortAttribute = "hqCity"
            if (fju.fireStationState != nil) {
                predicate = NSPredicate(format: "%K = %@",self.attribute,fju.fireStationState!)
                if fju.fireStationCity != "" {
                    let letter = fju.fireStationCity
                    let letr = letter!.prefix(4)
                    predicate2 = NSPredicate(format: "%K BEGINSWITH[cd] %@","hqCity",letr as CVarArg)
                }
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
                fetchRequest.predicate = predicateCan
            } else {
                predicate = NSPredicate(format: "%K != %@",self.attribute,"")
                fetchRequest.predicate = predicate
            }
        default:
            predicate = NSPredicate(format: "%K != %@",self.attribute,"")
            fetchRequest.predicate = predicate
        }
        
        
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
            
            let errorMessage = "SettingsProfileDataTVC getTheData() Unresolved error \(nserror)"
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
