//
//  TeamTVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/8/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

protocol TeamTVCDelegate: AnyObject {
    func namesChosen(resource: [ICS214Resources])
    func namesArraySent(names: [UserAttendees])
    func cancelButtonTapped()
}


@available(iOS 11.0, *)
class TeamTVC: UITableViewController, CNContactPickerDelegate, CNContactViewControllerDelegate {
    var modalCells:Array = [CellParts]()
    var field1Chosen: String!
    var field2Chosen: String!
    var field3Chosen: String!
    var objectID: NSManagedObjectID! = nil
    var contactStore = CNContactStore()
    var buttonAdded: Bool!
    
    var resources = [Resource]()
    var resource = [ResourceAttendee]()
    var teamMembers = [ResourceAttendee]()
    var ics214resources = [ICS214Resources]()
    var ics214Team = [ICS214Resources]()
    var teams:Array<NSManagedObject>!
    var members:Array<UserAttendees>!
    var members2:Array<UserAttendees>!
    var chosenMembers = [UserAttendees]()
    var chosenPath:Array<IndexPath>!
    
    weak var delegateTeam: TeamTVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var nims: ICS214Form!
    var userAttendee: UserAttendees!
    var nimsPersonnel: ICS214Personnel!
    var tableIndexPath = IndexPath(item: 0, section: 0)
    
