//
//  ModalResourcesTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/23/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ResourcesItem {
    var resourceGroupName: String
    var resources: Array<String>
    var fetched:Array<Any>!
    var overtimeB: Bool = true
    var resourceGroupGuid: String
    var isSelected: Bool = false
    var resourceString: String = ""
    var resourceDate: Date = Date()
    var entryState: EntryState = .new
    var objectID: NSManagedObjectID! = nil
    var overtimeS: String = "Front Line"
    
    init(group: String, resource: Array<String>, groupGuid: String) {
        self.resourceGroupName = group
        self.resources = resource
        self.resourceGroupGuid = groupGuid
    }
    
    func joinResources()->String {
        let group:String = resources.joined(separator: ", ")
        return group
    }
    
    func createGuid() {
        self.resourceDate = Date()
        let groupDate = GuidFormatter.init(date:resourceDate)
        let grGuid:String = groupDate.formatGuid()
        self.resourceGroupGuid = "78."+grGuid
    }
    
    func overtimeSwitch(yesno: Bool) {
        self.overtimeB = yesno
        if yesno {
            self.overtimeS = "Front Line"
        } else {
            self.overtimeS = "Reserve"
        }
    }
}



protocol ModalResourcesTVCDelegate: AnyObject {
    func theModalResourceCancelHasBeenTapped()
    func theResourcesChoiceHasBeenMade(resourceGroup: ResourcesItem, objectID: NSManagedObjectID )
}

