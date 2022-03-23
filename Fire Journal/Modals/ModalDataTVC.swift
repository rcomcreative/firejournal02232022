//
//  ModalDataTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/17/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol ModalDataTVCDelegate: AnyObject {
    func theModalDataCancelTapped()
    func theModalDataTapped(object:NSManagedObjectID,type:IncidentTypes, index: IndexPath)
    func theModalDataWithTapped(type: IncidentTypes)
}

class ModalDataTVC: UITableViewController, NSFetchedResultsControllerDelegate,CellHeaderDelegate {
    
    func theCancelModalDataTapped() {
        delegate?.theModalDataCancelTapped()
    }
    
    var journalType: JournalTypes!
    var incidentType: IncidentTypes!
    var myShift: MenuItems = .journal
    weak var delegate: ModalDataTVCDelegate? = nil
    var headerTitle: String = ""
    var context:NSManagedObjectContext!
    var objectID:NSManagedObjectID!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var index: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        getDataSource()
        registerCells()
        roundViews()
        self.title = headerTitle
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "LabelCell",bundle: nil), forCellReuseIdentifier: "LabelCell")
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func getDataSource() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",attribute,"")
        fetchRequest.predicate = predicate
        if entity == "UserLocalIncidentType" {
            let sectionSortDescriptor = NSSortDescriptor(key: "localIncidentTypeName", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        } else {
            let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        do {
            if entity == "UserLocalIncidentType" {
                fetched = try context.fetch(fetchRequest) as! [UserLocalIncidentType]
            } else if entity == "NFIRSIncidentType" {
                fetched = try context.fetch(fetchRequest) as! [NFIRSIncidentType]
            } else if entity == "NFIRSLocation" {
                fetched = try context.fetch(fetchRequest) as! [NFIRSLocation]
            } else if entity == "NFIRSStreetType" {
                fetched = try context.fetch(fetchRequest) as! [NFIRSStreetType]
            } else if entity == "NFIRSStreetPrefix" {
                fetched = try context.fetch(fetchRequest) as! [NFIRSStreetPrefix]
            } else if entity == "UserPlatoon" {
                fetched = try context.fetch(fetchRequest) as! [UserPlatoon]
            } else if entity == "UserAssignments" {
                fetched = try context.fetch(fetchRequest) as! [UserAssignments]
            } else if entity == "UserApparatusType" {
                fetched = try context.fetch(fetchRequest) as! [UserApparatusType]
            } else if entity == "UserResources" {
                fetched = try context.fetch(fetchRequest) as! [UserResources]
            } else if entity == "NFIRSActionsTaken" {
                fetched = try context.fetch(fetchRequest) as! [NFIRSActionsTaken]
            } else if entity == "UserRank" {
                fetched = try context.fetch(fetchRequest) as! [UserRank]
            } else if entity == "UserAssignments" {
                fetched = try context.fetch(fetchRequest) as! [UserAssignments]
            }
        } catch let error as NSError {
            print("ModalDataTVC line 86 Fetch Error: \(error.localizedDescription)")
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
        switch myShift {
        case .journal, .personal:
            cellHeader.titleHeader.text = headerTitle
            cellHeader.titleHeader.textColor = UIColor.white
            cellHeader.cancelButton.titleLabel?.textColor = UIColor.white
            let color = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1.0)
            cellHeader.backgroundV.backgroundColor = color
        case .incidents:
            cellHeader.titleHeader.text = headerTitle
            cellHeader.titleHeader.textColor = UIColor.white
            cellHeader.cancelButton.titleLabel?.textColor = UIColor.white
            let color = ButtonsForFJ092018.fillColor38
            cellHeader.backgroundV.backgroundColor = color
        default: break
        }
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetched.count == 0 {
            return 0
        } else {
            return fetched.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell

        cell.infoB.isHidden = true
        cell.infoB.isEnabled = false
        cell.infoB.alpha = 0.0


        if entity == "UserLocalIncidentType" {
            let incidentType = fetched[indexPath.row] as! UserLocalIncidentType
            cell.modalTitleL.text = incidentType.localIncidentTypeName
        } else if entity == "NFIRSIncidentType" {
            cell.modalTitleL.font = cell.modalTitleL.font.withSize(15)
            cell.modalTitleL.adjustsFontSizeToFitWidth = true
            cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.modalTitleL.numberOfLines = 0
            cell.modalTitleL.setNeedsDisplay()
            let incidentType = fetched[indexPath.row] as! NFIRSIncidentType
            let number:String = incidentType.incidentTypeNumber ?? ""
            let type:String = incidentType.incidentTypeName ?? ""
            cell.modalTitleL.text = number+" "+type
        } else if entity == "NFIRSLocation" {
            let incidentType = fetched[indexPath.row] as! NFIRSLocation
            cell.modalTitleL.text = incidentType.location
        } else if entity == "NFIRSStreetType" {
            let incidentType = fetched[indexPath.row] as! NFIRSStreetType
            cell.modalTitleL.text = incidentType.streetType
        } else if entity == "NFIRSStreetPrefix" {
            let incidentType = fetched[indexPath.row] as! NFIRSStreetPrefix
            cell.modalTitleL.text = incidentType.streetPrefix
        } else if entity == "UserPlatoon" {
            let incidentType = fetched[indexPath.row] as! UserPlatoon
            cell.modalTitleL.text = incidentType.platoon
        } else if entity == "UserAssignments" {
            let incidentType = fetched[indexPath.row] as! UserAssignments
            cell.modalTitleL.text = incidentType.assignment
        } else if entity == "UserApparatusType" {
            let incidentType = fetched[indexPath.row] as! UserApparatusType
            cell.modalTitleL.text = incidentType.apparatus
        } else if entity == "UserResources" {
            let incidentType = fetched[indexPath.row] as! UserResources
            cell.modalTitleL.text = incidentType.resource
        } else if entity == "NFIRSActionsTaken" {
            let incidentType = fetched[indexPath.row] as! NFIRSActionsTaken
            cell.modalTitleL.font = cell.modalTitleL.font.withSize(15)
            cell.modalTitleL.adjustsFontSizeToFitWidth = true
            cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.modalTitleL.numberOfLines = 0
            cell.modalTitleL.setNeedsDisplay()
            let numberAndText = incidentType.actionTaken
            cell.modalTitleL.text = numberAndText
        } else if entity == "UserAssignments" {
            let incidentType = fetched[indexPath.row] as! UserAssignments
            cell.modalTitleL.text = incidentType.assignment
        } else if entity == "UserRank" {
            let incidentType = fetched[indexPath.row] as! UserRank
            cell.modalTitleL.text = incidentType.rank
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if entity == "NFIRSIncidentType" {
            let nfirsIncidentType = fetched[indexPath.row] as! NFIRSIncidentType
            delegate?.theModalDataTapped(object:nfirsIncidentType.objectID,type:incidentType, index: index)
        } else if entity == "UserLocalIncidentType" {
            let localIncidentType = fetched[indexPath.row] as! UserLocalIncidentType
            delegate?.theModalDataTapped(object:localIncidentType.objectID, type: incidentType, index: index)
        } else if entity == "NFIRSLocation" {
            let location = fetched[indexPath.row] as! NFIRSLocation
            delegate?.theModalDataTapped(object: location.objectID, type: incidentType, index: index)
        } else if entity == "NFIRSStreetType" {
            let street = fetched[indexPath.row] as! NFIRSStreetType
            delegate?.theModalDataTapped(object:street.objectID, type:incidentType, index: index)
        } else if entity == "NFIRSStreetPrefix" {
            let prefix = fetched[indexPath.row] as! NFIRSStreetPrefix
            delegate?.theModalDataTapped(object:prefix.objectID, type: incidentType, index: index)
        } else if entity == "UserPlatoon" {
            let platoon = fetched[indexPath.row] as! UserPlatoon
            delegate?.theModalDataTapped(object:platoon.objectID, type: incidentType, index: index)
        } else if entity == "UserAssignments" {
            let assignment = fetched[indexPath.row] as! UserAssignments
            delegate?.theModalDataTapped(object:assignment.objectID, type: incidentType, index: index)
        } else if entity == "UserApparatusType" {
            let apparatus = fetched[indexPath.row] as! UserApparatusType
            delegate?.theModalDataTapped(object:apparatus.objectID, type: incidentType, index: index)
        } else if entity == "NFIRSActionsTaken" {
            let action = fetched[indexPath.row] as! NFIRSActionsTaken
            delegate?.theModalDataTapped(object: action.objectID, type: incidentType, index: index)
        } else if entity == "UserRank" {
            let rank = fetched[indexPath.row] as! UserRank
            delegate?.theModalDataTapped(object:rank.objectID, type: incidentType, index: index)
        }
    }
    
}
