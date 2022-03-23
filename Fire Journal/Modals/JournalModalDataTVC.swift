//
//  JournalModalDataTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/15/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol JournalModalDataDelegate: AnyObject {
    func theJModalDataCancelTapped()
    func theJModalDataTapped(object:NSManagedObject)
}

class JournalModalDataTVC: UITableViewController {
    
    var headerTitle: String = ""
    var context:NSManagedObjectContext!
    var objectID:NSManagedObjectID!
    var journalData:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    weak var delegate:JournalModalDataDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        getDataSource()
        roundViews()
        self.title = headerTitle
        print("here is the headerTitle \(headerTitle)")
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    private func getDataSource() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",attribute,"")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
                   let sortDescriptors = [sectionSortDescriptor]
                   fetchRequest.sortDescriptors = sortDescriptors
        
        do {
        if entity == "UserAssignments" {
            journalData = try context.fetch(fetchRequest) as! [UserAssignments]
        } else if entity == "UserApparatusType" {
            journalData = try context.fetch(fetchRequest) as! [UserApparatusType]
        }
        } catch {
            print("JournalModalDataTVC line 66 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeader", owner: self, options: nil)?.first as! CellHeader
        cellHeader.titleHeader.text = headerTitle
        cellHeader.titleHeader.textColor = UIColor.white
        cellHeader.cancelButton.titleLabel?.textColor = UIColor.white
        let color = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1.0)
        cellHeader.backgroundV.backgroundColor = color
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if journalData.count == 0 {
            return 0
        } else {
            return journalData.count
        }
    }

//    ReuseIdentifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
            if entity == "UserAssignments" {
               let incidentType = journalData[indexPath.row] as! UserAssignments
               cell.textLabel?.text = incidentType.assignment
           } else if entity == "UserApparatusType" {
               let incidentType = journalData[indexPath.row] as! UserApparatusType
               cell.textLabel?.text = incidentType.apparatus
           }
           return cell
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
           if entity == "UserAssignments" {
                let assignment = journalData[indexPath.row] as! UserAssignments
                delegate?.theJModalDataTapped(object:assignment)
            } else if entity == "UserApparatusType" {
                let apparatus = journalData[indexPath.row] as! UserApparatusType
                delegate?.theJModalDataTapped(object:apparatus)
            }
        }

}

extension JournalModalDataTVC: CellHeaderDelegate {
    func theCancelModalDataTapped() {
        delegate?.theJModalDataCancelTapped()
    }
}
