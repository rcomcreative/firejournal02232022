//
//  ModalResourceDataTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/23/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol ModalResourceDataDelegate: AnyObject {
    func theResourceCancelWasTapped()
    func theResourceGroupHasGathered(selected: Array<String>)
}

class Resources {
    private var resource: UserResources
    
    var isSelected: Bool = false
    
    var title: String {
        return resource.resource ?? ""
    }
    
    init(resource:UserResources) {
        self.resource = resource
    }
}

class AllResources:NSObject {
    var resources = [Resources]()
    
    var didToggleSelection: ((_ hasSelection: Bool) -> ())? {
        didSet {
            didToggleSelection?(!selectedItems.isEmpty)
        }
    }
    
    var selectedItems: [Resources] {
        return resources.filter { return $0.isSelected }
    }
    
    init(fetched:Array<NSManagedObject>) {
        super.init()
        resources = fetched.map { Resources(resource: $0 as! UserResources) }
    }
}

class ModalResourceDataTVC: UITableViewController,CellHeaderCancelSaveDelegate  {
    //    MARK: -CellHeaderCancelSaveDelegate
    func cellCancelled() {
        self.dismiss(animated: true, completion: nil)
        delegate?.theResourceCancelWasTapped()
    }
    
    func cellSaved() {
        self.dismiss(animated: true, completion: nil)
        delegate?.theResourceGroupHasGathered(selected: selected)
    }
    
    
    func theCancelModalDataTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    var context:NSManagedObjectContext!
    var objectID:NSManagedObjectID!
    var fetched:Array<NSManagedObject> = []
    var selected: [String] = []
    var entity:String = ""
    var attribute:String = ""
    weak var delegate: ModalResourceDataDelegate? = nil
    var headerTitle: String = "Choose Your Resources"
    var resource: AllResources!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResourceCell", bundle: nil), forCellReuseIdentifier: "ResourceCell")
        tableView.allowsMultipleSelection = true
        resource = AllResources.init(fetched: fetched)
        roundViews()
    }
    
    
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeaderCancelSave", owner: self, options: nil)?.first as! CellHeaderCancelSave
        print("cell header \(headerTitle)")
        cellHeader.headerTitleL.text = headerTitle
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetched.count == 0 {
            return 0
        } else {
            return fetched.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath) as! ResourceCell
        cell.resource = fetched[indexPath.row] as? UserResources
        
        //        MARK: if multiple selects already exist check against resource and mark as checked
        let resource = cell.resource?.resource ?? ""
        if selected.contains(resource) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)! as! ResourceCell
        cell.isSelected = true
        let resource = cell.resource?.resource ?? ""
        if !selected.contains(resource) { selected.append(resource) }
        print("here is selected added to \(selected)")
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)! as! ResourceCell
        cell.isSelected = false
        let resource = cell.resource?.resource ?? ""
        selected = selected.filter { $0 != resource }
        print("here is selected removed \(selected)")
    }

}
