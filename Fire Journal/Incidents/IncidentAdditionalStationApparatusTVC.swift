//
//  IncidentAdditionalStationApparatusTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/1/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol IncidentAdditionalStationApparatusTVCDelegate: AnyObject {
    func incidentAddtionalStationApparatusChosen(collectionOfResources: [UserFDResources])
    func incidentAdditionalStationApparatusCanceled()
}



class IncidentAdditionalStationApparatusTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    //    MARK: -PROPERTIES-
    let nc = NotificationCenter.default
    var titleName: String = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var selectedResources = [UserFDResources]()
    var fetched = [UserFDResources]()
    var fetchedUserResources = [UserResources]()
    var userResourcesA = [UserResources]()
    var incidentFDResources = [UserFDResources]()
    var fdResourcesA = [String]()
    var userFDResourcesCD = [UserFDResources]()
    var entity:String = "UserFDResources"
    var attribute:String = "fdResourceType"
    var sortAttribute:String = "fdResource"
    var fdResourceCount: Int = 0
    
    var fdResource: UserFDResources!
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    
    weak var delegate: IncidentAdditionalStationApparatusTVCDelegate? = nil
    
    
    //    MARK: -cellidentifier-AdditionalStationResourceIdentifier-
    override func viewDidLoad() {
        super.viewDidLoad()
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        roundViews()
        getTheUserFDResources()
        registerCells()
        tableView.allowsMultipleSelection = true
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "IncidentAdditionalResourcesCustomCell", bundle: nil), forCellReuseIdentifier: "IncidentAdditionalResourcesCustomCell")
        tableView.register(UINib(nibName: "IncidentAdditionalResoucesCell", bundle: nil), forCellReuseIdentifier: "IncidentAdditionalResoucesCell")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeaderW2Buttons", owner: self, options: nil)?.first as! CellHeaderW2Buttons
        
        cellHeader.titleHeader.text = "Additional Station Apparatus"
        cellHeader.titleHeader.textColor = UIColor.white
        cellHeader.cancelButton.titleLabel?.textColor = UIColor.white
        let color = ButtonsForFJ092018.fillColor38
        cellHeader.backgroundV.backgroundColor = color
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incidentFDResources.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = incidentFDResources[indexPath.row] as UserFDResources
        if resource.customResource {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentAdditionalResourcesCustomCell", for: indexPath) as! IncidentAdditionalResourcesCustomCell
            configureCustomCell(cell, at: indexPath,resource: resource)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentAdditionalResoucesCell", for: indexPath) as! IncidentAdditionalResoucesCell
            configureSettingsFDResourceCell(cell, at: indexPath,resource: resource)
            return cell
        }
    }
    
    func configureCustomCell(_ cell: IncidentAdditionalResourcesCustomCell, at indexPath: IndexPath, resource: UserFDResources) {
        cell.fdResource = resource
        let result = selectedResources.filter { $0.fdResource == resource.fdResource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func configureSettingsFDResourceCell(_ cell: IncidentAdditionalResoucesCell, at indexPath: IndexPath, resource: UserFDResources) {
        cell.fdResource = resource
        let result = selectedResources.filter { $0.fdResource == resource.fdResource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resource = incidentFDResources[indexPath.row] as UserFDResources
        
        let result = selectedResources.filter { $0.fdResource == resource.fdResource}
        
        if result.isEmpty {
            selectedResources.append(resource)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let resource =  incidentFDResources[indexPath.row] as UserFDResources
        if resource.customResource {
            let cell = tableView.cellForRow(at: indexPath)! as! IncidentAdditionalResourcesCustomCell
            cell.isSelected = false
            let theResource = cell.fdResource?.fdResource ?? ""
            selectedResources = selectedResources.filter { $0.fdResource != theResource }
        } else {
            let cell = tableView.cellForRow(at: indexPath)! as! IncidentAdditionalResoucesCell
            cell.isSelected = false
            let theResource = cell.fdResource?.fdResource ?? ""
            selectedResources = selectedResources.filter { $0.fdResource != theResource }
        }
    }
    
}

extension IncidentAdditionalStationApparatusTVC {
    //    MARK: -data-
    private func getTheUserFDResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
        var predicate = NSPredicate.init()
        let two: Int64 = 2;
        predicate = NSPredicate(format: "%K = %d", self.attribute , two)
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: self.sortAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 10
        do {
            incidentFDResources = try context.fetch(fetchRequest) as! [UserFDResources]
            
            if incidentFDResources.count == 0 {
                print("hey we have zero")
            } else {
                fdResourceCount = incidentFDResources.count
                fdResourceCount = fdResourceCount+1
                for resource in incidentFDResources {
                    if fdResource == nil {
                        fdResource = resource
                    }
                    userFDResourcesCD.append(resource)
                    fdResourcesA.append(resource.fdResource!)
                }
                
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
}

extension IncidentAdditionalStationApparatusTVC: CellHeaderW2ButtonsDelegate {
    func theCancelModalDataW2ButtonsTapped() {
        delegate?.incidentAdditionalStationApparatusCanceled()
    }
    
    func theGroupW2ButtonsHasBeenChosen() {
        delegate?.incidentAddtionalStationApparatusChosen(collectionOfResources: selectedResources)
    }
    
    
}