class ModalResourcesTVC: UITableViewController, ModalResourceDataDelegate, UITextFieldDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    @IBOutlet weak var subject1L: UILabel!
    @IBOutlet weak var subject2L: UILabel!
    @IBOutlet weak var subject1TF: UITextField!
    @IBOutlet weak var subject2TF: UITextField!
    @IBOutlet weak var switchL: UILabel!
    @IBOutlet weak var overtimeSwitch: UISwitch!
    @IBOutlet weak var subject4L: UILabel!
    @IBOutlet weak var subject4B: UIButton!
    @IBOutlet weak var subject3L: UILabel!
    @IBOutlet weak var subject3B: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    
    var frontOrOverB: Bool = true
    
    weak var delegate: ModalResourcesTVCDelegate? = nil
    var headerTitle:String = ""
    var myShift: MenuItems!
    var incidentType: IncidentTypes!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entity: String = "UserResources"
    var attribute: String = "resource"
    var resources: Array<NSManagedObject> = []
    var selected: Array<String> = []
    var fetched:Array<Any>!
    var group: ResourcesItem!
    let segue: String = "ResourceGroupToDataSegue"
    
    let nc = NotificationCenter.default
    var userResourcesGroup: UserResourcesGroups!
    var fju:FireJournalUser!
    
    
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.theModalResourceCancelHasBeenTapped()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveBTapped(_ sender: Any) {
        if group.resourceGroupName == "" {
            let name = subject1TF.text ?? ""
            let groupR = subject2TF.text ?? ""
            if name == "" {
                let alertMessage:String = "To save a resource group you need to give the group a name."
                let title:String = "Resource Group"
                let alert = UIAlertController.init(title: title, message: alertMessage, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "I Agree", style: .default, handler: {_ in
                   
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                group.resourceGroupName = name
                group.resourceString = groupR
                group.createGuid()
                if group.objectID == nil {
                    saveTheData()
                } else {
                    updateTheData()
                }
            }
        } else {
            let name = subject1TF.text ?? ""
            let groupR = subject2TF.text ?? ""
            if group.objectID == nil {
            group.resourceGroupName = name
            group.resourceString = groupR
            group.createGuid()
                saveTheData()
            } else {
                updateTheData()
            }
        }
    }
    
    func updateTheData() {
        userResourcesGroup.resourcesGroupModDate = Date()
        if let name = subject1TF.text {
            userResourcesGroup.resourcesGroupName = name
            group.resourceGroupName = name
        }
        if let groupR = subject2TF.text {
            userResourcesGroup.resourcesGroup = groupR
            group.resourceString = groupR
            group.resources = groupR.components(separatedBy: ", ")
        }
        userResourcesGroup.entryState = EntryState.update.rawValue
        userResourcesGroup.resourcesGroupBackedUp = false
        userResourcesGroup.resourcesGroupDefault = group.overtimeB
        let defaultOrNot = group.overtimeB
        if defaultOrNot {
            fju.resourcesDefault = defaultOrNot
            fju.defaultResources = group.joinResources()
            fju.defaultResourcesName = group.resourceGroupName
            fju.resourcesGuid = group.resourceGroupGuid
        } else {
            fju.resourcesDefault = defaultOrNot
            fju.tempResources = group.joinResources()
            fju.resourcesOvertimeName = group.resourceGroupName
            fju.resourcesOvertimeGuid = group.resourceGroupGuid
        }
        saveToCD()
        let isSaved: Bool = userResourcesGroup.objectID.isTemporaryID
        if isSaved {
            
        } else {
            delegate?.theResourcesChoiceHasBeenMade(resourceGroup: group, objectID: userResourcesGroup.objectID)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveTheData() {
        let fjUserResourcesGroup = UserResourcesGroups.init(entity: NSEntityDescription.entity(forEntityName: "UserResourcesGroups", in: context)!, insertInto: context)
        fjUserResourcesGroup.resourcesGroupGuid = group.resourceGroupGuid
        fjUserResourcesGroup.resourcesGroupModDate = group.resourceDate
        fjUserResourcesGroup.entryState = group.entryState.rawValue
        fjUserResourcesGroup.resourcesGroupName = group.resourceGroupName
        fjUserResourcesGroup.resourcesGroup = group.joinResources()
        fjUserResourcesGroup.resourcesGroupDateCreated = group.resourceDate
        fjUserResourcesGroup.resourcesGroupBackedUp = false
        fjUserResourcesGroup.resourcesGroupDefault = group.overtimeB
        let defaultOrNot = group.overtimeB
        if defaultOrNot {
            fju.resourcesDefault = defaultOrNot
            fju.defaultResources = group.joinResources()
            fju.defaultResourcesName = group.resourceGroupName
            fju.resourcesGuid = group.resourceGroupGuid
        } else {
            fju.resourcesDefault = defaultOrNot
            fju.tempResources = group.joinResources()
            fju.resourcesOvertimeName = group.resourceGroupName
            fju.resourcesOvertimeGuid = group.resourceGroupGuid
        }
        saveToCD()
        let isSaved: Bool = fjUserResourcesGroup.objectID.isTemporaryID
        if isSaved {
            
        } else {
            delegate?.theResourcesChoiceHasBeenMade(resourceGroup: group, objectID: fjUserResourcesGroup.objectID)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Modfal Resources TVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": self.fju.objectID])
            }
        } catch let error as NSError {
            print("ModalResourcesTVC line 218 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<UserResourcesGroups> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<UserResourcesGroups>? = nil
    
    private func getTheResourcesGroupData() -> NSFetchedResultsController<UserResourcesGroups> {
        
        let fetchRequest: NSFetchRequest<UserResourcesGroups> = UserResourcesGroups.fetchRequest()
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","resourcesGroup","")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "resourcesGroup", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("ModalResourcesTVC line 252 Fetch Error: \(error.localizedDescription)")
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
    
    func theResourceCancelWasTapped() {
    }
    func theResourceGroupHasGathered(selected: Array<String>) {
        print(selected)
        group.resources = selected
        group.resourceString = group.joinResources()
        subject2TF.text = group.resourceString
    }
    
    @IBAction func overtimeSwitchTapped(_ sender: Any) {
        if overtimeSwitch.isOn {
            group.overtimeSwitch(yesno: true)
            switchL.text = group.overtimeS
        } else {
            group.overtimeSwitch(yesno: false)
            switchL.text = group.overtimeS
        }
        
    }
    @IBAction func subject4BTapped(_ sender: Any) {
        let selectTeam: String = subject2TF.text ?? ""
        selected = selectTeam.components(separatedBy: ", ")
        performSegue(withIdentifier: segue, sender: self)
    }
    @IBAction func subject3BTapped(_ sender: Any) {
        performSegue(withIdentifier: segue, sender: self)
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResourceGroupCell", bundle: nil), forCellReuseIdentifier: "ResourceGroupCell")
        resources = getTheData()
        getTheUserData()
        group = ResourcesItem.init(group: "", resource: [], groupGuid: "")
        
         nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        overtimeSwitch.setOn(true, animated: true)
        group.overtimeB = true
        switchL.text = "Front Line"
        _ = getTheResourcesGroupData()
        roundViews()
        tableView.allowsMultipleSelection = false
    }
    
    override func viewDidLayoutSubviews() {
        subject3B.setBackgroundImage(ButtonsForFJ092018.imageOfResourceGroupNew, for: .normal)
        subject3B.layer.cornerRadius = 6
        subject3B.layer.masksToBounds = true
        subject4B.setBackgroundImage(ButtonsForFJ092018.imageOfSmallBluePlusButt, for: .normal)
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        group.resourceGroupName = text
        subject1TF.text = text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        group.resourceGroupName = text
        subject1TF.text = text
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func getTheData()->Array<NSManagedObject> {
        var fetch = [UserResources]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",attribute,"")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: attribute , ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
         do {
            fetch = try context.fetch(fetchRequest) as! [UserResources]
            return fetch
         } catch let error as NSError {
            print("ModalResourcesTVC line 381 Fetch Error: \(error.localizedDescription)")
        }
        return fetch
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return _fetchedResultsController?.sections?.count ?? 0
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceGroupCell", for: indexPath) as! ResourceGroupCell
//        cell.resource = fetched[indexPath.row] as? UserResourcesGroups
        cell.resource = _fetchedResultsController?.object(at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ResourceGroupCell
        cell.isSelected = true
//        userResourcesGroup = fetched[indexPath.row] as! UserResourcesGroups
        userResourcesGroup = _fetchedResultsController?.object(at: indexPath)
        group.objectID = userResourcesGroup.objectID
        group.resourceGroupName = userResourcesGroup.resourcesGroupName ?? ""
        group.resourceGroupGuid = userResourcesGroup.resourcesGroupGuid ?? ""
        group.resourceString = userResourcesGroup.resourcesGroup ?? ""
        group.overtimeB = userResourcesGroup.resourcesGroupDefault
        group.entryState = .update
        selected = group.resourceString.components(separatedBy: ", ")
        subject1TF.text = group.resourceGroupName
        subject2TF.text = group.resourceString
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ResourceGroupCell
        cell.isSelected = false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            userResourcesGroup = _fetchedResultsController?.object(at: indexPath)
            context.delete(userResourcesGroup)
            saveToCD()
            userResourcesGroup = nil
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResourceGroupToDataSegue" {
            let detailTVC:ModalResourceDataTVC = segue.destination as! ModalResourceDataTVC
            let resources = getTheData()
            detailTVC.delegate = self
            detailTVC.context = context
            detailTVC.fetched = resources
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
            print("ModalResourcesTVC line 475 Fetch Error: \(error.localizedDescription)")
        }
    }
    

}
