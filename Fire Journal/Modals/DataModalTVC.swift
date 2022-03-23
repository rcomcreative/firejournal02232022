//
//  DataModalTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol DataModalTVCDelegate: AnyObject {
    func dataModalCancelCalled()
    func theDataModalChosen(objectID:NSManagedObjectID, user: UserInfo)
}

class DataModalTVC: UITableViewController,CellHeaderDelegate,NSFetchedResultsControllerDelegate {
    func theCancelModalDataTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var journalType: JournalTypes!
    var incidentType: IncidentTypes!
    var myShift: MenuItems!
    weak var delegate: DataModalTVCDelegate? = nil
    var headerTitle: String = ""
    var userInfo: UserInfo!
    var entity: String = ""
    var attribute: String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let nc = NotificationCenter.default
    var fetched:Array<Any>!

    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        tableView.register(UINib(nibName: "CrewCell", bundle: nil), forCellReuseIdentifier: "CrewCell")
        switch userInfo {
        case .platoon?:
            entity = "UserPlatoon"
            attribute = "platoon"
        case .apparatus?:
            entity = "UserApparatusType"
            attribute = "apparatus"
        case .assignment?:
            entity = "UserAssignments"
            attribute = "assignment"
        default:
            print("no")
        }
        getDataSource()
        roundViews()
        registerCells()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "DashboardDataLabelCell", bundle: nil), forCellReuseIdentifier: "DashboardDataLabelCell")
    }
    
    
    func getDataSource() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",attribute,"")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
         do {
            switch userInfo {
            case .platoon?:
                fetched = try context.fetch(fetchRequest) as! [UserPlatoon]
            case .assignment?:
                fetched = try context.fetch(fetchRequest) as! [UserAssignments]
            case .apparatus?:
                fetched = try context.fetch(fetchRequest) as! [UserApparatusType]
            default:
                print("no")
            }
         } catch let error as NSError {
            print("DataModalTVC line 84 Fetch Error: \(error.localizedDescription)")
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"DataModalTVC merge that"])
            }
        } catch let error as NSError {
            print("DataModalTVC line 100 Fetch Error: \(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeader", owner: self, options: nil)?.first as! CellHeader
        print("cell header \(headerTitle)")
        cellHeader.titleHeader.text = headerTitle
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardDataLabelCell", for: indexPath) as! DashboardDataLabelCell
        
        if entity == "UserPlatoon" {
            let incidentType = fetched[indexPath.row] as! UserPlatoon
            cell.dashData = incidentType.platoon
        } else if entity == "UserApparatusType" {
            let incidentType = fetched[indexPath.row] as! UserApparatusType
            cell.dashData = incidentType.apparatus
        } else if entity == "UserAssignments" {
            let incidentType = fetched[indexPath.row] as! UserAssignments
            cell.dashData = incidentType.assignment
        }
        return cell
    }
    
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if entity == "UserPlatoon" {
            let userPlatoon = fetched[indexPath.row] as! UserPlatoon
            let objectID = userPlatoon.objectID
            delegate?.theDataModalChosen(objectID:objectID, user: userInfo)
        } else if entity == "UserApparatusType" {
            let userApparatus = fetched[indexPath.row] as! UserApparatusType
            let objectID = userApparatus.objectID
            delegate?.theDataModalChosen(objectID:objectID, user: userInfo)
        } else if entity == "UserAssignments" {
            let userAssignments = fetched[indexPath.row] as! UserAssignments
            let objectID = userAssignments.objectID
            delegate?.theDataModalChosen(objectID:objectID, user: userInfo)
        }
        self.dismiss(animated:true,completion:nil)
    }

}
