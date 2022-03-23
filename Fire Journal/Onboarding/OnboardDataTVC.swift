//
//  OnboardDataTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol OnboardDataTVCDelegate: AnyObject {
    func theCellWasTapped(object:NSManagedObject,type:IncidentTypes)
    func theDataModalWasCanceled()
}

class OnboardDataTVC: UITableViewController, NSFetchedResultsControllerDelegate,CellHeaderDelegate,CellHeaderFDIDDelegate {
    
    
    var incidentType: IncidentTypes!
    weak var delegate:OnboardDataTVCDelegate? = nil
    var headerTitle: String = ""
    var context:NSManagedObjectContext!
    var objectID:NSManagedObjectID!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var theState:String = ""
    var theCity: String = ""
    
    func theCancelModalDataTapped() {
        delegate?.theDataModalWasCanceled()
    }
    
    
    //    MARK: -CellHeaderFDIDDelegate
    func theFDIDCancelBTapped() {
        delegate?.theDataModalWasCanceled()
    }
    
    
    
    var fjuState:String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getTheData()
        tableView.register(UINib(nibName: "FDIDCell", bundle: nil), forCellReuseIdentifier: "FDIDCell")
    }
    
    //    MARK: - GIT THE DATASOURCE
    private func getTheData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        var predicate2 = NSPredicate.init()
        if entity == "UserFDID" {
            if theState != "" {
                predicate = NSPredicate(format: "%K = %@", attribute, theState)
                if theCity != "" {
                    let letter = theCity
                    let letr = letter.prefix(4)
                    predicate2 = NSPredicate(format: "%K BEGINSWITH[cd] %@","hqCity",letr as CVarArg)
                    let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
                    fetchRequest.predicate = predicateCan
                }
            } else {
                predicate = NSPredicate(format: "%K != %@",attribute,"")
                fetchRequest.predicate = predicate
            }
        } else {
            predicate = NSPredicate(format: "%K != %@",attribute,"")
            fetchRequest.predicate = predicate
        }
        fetchRequest.fetchBatchSize = 20
        if entity != "UserFDID" {
            let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        } else {
            let sectionSortDescriptor = NSSortDescriptor(key: "hqCity", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        do {
            if entity == "UserPlatoon" {
                fetched = try context.fetch(fetchRequest) as! [UserPlatoon]
            } else if entity == "UserRank" {
                fetched = try context.fetch(fetchRequest) as! [UserRank]
            } else if entity == "UserAssignments" {
                fetched = try context.fetch(fetchRequest) as! [UserAssignments]
            } else if entity == "UserApparatusType" {
                fetched = try context.fetch(fetchRequest) as! [UserApparatusType]
            } else if entity == "UserFDID" {
                fetched = try context.fetch(fetchRequest) as! [UserFDID]
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "OnboardDataTVC getTheData() \(fetchRequest) Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if entity == "UserFDID" {
            let cellHeader = Bundle.main.loadNibNamed("CellHeaderFDID", owner: self, options: nil)?.first as! CellHeaderFDID
            if theState != "" {
                headerTitle = theState+" "+headerTitle
            }
            cellHeader.delegate = self
            cellHeader.headerTitle.text = headerTitle
            return cellHeader
        } else {
            let cellHeader = Bundle.main.loadNibNamed("CellHeader", owner: self, options: nil)?.first as! CellHeader
            cellHeader.backgroundColor = UIColor.gray
            cellHeader.titleHeader.text = headerTitle
            cellHeader.delegate = self
            return cellHeader
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if entity == "UserFDID" {
            return 88
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetched.count == 0 || fetched == nil {
            return 0
        } else {
            return fetched.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if entity == "UserFDID" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FDIDCell", for: indexPath) as! FDIDCell
            let incidentType = fetched[indexPath.row] as! UserFDID
            cell.fdidL.text = incidentType.fdidNumber
            cell.deptL.text = incidentType.fireDepartmentName
            cell.cityL.text = incidentType.hqCity
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if entity == "UserPlatoon" {
                let incidentType = fetched[indexPath.row] as! UserPlatoon
                cell.textLabel?.text = incidentType.platoon
            } else if entity == "UserRank" {
                let incidentType = fetched[indexPath.row] as! UserRank
                cell.textLabel?.text = incidentType.rank
            } else if entity == "UserAssignments" {
                let incidentType = fetched[indexPath.row] as! UserAssignments
                cell.textLabel?.text = incidentType.assignment
            } else if entity == "UserApparatusType" {
                let incidentType = fetched[indexPath.row] as! UserApparatusType
                cell.textLabel?.text = incidentType.apparatus
        }
//            
            return cell
        }
    }
    
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if entity == "UserPlatoon" {
            let platoonType = fetched[indexPath.row] as! UserPlatoon
            delegate?.theCellWasTapped(object: platoonType, type: incidentType)
        } else if entity == "UserRank" {
            let rankType = fetched[indexPath.row] as! UserRank
            delegate?.theCellWasTapped(object: rankType, type: incidentType)
        } else if entity == "UserAssignments" {
            let assignmentType = fetched[indexPath.row] as! UserAssignments
            delegate?.theCellWasTapped(object: assignmentType, type: incidentType)
        } else if entity == "UserApparatusType" {
            let apparatusType = fetched[indexPath.row] as! UserApparatusType
            delegate?.theCellWasTapped(object: apparatusType, type: incidentType)
        } else if entity == "UserFDID" {
            let fdidType = fetched[indexPath.row] as! UserFDID
            delegate?.theCellWasTapped(object: fdidType, type: incidentType)
        }
    }

}