    //    MARK: -theCells-
    let cellsFromData = TeamCellAttributes()
    var theCells = [CellStorage]()
    let nc = NotificationCenter.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resources = []
        buttonAdded = false
        resource = []
        teamMembers = []
        ics214resources = []
        ics214Team = []
        members = []
        members2 = []
        chosenPath = []
        theCells = cellsFromData.teamCells
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addNewContact(_:)))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewContact(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancel
        
        let backgroundImage = UIImage(named: "headerBar2")
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        self.title = "Resources Assigned"
        nims = ICS214Form.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Form", in: context)!, insertInto: context)
        
        registerCells()
        
        fetchUsersForTable()
        
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToContactsListSegue" {
            let modalTVC = segue.destination as! ContactsTVC
            modalTVC.delegate = self
        }
    }
    
    func loadContacts() {
        let segue = "ToContactsListSegue"
        performSegue(withIdentifier: segue, sender: self)
    }
    
    @objc func cancelNewContact(_ sender:Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func compareAttendeeForAdd(team: [UserAttendees]) {
        delegateTeam?.namesArraySent(names: team)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addNewContact(_ sender:Any) {
        compareAttendeeForAdd(team: chosenMembers)
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
        return theCells.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named:"header")!)
        }
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let theCell = theCells[indexPath.row]
        let cellT = theCell.type
        
        switch cellT {
        case .modalHeader:
            return 100
        case .contactsCell:
            return 105
        case .completedThreeFieldCell:
            return 44
        case .addButtonCell:
            return 44
        case .teamCell:
            return 44
        case .noSelectCell:
            return 44
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theCell = theCells[indexPath.row]
        let cellT = theCell.type
        let header:String = theCell.header
        let field1:String = theCell.field1
        let field2:String = theCell.field2
        let field3:String = theCell.field3
        let field4:String = theCell.field4
        let field5:String = theCell.cellValue1
        let field6:String = theCell.cellValue2
        
        
        switch cellT {
        case .modalHeader:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModalHeaderCell", for: indexPath) as! ModalHeaderCell
            return cell
        case .contactsCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
            cell.delegate = self
            cell.resourceL.text = header
            cell.fieldOneL.text = field1
            cell.fieldTwoL.text = field2
            cell.fieldThreeL.text = field3
            cell.inputOneTF.text = ""
            cell.inputTwoTF.text = ""
            cell.inputThreeTF.text = ""
            tableIndexPath = indexPath
            return cell
        case .completedThreeFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedThreeFieldExpandedCell", for: indexPath) as! CompletedThreeFieldExpandedCell
            cell.delegate = self
            cell.indexPath.row = indexPath.row
            let selected = ResourceAttendee.init(name: field1, email: field4, phone: field5, icsPosition: field2, homeAgency: field3, guid: field6)
            cell.configureWithResource(selected!)
            resource.append(selected!)
            return cell
        case .teamCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedThreeFieldExpandedCell", for: indexPath) as! CompletedThreeFieldExpandedCell
            let selected = ResourceAttendee.init(name: field1, email: field4, phone: field5, icsPosition: field2, homeAgency: field3, guid: field6)
            cell.configureWithResource(selected!)
            cell.indexPath.row = indexPath.row
            resource.append(selected!)
            return cell
        case .noSelectCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedThreeFieldExpandedCell", for: indexPath) as! CompletedThreeFieldExpandedCell
            cell.delegate = self
            cell.indexPath.row = indexPath.row
            let selected = ResourceAttendee.init(name: field1, email: field4, phone: field5, icsPosition: field2, homeAgency: field3, guid: field6)
            cell.configureWithResource(selected!)
            cell.chosenIV.isHidden = true
            cell.checked = false
            cell.chosenIV.alpha = 0.0
            for path in chosenPath {
                let row = path.row
                let row2 = indexPath.row
                if row2 == row {
                    cell.chosenIV.isHidden = false
                    cell.chosenIV.alpha = 1.0
                }
            }
            for user in chosenMembers {
                let guid1 = user.attendeeGuid
                if field6 == guid1 {
                    cell.chosenIV.isHidden = false
                    cell.chosenIV.alpha = 1.0
                    cell.checked = true
                }
            }
            return cell
        case .addButtonCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath) as! AddButtonCell
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        _ = row-2
        switch row {
        case 0, 1: break
        default:
            chosenPath.append(indexPath)
            let cellChecked = tableView.cellForRow(at: indexPath) as! CompletedThreeFieldExpandedCell
            if cellChecked.checked {
                cellChecked.checked = false
                self.tableView(tableView, didDeselectRowAt: indexPath)
            } else {
                cellChecked.checked = true
                cellChecked.chosenIV.isHidden = false
                cellChecked.chosenIV.alpha = 1.0
                let select = cellChecked.resources
                let entry = select[0]
                var name:String = ""
                var icsPosition:String = ""
                var homeAgency:String = ""
                var guid:String = ""
                if (entry.name) != nil {
                    name = entry.name!
                }
                if entry.homeAgency != nil {
                    homeAgency = entry.homeAgency!
                    if homeAgency == "" {
                        homeAgency = cellChecked.inputTextFieldThree.text!
                    }
                }
                if entry.icsPosition != nil {
                    icsPosition = entry.icsPosition!
                    if icsPosition == "" {
                        icsPosition = cellChecked.inputTextFieldTwo.text!
                    }
                }
                if entry.guid != nil {
                    guid = entry.guid!
                }
                if chosenMembers.isEmpty {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
                    let predicate1 = NSPredicate(format: "%K == %@","attendeeGuid",guid)
                    let predicate2 = NSPredicate(format: "%K == %@","attendee",name)
                    let predicate3 = NSPredicate(format: "%K == %@","attendeeHomeAgency",homeAgency)
                    let predicate4 = NSPredicate(format: "%K == %@","attendeeICSPosition",icsPosition)
                    
                    let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
                    fetchRequest.predicate = predicateCan
                    do {
                        let fetchedAttendee = try context.fetch(fetchRequest) as! [UserAttendees]
                        let member:UserAttendees = fetchedAttendee.last!
                        if !(chosenMembers.contains(member)) {
                            chosenMembers.append(member)
                        }
                        //                    print( member.attendee ?? "no attendee" )
                    }catch {
                        
                        let nserror = error as NSError
                        
                        let errorMessage = "TeamTVC contactsSaveBTapped()2 fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                        print(errorMessage)
                    }
                } else {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
                    let predicate1 = NSPredicate(format: "%K == %@","attendeeGuid",guid)
                    let predicate2 = NSPredicate(format: "%K == %@","attendee",name)
                    let predicate3 = NSPredicate(format: "%K == %@","attendeeHomeAgency",homeAgency)
                    let predicate4 = NSPredicate(format: "%K == %@","attendeeICSPosition",icsPosition)
                    
                    let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
                    fetchRequest.predicate = predicateCan
                    do {
                        let fetchedAttendee = try context.fetch(fetchRequest) as! [UserAttendees]
                        if fetchedAttendee.count > 0 {
                            let member:UserAttendees = fetchedAttendee.last!
                            if !(chosenMembers.contains(member)) {
                                chosenMembers.append(member)
                            }
                        }
                    }catch {
                        
                        let nserror = error as NSError
                        
                        let errorMessage = "TeamTVC contactsSaveBTapped()2 fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                        print(errorMessage)
                        
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 0, 1: break
        default:
            let cellChecked = tableView.cellForRow(at: indexPath) as! CompletedThreeFieldExpandedCell
            cellChecked.chosenIV.isHidden = true
            cellChecked.chosenIV.alpha = 0.0
            cellChecked.checked = false
            let select = cellChecked.resources
            let entry = select[0]
            let eGuid = entry.guid!
            let keepingMembers = chosenMembers.filter { $0.attendeeGuid != eGuid }
            chosenMembers.removeAll()
            chosenMembers = keepingMembers
            print(chosenMembers)
        }
    }
    
}
