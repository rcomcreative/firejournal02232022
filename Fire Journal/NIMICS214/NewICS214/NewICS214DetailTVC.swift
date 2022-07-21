//
//  NewICS214DetailTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/12/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit

protocol NewICS214DetailTVCDelegate: AnyObject {
    func theCampaignHasChanged()
}

class NewICS214DetailTVC: UITableViewController {
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var autograph: T1Autograph = T1Autograph()
    var ics214: ICS214Form!
    var signatureImage:UIImage!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var objectID: NSManagedObjectID? = nil
    weak var delegate: NewICS214DetailTVCDelegate? = nil
    var ics214Guid: String = ""
    var resources = [UserAttendees]()
    var activityLogs = [ICS214ActivityLog]()
    var resource: NewICS214Resources!
    var logs: NewICS214ActivityLog!
    var theCampaign = [ICS214Form]()
    let cellsForForm = NewICS214Cells()
    var newTheCells = [NewICS214CellStorage]()
    var showPicker:Bool = false
    var showPickerTwo:Bool = false
    var showPickerThree:Bool = false
    var showPickerFour:Bool = false
    var completedB:Bool = false
    var signatureBool:Bool = false
    var masterGuid:String!
    var logTVHeight: CGFloat = 145
    var logCompletedTVHeight: CGFloat = 145
    var newActivityLogDateTime: Date!
    var newActivityLogText: String!
    var alertUp: Bool = false
    var activityLogClear: Bool = false
    var signatureDateTag: Int = 0
    var signatureImageTag: Int = 0
    var signatureDate: Date!
    var activityLogViewHeight: CGFloat = 145
    var saveActivityLogViewHeight: CGFloat = 145
    var theICS214Campaign = [ICS214Form]()
    var ics214ToCloud: ICS214ToCloud!
    var pdfLink: String = ""
    var saveButton: UIBarButtonItem!
    
    var fromMap: Bool = false
    var incidentType: IncidentTypes = .ics214Form
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    var theFireJournalUser: FireJournalUser!
    
        //    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            let errorMessage = "There is no user associated with this end shift"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theFireJournalUser = context.object(with: id) as? FireJournalUser
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NIMS ICS 214"
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        signatureImage = nil
        getTheUser()
        
        if !fromMap {
            if Device.IS_IPHONE {
                let listButton = UIBarButtonItem(title: "ICS 214", style: .plain, target: self, action: #selector(returnToList(_:)))
                navigationItem.leftBarButtonItem = listButton
                navigationItem.setLeftBarButtonItems([listButton], animated: true)
                navigationItem.leftItemsSupplementBackButton = false
            }
        }
        
        //        MARK: -BUILD THE CELLS
        if objectID != nil {
            buildTheCells()
        }
        
        
        //        MARK: -BUILD THE TABLE-
        registerCells()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        //        MARK: -NAVIGATION-
        if !fromMap {
            saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveICS214(_:)))
            navigationItem.rightBarButtonItem = saveButton
            _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
            


            if (Device.IS_IPHONE){
                self.navigationController?.navigationBar.backgroundColor = UIColor.white
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
            } else {
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            }

        }
        //        MARK: -OBSERVERS-
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(deliverTheShare(ns:)), name:NSNotification.Name(rawValue: FJkLINKFROMCLOUDFORICS214TOSHARE), object: nil)
    }
    
    
