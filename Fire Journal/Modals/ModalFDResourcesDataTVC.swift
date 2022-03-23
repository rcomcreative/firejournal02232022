//
//  ModalFDResourcesDataTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/22/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol ModalFDResourcesDataDelegate: AnyObject {
    func theResourcesHaveBeenCollected(collectionOfResources: [UserResources])
    func theResourcesHasBeenCancelled()
}

class ModalFDResourcesDataTVC: UITableViewController, NSFetchedResultsControllerDelegate,CellHeaderW2ButtonsDelegate {
    
    //    MARK: -CellHeaderDelegate
    func theCancelModalDataW2ButtonsTapped() {
        delegate?.theResourcesHasBeenCancelled()
    }
    
    func theGroupW2ButtonsHasBeenChosen() {
        delegate?.theResourcesHaveBeenCollected(collectionOfResources: selectedResources)
    }
    
    let nc = NotificationCenter.default
    var titleName: String = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fetched = [UserFDResources]()
    var fetchedUserResources = [UserResources]()
    var userResourcesA = [UserResources]()
    var incidentFDResources = [UserFDResources]()
    var entity:String = "UserFDResources"
    var attribute:String = "fdResource"
    var sortAttribute:String = "fdResource"
    var settingType:FJSettings!
    var fdResources: UserFDResources!
    var fdResourcesA = [String]()
    var fdResourcesOrUserResource: Bool = true
    var subject:String = ""
    var descriptionText:String = ""
    var newEntry:String = ""
    
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    var selected: Array<String> = []
    var selectedResources = [UserResources]()
    var alertUp: Bool = false
    var theResources: Array<String>!
    var count: Int = 0
    weak var delegate: ModalFDResourcesDataDelegate! = nil
    
    var closed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        roundViews()
        getTheUserResources()
        getTheUserFDResources()
        
        var resourceString = [String]()
        for resource in incidentFDResources {
            resourceString.append(resource.fdResource!)
        }
        
        for s in resourceString {
            fetchedUserResources = fetchedUserResources.filter{ $0.resource != s }
        }
        
        tableView.allowsMultipleSelection = true
        
        tableView.register(UINib(nibName: "UserResourceCell", bundle: nil), forCellReuseIdentifier: "UserResourceCell")
        tableView.register(UINib(nibName: "SettingsCustomFDResourceCell", bundle: nil), forCellReuseIdentifier: "SettingsCustomFDResourceCell")
        tableView.register(UINib(nibName: "SettingsFDResourcesCell", bundle: nil), forCellReuseIdentifier: "SettingsFDResourcesCell")
    }
    
    
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeaderW2Buttons", owner: self, options: nil)?.first as! CellHeaderW2Buttons
        
        cellHeader.titleHeader.text = titleName
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
        return fetchedUserResources.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = fetchedUserResources[indexPath.row] as UserResources
        if resource.resourceCustom {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCustomFDResourceCell", for: indexPath) as! SettingsCustomFDResourceCell
            configureCustomCell(cell, at: indexPath,resource: resource)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsFDResourcesCell", for: indexPath) as! SettingsFDResourcesCell
            configureSettingsFDResourceCell(cell, at: indexPath,resource: resource)
            return cell
        }
    }
    
    func configureCustomCell(_ cell: SettingsCustomFDResourceCell, at indexPath: IndexPath, resource: UserResources) {
        cell.resource = resource
        let result = selectedResources.filter { $0.resource == resource.resource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func configureSettingsFDResourceCell(_ cell: SettingsFDResourcesCell, at indexPath: IndexPath, resource: UserResources) {
        cell.resource = resource
        let result = selectedResources.filter { $0.resource == resource.resource}
        if !result.isEmpty {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resource = fetchedUserResources[indexPath.row] as UserResources
        
        let result = selectedResources.filter { $0.resource == resource.resource}
        
        if result.isEmpty {
            selectedResources.append(resource)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let resource =  fetchedUserResources[indexPath.row] as UserResources
        if resource.resourceCustom {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsCustomFDResourceCell
            cell.isSelected = false
            let theResource = cell.resource?.resource ?? ""
            selectedResources = selectedResources.filter { $0.resource != theResource }
        } else {
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsFDResourcesCell
            cell.isSelected = false
            let theResource = cell.resource?.resource ?? ""
            selectedResources = selectedResources.filter { $0.resource != theResource }
        }
    }
    
    func closeItUp() {
        if collapsed {
//            delegate?.userFDResourcesBackToSettings()
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                    object: nil,
                    userInfo: ["sizeTrait":compact])
        }
    }
    
    fileprivate func saveToCD() {
        do {
            print(selected)
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"SettingsUsretFDResources merge that"])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "ModalFDResourcesDataTVC saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    private func getTheUserFDResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        do {
            incidentFDResources = try context.fetch(fetchRequest) as! [UserFDResources]
        }  catch {
            let nserror = error as NSError
            let errorMessage = "ModalFDResourcesDataTVCTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    private func getTheUserResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserResources")
        let sectionSortDescriptor = NSSortDescriptor(key: "resource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        do {
            fetchedUserResources = try context.fetch(fetchRequest) as! [UserResources]
        }  catch {
            let nserror = error as NSError
            let errorMessage = "ModalFDResourcesDataTVCTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
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
                    saveToCD()
                }
            }
        } catch let error as NSError {
            print("fJU error line 188 \(error.localizedDescription)")
        }
    }

}
