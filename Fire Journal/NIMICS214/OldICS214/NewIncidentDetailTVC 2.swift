//
//  NewIncidentDetailTVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 11/1/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol NewIncidentDetailDelegate: AnyObject {
    func selectedTextToReturnWithType(entity:String,selected:String)
}

class NewIncidentDetailTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var entity:String = ""
    var attribute:String = ""
    var fetched:Array<Any>!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate: NewIncidentDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewIncident(_:)))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewIncident(_:)))
        //        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancel
        
        let backgroundImage = UIImage(named: "headerBar2")
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@",attribute,"")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: attribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
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
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "NewIncidentDetailTVC viewDidLoad() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
           print(errorMessage)
            
        }
        
    }
    
    func addNewIncident(_ sender:Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelNewIncident(_ sender:Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetched.count == 0 {
            return 0
        } else {
            return fetched.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if entity == "UserLocalIncidentType" {
            let incidentType = fetched[indexPath.row] as! UserLocalIncidentType
            cell.textLabel?.text = incidentType.localIncidentTypeName
        } else if entity == "NFIRSIncidentType" {
            let incidentType = fetched[indexPath.row] as! NFIRSIncidentType
            cell.textLabel?.text = incidentType.incidentTypeName
        } else if entity == "NFIRSLocation" {
            let incidentType = fetched[indexPath.row] as! NFIRSLocation
            cell.textLabel?.text = incidentType.location
        } else if entity == "NFIRSStreetType" {
            let incidentType = fetched[indexPath.row] as! NFIRSStreetType
            cell.textLabel?.text = incidentType.streetType
        } else if entity == "NFIRSStreetPrefix" {
            let incidentType = fetched[indexPath.row] as! NFIRSStreetPrefix
            cell.textLabel?.text = incidentType.streetPrefix
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let selected:String = (cell.textLabel?.text)!
        delegate?.selectedTextToReturnWithType(entity: entity, selected: selected)
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
}