//    MARK: -RETURN TO THE LIST
    @objc private func returnToList(_ sender:Any) {
        closeItUp()
    }
    
    func closeItUp() {
        if  Device.IS_IPHONE {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:"FJkICS214FORMLISTCALLED"),
                             object: nil,
                             userInfo: nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.register(UINib(nibName: "NewICS214DatePickerCell", bundle: nil), forCellReuseIdentifier: "NewICS214DatePickerCell")
        tableView.register(UINib(nibName: "NewICS214LabelTextFieldCell",bundle: nil), forCellReuseIdentifier: "NewICS214LabelTextFieldCell")
        tableView.register(UINib(nibName: "NewICS214HeadCell",bundle: nil), forCellReuseIdentifier: "NewICS214HeadCell")
        tableView.register(UINib(nibName: "NewICS214DateTimeCell",bundle: nil), forCellReuseIdentifier: "NewICS214DateTimeCell")
        tableView.register(UINib(nibName: "NewICS214SignatureCell",bundle: nil), forCellReuseIdentifier: "NewICS214SignatureCell")
        tableView.register(UINib(nibName: "NewICS214ResourcesAssignedCell",bundle: nil), forCellReuseIdentifier: "NewICS214ResourcesAssignedCell")
        tableView.register(UINib(nibName: "NewICS214ResourceCompleteCell",bundle: nil), forCellReuseIdentifier: "NewICS214ResourceCompleteCell")
        tableView.register(UINib(nibName: "NewICS214ActivityLogCell",bundle: nil), forCellReuseIdentifier: "NewICS214ActivityLogCell")
        tableView.register(UINib(nibName: "NewICS214ActivityLogCompleteCell",bundle: nil), forCellReuseIdentifier: "NewICS214ActivityLogCompleteCell")
    }
    
    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("MapFormHeaderV", owner: self, options: nil)?.first as! MapFormHeaderV
        headerV.incidentType = incidentType
        headerV.delegate = self
        return headerV
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if fromMap {
            if  Device.IS_IPAD {
                return 44
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newTheCells.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = newTheCells[indexPath.row]
        let tag = cell.tag
        switch tag {
        case 0:
            //            NewICS214HeadCell
            return 150
        case 1:
            //            NewICS214LabelTextFieldCell
            return 85
        case 2:
            //            LabelCell
            return 60
        case 3: 
            //            NewICS214DateTimeCell
            return 90
        case 4:
            //            NewICS214DatePickerCell
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case 5:
            //            NewICS214DateTimeCell
            return 90
        case 6:
            //            NewICS214DatePickerCell
            if(showPickerTwo) {
                return  132
            } else {
                return 0
            }
        case 7:
            //            NewICS214LabelTextFieldCell
            return 85
        case 8:
            //            NewICS214LabelTextFieldCell
            return 85
        case 9:
            //            NewICS214LabelTextFieldCell
            return 85
        case 10:
            //            LabelCell
            return 60
        case 11:
            //            NewICS214ResourcesAssignedCell
            return 74
        case 12:
            //            LabelCell
            return 60
        case 13:
            //            NewICS214ActivityLogCell
            if activityLogViewHeight == 145 {
                activityLogViewHeight = getOverViewSize()
            }
            return activityLogViewHeight
        case 14:
            //             NewICS214DatePickerCell
            if(showPickerThree) {
                return  132
            } else {
                return 0
            }
        case 15:
            //            LabelCell
            return 60
        case 16:
            //            NewICS214LabelTextFieldCell
            return 85
        case 17:
            //            NewICS214LabelTextFieldCell
            return 85
        case 18:
            //            NewICS214LabelTextFieldCell
            return 90
        case 19:
            //             NewICS214DatePickerCell
            if(showPickerFour) {
                return  132
            } else {
                return 0
            }
        case 20:
            //                NewICS214SignatureCell
            return 200
        case 21:
            //            NewICS214ResourceCompleteCell
            return 44
        case 22:
            //            NewICS214ActivityLogCompleteCell
//            return 145
            if saveActivityLogViewHeight == 145 {
                saveActivityLogViewHeight = getSaveActivityLogSize(position:cell.arrayPosition)
            }
            return saveActivityLogViewHeight
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = newTheCells[indexPath.row]
        let tag = newCell.tag
        switch tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214HeadCell", for: indexPath) as!  NewICS214HeadCell
            let headCell = configureHeadCell(cell, at: indexPath)
            return headCell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
            return tfCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            let lCell = configureLabelCell(cell, at: indexPath, tag: tag)
            return lCell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DateTimeCell", for: indexPath) as! NewICS214DateTimeCell
            let dtCell = configureDateTimeCell(cell, at: indexPath, tag: tag)
            return dtCell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DatePickerCell", for: indexPath) as! NewICS214DatePickerCell
            cell.delegate = self
            cell.tag = 4
            cell.path = indexPath
            cell.theDatePicker.date = ics214.ics214FromTime ?? Date()
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DateTimeCell", for: indexPath) as! NewICS214DateTimeCell
            let dtCell = configureDateTimeCell(cell, at: indexPath, tag: tag)
            return dtCell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DatePickerCell", for: indexPath) as! NewICS214DatePickerCell
            cell.delegate = self
            cell.path = indexPath
            cell.tag = 6
            cell.theDatePicker.date = ics214.ics214ToTime ?? Date()
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
            return tfCell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
            return tfCell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
            return tfCell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            let lCell = configureLabelCell(cell, at: indexPath, tag: tag)
            return lCell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214ResourcesAssignedCell", for: indexPath) as!  NewICS214ResourcesAssignedCell
            if !resources.isEmpty {
                cell.addB.setTitle("Edit", for: .normal)
            }
            cell.delegate = self
            return cell
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            let lCell = configureLabelCell(cell, at: indexPath, tag: tag)
            return lCell
        case 13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214ActivityLogCell", for: indexPath) as! NewICS214ActivityLogCell
            let alCell = configureNewICS214ActivityLogCell(cell, at: indexPath, tag: tag)
            return alCell
        case 14:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DatePickerCell", for: indexPath) as! NewICS214DatePickerCell
            cell.delegate = self
            cell.path = indexPath
            cell.tag = 14
            cell.theDatePicker.date = Date()
            return cell
        case 15:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            let lCell = configureLabelCell(cell, at: indexPath, tag: tag)
            return lCell
        case 16:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
            return tfCell
        case 17:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
            return tfCell
        case 18:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DateTimeCell", for: indexPath) as! NewICS214DateTimeCell
            signatureDateTag = indexPath.row
            let dtCell = configureDateTimeCell(cell, at: indexPath, tag: tag)
            return dtCell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
//            signatureDateTag = indexPath.row
//            let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
//            return tfCell
        case 19:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214DatePickerCell", for: indexPath) as! NewICS214DatePickerCell
            cell.delegate = self
            cell.path = indexPath
            cell.tag = 19
            cell.theDatePicker.date = Date()
            return cell
        case 20:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214SignatureCell", for: indexPath) as! NewICS214SignatureCell
            signatureImageTag = indexPath.row
            let sCell = configureSignatureCell(cell, at: indexPath, tag: tag)
            return sCell
        case 21:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214ResourceCompleteCell", for: indexPath) as! NewICS214ResourceCompleteCell
            let position = newCell.arrayPosition
            let rCell = configureNewICS214ResourceCompleteCell(cell, at: indexPath, tag: tag, position: position )
            return rCell
        case 22:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214ActivityLogCompleteCell", for: indexPath) as! NewICS214ActivityLogCompleteCell
            let position = newCell.arrayPosition
            let aCell = configureNewICS214ActivityLogCompleteCell(cell, at: indexPath, tag: tag, position: position )
            return aCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the  specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

        
    
}
