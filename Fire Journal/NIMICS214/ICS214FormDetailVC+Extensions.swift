    //
    //  ICS214FormDetailVC+Extensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 8/9/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import Contacts
import ContactsUI
import T1Autograph

extension ICS214FormDetailVC {
    
    fileprivate func buildActivityHeight() {
        if !theICS214ActivityLog.isEmpty {
            activityAvailable = true
//            var heightCount: CGFloat = 0
//            for activityLog in theICS214ActivityLog {
//                if let log = activityLog.ics214ActivityLog {
//                    if log == "" {
//
//                    } else {
//                        let height = configureLabelHeight(text: log)
//                        heightCount = heightCount + height
//                    }
//                }
//            }
//            activityHeight = heightCount
            
            let count = theICS214ActivityLog.count
            let height = (44 * 3) * count
            activityHeight = CGFloat(height)
        }
    }
    
    func grabTheManagedObjects() {
        
        if theICS214FormOID != nil {
            theICS214Form = context.object(with: theICS214FormOID) as? ICS214Form
            theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
            if let theType = theICS214Form.ics214Effort {
                type = theICS214Provider.determineICS214TypeFromString(theType: theType)
            }
            masterOrNot = theICS214Form.ics214EffortMaster
            if theICS214Form.ics214ActivityDetail != nil {
                if let result = theICS214Form.ics214ActivityDetail?.allObjects as? [ICS214ActivityLog] {
                    theICS214ActivityLog = result
                    if !theICS214ActivityLog.isEmpty {
                        activityAvailable = true
                    }
                }
            }
            if theICS214Form.ics214PersonneDetail != nil {
                if let result = theICS214Form.ics214PersonneDetail?.allObjects as? [ICS214Personnel] {
                    theICS214Personnel = result
                    theUserAttendeeContext = theUserAttendeeProvider.persistentContainer.newBackgroundContext()
                    for personnel in theICS214Personnel {
                        if let attendeeGuid = personnel.userAttendeeGuid {
                            if let result = theUserAttendeeProvider.isUserAttendeePartOfCD(attendeeGuid, theUserAttendeeContext) {
                                let attendee = result.last
                                if let id = attendee?.objectID {
                                    if let userAttendee = context.object(with: id) as? UserAttendees {
                                        thePersonnel.append(userAttendee)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                if thePersonnel.count > 1 {
                    let theHeight = thePersonnel.count * 50
                    attendeeHeight = CGFloat(theHeight)
                    attendeesAvailable = true
                } else if thePersonnel.count == 1{
                    let theHeight = 50
                    attendeeHeight = CGFloat(theHeight)
                    attendeesAvailable = true
                }
            } else {
                attendeesAvailable = false
                attendeeHeight = 0
            }
            if theICS214Form.ics214SignatureAdded {
                signatureAvailable = true
                if theICS214Form.ics214Signature != nil {
                    if let signature = theICS214Form.ics214Signature {
                        if let imageUIImage: UIImage = UIImage(data: signature) {
                            signatureImage = imageUIImage
                        }
                    }
                }
            } else {
                signatureAvailable = false
            }
        } else {
            delegate?.cancelICS214FormDetail()
        }
        
        if theUserOID != nil {
            theUser = context.object(with: theUserOID) as? FireJournalUser
        } else {
            delegate?.cancelICS214FormDetail()
        }
        
        if theUserTimeOID != nil {
            theUserTime = context.object(with: theUserTimeOID) as? UserTime
        } else {
            delegate?.cancelICS214FormDetail()
        }
        
        switch type {
        case .incidentForm:
            imageName = "ICS_214_Form_LOCAL_INCIDENT"
            buildTheIncident()
        case .femaTaskForceForm:
            imageName = "ICS214FormFEMA"
            buildTheJournal()
        case .strikeForceForm:
            imageName = "ICS214FormSTRIKETEAM"
            buildTheJournal()
        case .otherForm:
            imageName = "ICS214FormOTHER"
            buildTheJournal()
        }
        
        ics214ToCloud = ICS214ToCloud.init(context)
        
    }
    
        //    MARK: -CONFIGUREHEIGHT-
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        var width: CGFloat = 0
        let frame = self.ics214TableView.frame
        width = frame.width - 150
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 15)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
        if theFloat < 44 {
            theFloat = 88
        }
        return theFloat
    }
    
    func buildTheJournal() {
        if theJournalOID != nil {
            theJournal = context.object(with: theJournalOID) as? Journal
            if theJournal.theLocation != nil {
                theJournalLocation = theJournal.theLocation
                theJournal.locationAvailable = true
            } else {
                theJournal.locationAvailable = false
                theJournalLocation = FCLocation(context: context)
                theJournal.theLocation = theJournalLocation
            }
        }
    }
    
    func buildTheIncident() {
        if theIncidentOID != nil {
            theIncident = context.object(with: theIncidentOID) as? Incident
            if theIncident.theLocation != nil {
                theIncidentLocation = theIncident.theLocation
                theIncident.locationAvailable = true
            } else {
                theIncident.locationAvailable = false
                theIncidentLocation = FCLocation(context: context)
                theIncident.theLocation = theIncidentLocation
            }
        }
    }
    
    func buildNavigation() {
            //        MARK: -NAVIGATION-
        if !fromMap {
            
            saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveICS214(_:)))
            navigationItem.rightBarButtonItem = saveButton
            _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
            
            if Device.IS_IPHONE {
                let listButton = UIBarButtonItem(title: "ICS 214", style: .plain, target: self, action: #selector(returnToList(_:)))
                navigationItem.leftBarButtonItem = listButton
                navigationItem.setLeftBarButtonItems([listButton], animated: true)
                navigationItem.leftItemsSupplementBackButton = false
                let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
                ]
                listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
                listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
            }
            
            
            
            if (Device.IS_IPHONE){
                self.navigationController?.navigationBar.barTintColor = UIColor(named: "FJBlueColor")
                self.navigationController?.navigationBar.isTranslucent = false
                let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
                ]
                saveButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
                saveButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
            } else {
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
                navigationBarAppearace.isTranslucent = false
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
                
            }
            
        }
    }
    
    func buildAddObservers() {
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(deliverTheShare(ns:)), name:NSNotification.Name(rawValue: FJkLINKFROMCLOUDFORICS214TOSHARE), object: nil)
        nc.addObserver(self, selector: #selector(editThePersonnel(nc:)), name: .fConEditICS214UserAttendee, object: nil)
        nc.addObserver(self, selector: #selector(editTheActivityLog(nc:)), name: .fConLaunchEditICS214ActivityLog, object: nil)
        nc.addObserver(self, selector: #selector(deleteFromActivityLog(nc:)), name: .fConLaunchDeleteICS214ActivityLog, object: nil)
        nc.addObserver(self,selector: #selector(removeSpinnerUpdate(ns:)),name: .fConICS214DropTheSpinner, object:nil)
        
        nc.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc func deleteFromActivityLog(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["activityLogID"] as? NSManagedObjectID {
                let activityLogModel = context.object(with: id)
                let oneICS214ActivityLog = context.object(with: id) as! ICS214ActivityLog
                context.delete(activityLogModel)
                theICS214Form.removeFromIcs214ActivityDetail(oneICS214ActivityLog)
                saveToCoreData() {
                    theICS214ActivityLog.removeAll()
                    theICS214Form = context.object(with: theICS214FormOID) as? ICS214Form
                    if theICS214Form.ics214ActivityDetail != nil {
                        if let result = theICS214Form.ics214ActivityDetail?.allObjects as? [ICS214ActivityLog] {
                            theICS214ActivityLog = result
                        }
                    }
                    if !theICS214ActivityLog.isEmpty {
                        activityAvailable = true
                        let count = theICS214ActivityLog.count
//                        var heightCount: CGFloat = 0
                        let height = (44 * 3) * count
//                        for activityLog in theICS214ActivityLog {
//                            if let log = activityLog.ics214ActivityLog {
//                                let height = configureLabelHeight(text: log)
//                                heightCount = heightCount + height
//                            }
//                        }
//                        activityHeight = heightCount
                        activityHeight = CGFloat(height)
                    }
                    
                    let index1 = IndexPath(row: 15, section: 0)
                    let index2 = IndexPath(row: 16, section: 0)
                    self.ics214TableView.reloadRows(at: [index1, index2], with: .automatic)
                }
            }
        }
    }
    
    @objc func editThePersonnel(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["userAttendeeID"] as? NSManagedObjectID {
                let crew = context.object(with: id) as? UserAttendees
                let storyboard = UIStoryboard(name: "AssignedResource", bundle: nil)
                editVC  = storyboard.instantiateViewController(identifier: "NewICS214AssignedResourceEditVC") as? NewICS214AssignedResourceEditVC
                editVC.path = IndexPath(row: 12, section: 0)
                editVC.cMember = crew
                editVC.delegate = self
                self.present(editVC, animated: true )
            }
        }
    }
    
    @objc func editTheActivityLog(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["activityLogID"] as? NSManagedObjectID {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let storyBoard: UIStoryboard = UIStoryboard(name: "ICS214ActivityLog", bundle: nil)
                ics214ActivityLogVC = storyBoard.instantiateViewController(withIdentifier: "ICS214ActivityLogVC") as? ICS214ActivityLogVC
                ics214ActivityLogVC.delegate = self
                ics214ActivityLogVC.ics214FormOID = theICS214FormOID
                ics214ActivityLogVC.ics214ActivityLogOID = id
                ics214ActivityLogVC.transitioningDelegate = slideInTransitioningDelgate
                if Device.IS_IPHONE {
                ics214ActivityLogVC.modalPresentationStyle = .formSheet
                } else {
                    ics214ActivityLogVC.modalPresentationStyle = .custom
                }
                self.present(ics214ActivityLogVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func deliverTheShare(ns: Notification) {
        self.nc.post(name: .fConICS214DropTheSpinner,object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if let userInfo = ns.userInfo as! [String: Any]?
            {
                if let theLink = userInfo["pdfLink"] as? String {
                    self.pdfLink = theLink
                    let items = [ self.pdfLink ]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    if let pc = ac.popoverPresentationController {
                        pc.barButtonItem = self.saveButton
                    }
                    self.present(ac, animated: true, completion: nil)
                }
            }
        })
    }
                                      
    
    func configureics214TableView() {
        ics214TableView = UITableView(frame: .zero)
        registerCellsForTable()
        ics214TableView.translatesAutoresizingMaskIntoConstraints = false
        ics214TableView.backgroundColor = .systemBackground
        view.addSubview(ics214TableView)
        ics214TableView.delegate = self
        ics214TableView.dataSource = self
        ics214TableView.separatorStyle = .none
        
        ics214TableView.rowHeight = UITableView.automaticDimension
        ics214TableView.estimatedRowHeight = 300
        
        if Device.IS_IPHONE {
        NSLayoutConstraint.activate([
            ics214TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            ics214TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            ics214TableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60),
        ])
        } else {
            NSLayoutConstraint.activate([
                ics214TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                ics214TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0),
                ics214TableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
                ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            ])
        }
        
        
    }
}

extension ICS214FormDetailVC: NewICS214AssignedResourceEditVCDelegate {
    
    func theCancelTapped() {
        editVC.dismiss(animated: true, completion: nil)
    }
    
    func theAssignedResourceEditSaveTapped(member: UserAttendees, path: IndexPath) {
        member.attendeeModDate = Date()
        member.attendeeBackUp = false
        saveToCoreData() {
            editVC.dismiss(animated: true, completion: {
                self.ics214TableView.reloadRows(at: [path], with: .automatic)
            })
        }
    }
    
    func saveToCoreData(completion: () -> Void) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214ResourcesAssignedTVC merge that"])
            }
            completion()
        } catch let error as NSError {
            print("NewICS214ResourcesAssignedTVC line 140 Fetch Error: \(error.localizedDescription)")
        }
    }
    
}

extension ICS214FormDetailVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        ics214TableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        ics214TableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        ics214TableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        ics214TableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        
        
        ics214TableView.register(ICS214DetailHeaderTVCell.self, forCellReuseIdentifier: "ICS214DetailHeaderTVCell")
        ics214TableView.register(ICS214SegmentTVCell.self, forCellReuseIdentifier: "ICS214SegmentTVCell")
        ics214TableView.register(ICS214ResourcesHeaderTVCell.self, forCellReuseIdentifier: "ICS214ResourcesHeaderTVCell")
        ics214TableView.register(ICS214ActivityLogHeaderTVCell.self, forCellReuseIdentifier: "ICS214ActivityLogHeaderTVCell")
        ics214TableView.register(ICS214ButtonTVCell.self, forCellReuseIdentifier: "ICS214ButtonTVCell")
        ics214TableView.register(ICS214ResourcesCVTVCell.self, forCellReuseIdentifier: "ICS214ResourcesCVTVCell")
        ics214TableView.register(ICS214ActivityLogsCVTVCell.self, forCellReuseIdentifier: "ICS214ActivityLogsCVTVCell")
        ics214TableView.register(SignatureImageTVCell.self, forCellReuseIdentifier: "SignatureImageTVCell")

    }
    
}

extension ICS214FormDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            if subscriptionBought {
                return 184
            } else {
                return 80
            }
        case 1:
            return 60
        case 2, 6, 7, 8, 18, 19:
            return 85
        case 3, 9, 13:
            return 60
        case 4, 5, 22:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 100
            }
        case 10, 14, 20:
            return 51
        case 11:
            if attendeesAvailable {
                return 30
            } else {
                return 0
            }
        case 12:
            if attendeesAvailable {
                return attendeeHeight
            } else {
                return 0
            }
        case 15:
            if activityAvailable {
                return 30
            } else {
                return 0
            }
        case 16:
            if activityAvailable {
                if theICS214ActivityLog.count < 3 {
                    return 100
                } else {
                    let count = theICS214ActivityLog.count
                    let height = CGFloat(35 * count)
                    return height
                }
            } else {
                return 0
            }
        case 17:
            if activityAvailable {
                return 90
            } else {
                return 65
            }
        case 21:
            if signatureAvailable {
                return 250
            } else {
                return 0
            }
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214DetailHeaderTVCell", for: indexPath) as! ICS214DetailHeaderTVCell
            cell = configureICS214DetailHeaderTVCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214SegmentTVCell", for: indexPath) as! ICS214SegmentTVCell
            cell = configureICS214SegmentTVCell(cell, index: indexPath)
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 3, 9, 13, 17:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
        case 4:
//            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
                cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
                return cell
//            } else {
//                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
//                cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
//                cell.configureTheLabel(width: 125)
//                cell.configureDatePickersHoldingV()
//                return cell
//            }
        case 5:
//            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
                cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
                return cell
//            } else {
//                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
//                cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
//                cell.configureTheLabel(width: 125)
//                cell.configureDatePickersHoldingV()
//                return cell
//            }
        case 6:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case  7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 8:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 10, 14, 20:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214ButtonTVCell", for: indexPath) as! ICS214ButtonTVCell
            cell = configureICS214ButtonTVCell(cell, index: indexPath)
            return cell
        case 11:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214ResourcesHeaderTVCell", for: indexPath) as! ICS214ResourcesHeaderTVCell
            if attendeesAvailable {
                cell = configureICS214ResourcesHeaderTVCell( cell, index: indexPath)
            }
            return cell
        case 12:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214ResourcesCVTVCell", for: indexPath) as! ICS214ResourcesCVTVCell
            if attendeesAvailable {
                cell = configureICS214ResourcesCVTVCell(cell, index: indexPath)
            }
            return cell
        case 15:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214ActivityLogHeaderTVCell", for: indexPath) as! ICS214ActivityLogHeaderTVCell
            if activityAvailable {
                cell = configureICS214ActivityLogHeaderTVCell( cell, index: indexPath)
            }
            return cell
        case 16:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214ActivityLogsCVTVCell", for: indexPath) as! ICS214ActivityLogsCVTVCell
            if activityAvailable {
                cell = configureICS214ActivityLogsCVTVCell(cell, index: indexPath)
            }
            return cell
        case 18:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 19:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 21:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SignatureImageTVCell", for: indexPath) as! SignatureImageTVCell
            if signatureAvailable {
                cell = configureSignatureImageTVCell(cell, index: indexPath)
            }
            return cell
        case 22:
//            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
                cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
                return cell
//            } else {
//                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
//                cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
//                cell.configureTheLabel(width: 125)
//                cell.configureDatePickersHoldingV()
//                return cell
//            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.subjectL.isHidden = true
            cell.subjectL.text = ""
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
            return cell
        }
    }
    
    func configureSignatureImageTVCell(_ cell: SignatureImageTVCell, index: IndexPath) -> SignatureImageTVCell {
        if signatureImage != nil {
            cell.configure(signatureImage)
        }
        return cell
    }
    
    func configureICS214ActivityLogsCVTVCell(_ cell: ICS214ActivityLogsCVTVCell, index: IndexPath) -> ICS214ActivityLogsCVTVCell {
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        cell.configure(theICS214FormOID, theICS214ProviderContext, index: index, theICS214ActivityLog)
        return cell
    }
    
    func configureICS214ResourcesCVTVCell(_ cell: ICS214ResourcesCVTVCell, index: IndexPath) -> ICS214ResourcesCVTVCell {
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        cell.configure(theICS214FormOID, theICS214ProviderContext, index: index)
        return cell
    }
    
    func configureICS214ActivityLogHeaderTVCell(_ cell: ICS214ActivityLogHeaderTVCell, index: IndexPath) -> ICS214ActivityLogHeaderTVCell {
        cell.tag = index.row
        cell.configure()
        return cell
    }
    
    
    
    func configureICS214ResourcesHeaderTVCell(_ cell: ICS214ResourcesHeaderTVCell, index: IndexPath) -> ICS214ResourcesHeaderTVCell {
        cell.tag = index.row
        cell.configure()
        return cell
    }
    
    func configureICS214ButtonTVCell(_ cell: ICS214ButtonTVCell, index: IndexPath) -> ICS214ButtonTVCell {
        let row = index.row
        switch row {
        case 10:
            cell.index = index
            cell.buttonTitle = " Add Resource"
            cell.imageName = "person.crop.circle.badge.plus"
            cell.delegate = self
        case 14:
            cell.index = index
            cell.buttonTitle = " Add Notable Activity"
            cell.imageName = "note.text.badge.plus"
            cell.delegate = self
        case 20:
            cell.index = index
            cell.buttonTitle = " Add Signature"
            cell.imageName = "signature"
            cell.delegate = self
        default: break
        }
        cell.configure(index: index)
        return cell
    }
    
    func configureICS214DetailHeaderTVCell(_ cell: ICS214DetailHeaderTVCell, index: IndexPath) -> ICS214DetailHeaderTVCell {
        cell.tag = index.row
        let objectID = theICS214Form.objectID
        cell.configure(objectID, type: type)
        cell.delegate = self
        return cell
    }
    
    func configureICS214SegmentTVCell(_ cell: ICS214SegmentTVCell, index: IndexPath) -> ICS214SegmentTVCell {
        cell.tag = index.row
        let master = theICS214Form.ics214EffortMaster
        cell.delegate = self
        cell.configure(master: master)
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        switch row {
        case 2:
            cell.delegate = self
            cell.subjectL.text = ""
            cell.descriptionTF.text = ""
            switch type {
            case .incidentForm:
                cell.theShift = MenuItems.incidentForm
                cell.subjectL.text = "1. Incident Name"
            case .femaTaskForceForm:
                cell.theShift = MenuItems.femaTask
                cell.subjectL.text = "1. Effort Name"
            case .strikeForceForm:
                cell.theShift = MenuItems.strikeTeam
                cell.subjectL.text = "1. Effort Name"
            case .otherForm:
                cell.theShift = MenuItems.otherForm
                cell.subjectL.text = "1. Effort Name"
            }
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            cell.descriptionTF.text = ""
            if let name = theICS214Form.ics214IncidentName {
                cell.descriptionTF.text = name
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Name of effort",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 6:
            cell.delegate = self
            cell.subjectL.text = "3. Name"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            cell.descriptionTF.text = ""
            if let name = theICS214Form.ics214UserName {
                cell.descriptionTF.text = name
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "John Smith",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 7:
            cell.delegate = self
            cell.subjectL.text = "4. ICS Position"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            cell.descriptionTF.text = ""
            if let position = theICS214Form.ics214ICSPosition {
                cell.descriptionTF.text = position
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Firefighter",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 8:
            cell.delegate = self
            cell.subjectL.text = "5. Home Agency"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            cell.descriptionTF.text = ""
            if let agency = theICS214Form.ics241HomeAgency {
                cell.descriptionTF.text = agency
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Fire Department",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 18:
            cell.delegate = self
            cell.subjectL.text = "Preparing Name"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            cell.descriptionTF.text = ""
            if let preparerName = theICS214Form.icsPreparfedName {
                cell.descriptionTF.text = preparerName
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Name of person preparing form",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        case 19:
            cell.delegate = self
            cell.subjectL.text = "Position/Type"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            cell.descriptionTF.text = ""
            if let preparedPosition = theICS214Form.icsPreparedPosition {
                cell.descriptionTF.text = preparedPosition
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Preparer's position",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
        default: break
        }
        return cell
    }
    
    func configureLabelCell(_ cell: LabelCell, index: IndexPath) -> LabelCell {
        let row = index.row
        switch row {
        case 3:
            cell.modalTitleL.text = "2. Operational Period:"
            cell.infoB.isHidden = true
            cell.infoB.isEnabled = false
            cell.infoB.alpha = 0.0
        case 9:
            cell.modalTitleL.text = "6. Resources Assigned:"
            cell.infoB.isHidden = true
            cell.infoB.isEnabled = false
            cell.infoB.alpha = 0.0
        case 13:
            cell.modalTitleL.text = "7. Activity Logs:"
            cell.infoB.isHidden = true
            cell.infoB.isEnabled = false
            cell.infoB.alpha = 0.0
        case 17:
            cell.modalTitleL.text = "8. Prepared by:"
            cell.infoB.isHidden = true
            cell.infoB.isEnabled = false
            cell.infoB.alpha = 0.0
        default: break
        }
        return cell
    }
    
    func configureLabelDateiPhoneTVCell(_ cell: LabelDateiPhoneTVCell, index: IndexPath) -> LabelDateiPhoneTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 4:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "From Date/Time"
                if theICS214Form != nil {
                    if let fromTime = theICS214Form.ics214FromTime {
                        cell.theFirstDose = fromTime
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214FromTime = modTime
                        }
                    }
                }
            case 5:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "To Date/Time"
                if theICS214Form != nil {
                    if let toTime = theICS214Form.ics214ToTime {
                        cell.theFirstDose = toTime
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214ToTime = modTime
                        }
                    }
                }
            case 22:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Preparation Date/Time"
                if theICS214Form != nil {
                    if let sigDate = theICS214Form.ics214SignatureDate {
                        cell.theFirstDose = sigDate
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214SignatureDate = modTime
                        }
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureLabelSingleDateFieldCell(_ cell: LabelSingleDateFieldCell, index: IndexPath ) -> LabelSingleDateFieldCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 4:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "From Date/Time"
                if theICS214Form != nil {
                    if let fromTime = theICS214Form.ics214FromTime {
                        cell.theFirstDose = fromTime
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214FromTime = modTime
                        }
                    }
                }
            case 5:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "To Date/Time"
                if theICS214Form != nil {
                    if let toTime = theICS214Form.ics214ToTime {
                        cell.theFirstDose = toTime
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214ToTime = modTime
                        }
                    }
                }
            case 22:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Preparation Date/Time"
                if theICS214Form != nil {
                    if let sigDate = theICS214Form.ics214SignatureDate {
                        cell.theFirstDose = sigDate
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214SignatureDate = modTime
                        }
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
}

extension ICS214FormDetailVC: ICS214DetailHeaderTVCellDelegate {
  
    func theEditButtonTapped(_ theICS214OID: NSManagedObjectID) {
        
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "ICS214EditHeader", bundle:nil)
        editHeaderVC = storyBoard.instantiateViewController(withIdentifier: "ICS214EditHeaderVC") as? ICS214EditHeaderVC
        editHeaderVC.configure(theICS214FormOID)
        editHeaderVC.transitioningDelegate = slideInTransitioningDelgate
        editHeaderVC.delegate = self
        if Device.IS_IPHONE {
            editHeaderVC.modalPresentationStyle = .formSheet
        } else {
            editHeaderVC.modalPresentationStyle = .custom
        }
        self.present(editHeaderVC, animated: true, completion: nil)
        
    }
    
    func theShareButtonTapped(_ theICS214OID: NSManagedObjectID) {
        let _ = ics214ToCloud.buildToShare(theICS214OID)
        presentAlert()
        ics214ToCloud.sendAndRecieve(dataCompletionHander:  { link, error in
             if link == link {
                self.pdfLink = link
            }
        })
    }
    
    
}

extension ICS214FormDetailVC: ICS214EditHeaderVCDelegate {
    
    func editHeaderCancelled() {
        editHeaderVC.dismiss(animated: true, completion: nil)
    }
    
    func editHeaderSaved(_ theics214FormOID: NSManagedObjectID) {
        editHeaderVC.dismiss(animated: true, completion: nil)
        if let form = context.object(with: theics214FormOID) as? ICS214Form {
            theICS214Form = form
            let index = IndexPath(row: 0, section: 0)
            let index2 = IndexPath(row:2, section: 0)
            ics214TableView.reloadRows(at: [index, index2], with: .automatic)
        }
        
    }
    
    
}

extension ICS214FormDetailVC: ICS214SegmentTVCellDelegate {
    
    func theICS214CompleteSwitchTapped(complete: Bool) {
        theICS214Form.ics214EffortMaster = complete
        let completeionDate = Date()
        if complete {
            theICS214Form.ics214Completed = true
            theICS214Form.ics214CompletionDate = completeionDate
            theICS214Form.ics214BackedUp = false
            theICS214Form.ics214ModDate = completeionDate
        }
        let result = theICS214Form.master?.allObjects as! [ICS214Form]
        if !result.isEmpty {
            for log in result {
                log.ics214EffortMaster = complete
                log.ics214Completed = true
                log.ics214CompletionDate = completeionDate
                log.ics214BackedUp = false
                log.ics214ModDate = completeionDate
            }
        }
        saveICS214(self)
    }
    
    func theICS214DetailInfoBTapped() {
        infoAlert()
    }
    
    
}

extension ICS214FormDetailVC: ICS214ButtonTVCellDelegate, T1AutographDelegate {
    
    func theButtonTapped(index: IndexPath) {
        let row = index.row
        switch row {
        case 10:
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "NewICS214ResourcesAssigned", bundle:nil)
            personnelTVC = storyBoard.instantiateViewController(withIdentifier: "NewICS214ResourcesAssignedTVC") as? NewICS214ResourcesAssignedTVC
            personnelTVC.selected = thePersonnel
            personnelTVC.delegate = self
            personnelTVC.transitioningDelegate = slideInTransitioningDelgate
            if Device.IS_IPHONE {
                personnelTVC.modalPresentationStyle = .formSheet
            } else {
            personnelTVC.modalPresentationStyle = .custom
            }
            self.present(personnelTVC, animated: true, completion: nil)
        case 14:
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard: UIStoryboard = UIStoryboard(name: "ICS214ActivityLog", bundle: nil)
            ics214ActivityLogVC = storyBoard.instantiateViewController(withIdentifier: "ICS214ActivityLogVC") as? ICS214ActivityLogVC
            ics214ActivityLogVC.delegate = self
            ics214ActivityLogVC.ics214FormOID = theICS214FormOID
            ics214ActivityLogVC.transitioningDelegate = slideInTransitioningDelgate
            if Device.IS_IPHONE {
            ics214ActivityLogVC.modalPresentationStyle = .formSheet
            } else {
                ics214ActivityLogVC.modalPresentationStyle = .custom
            }
            self.present(ics214ActivityLogVC, animated: true, completion: nil)
        case 20:
            autograph = T1Autograph.autograph(withDelegate: self, modalDisplay: "ICS 214 Activity Log Signature") as! T1Autograph
            
            // Enter license code here to remove the watermark
            autograph.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"
            
            // any optional configuration done here
            autograph.showDate = false
            autograph.strokeColor = UIColor.darkGray
        default: break
        }
    }
    
    func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
        theICS214Form.ics214SignatureDate = Date()
        signatureImage = UIImage(data:signature.imageData,scale:1.0)
        signatureAvailable = true
        if let imageD = signatureImage!.pngData() as NSData? {
            theICS214Form.ics214Signature = imageD as Data
        }
        theICS214Form.ics214SignatureAdded = true
        saveICS214(self)
        let path1 = IndexPath(row: 22, section: 0)
        let path = IndexPath(row: 21, section: 0)
        ics214TableView.reloadRows(at: [path1,path], with: .automatic)
    }
    
    func autographDidCancelModalView(_ autograph: T1Autograph!) {
        signatureAvailable = false
        signatureImage = nil
        let path = IndexPath(row: 21, section: 0)
        ics214TableView.reloadRows(at: [path], with: .automatic)
    }
    
    func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
        signatureAvailable = false
        signatureImage = nil
        let path = IndexPath(row: 21, section: 0)
        ics214TableView.reloadRows(at: [path], with: .automatic)
    }
    
    func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
        // Note: You can use the 'count' parameter to determine if the line is substantial enough to enable the done or clear button.
    }
    
    func autograph(_ autograph: T1Autograph!, willCompleteWith signature: T1Signature!) {
        NSLog("Autograph will complete with signature")
    }
    
    
}

extension ICS214FormDetailVC: ICS214ActivityLogVCDelegate {
    
    func theICS214ActivityLogCancelled() {
        ics214ActivityLogVC.dismiss(animated: true, completion: nil)
    }
    
    func theICS214ActivityLogCreated() {
        theICS214ActivityLog.removeAll()
        ics214ActivityLogVC.dismiss(animated: true, completion: nil)
        theICS214Form = context.object(with: theICS214FormOID) as? ICS214Form
        if theICS214Form.ics214ActivityDetail != nil {
            if let result = theICS214Form.ics214ActivityDetail?.allObjects as? [ICS214ActivityLog] {
                theICS214ActivityLog = result
            }
        }
        if !theICS214ActivityLog.isEmpty {
            activityAvailable = true
//            var heightCount: CGFloat = 0
//            for activityLog in theICS214ActivityLog {
//                if let log = activityLog.ics214ActivityLog {
//                    let height = configureLabelHeight(text: log)
//                    heightCount = heightCount + height
//                }
//            }
//            activityHeight = heightCount
            let count = theICS214ActivityLog.count
            let height = (44 * 3) * count
            activityHeight = CGFloat(height)
        }
        
        let index1 = IndexPath(row: 15, section: 0)
        let index2 = IndexPath(row: 16, section: 0)
        self.ics214TableView.reloadRows(at: [index1, index2], with: .automatic)
    }
    
    
}

extension ICS214FormDetailVC: NewICS214ResourcesAssignedTVCDelegate {
  
    func newICS214ResourcesAssignedCanceled() {
        personnelTVC.dismiss(animated: true, completion: nil)
    }
    
    func newICS214ResourcesAssignedGroupToSave(crew: [UserAttendees]) {
        personnelTVC.dismiss(animated: true, completion: {
        for person in crew {
            let result = self.thePersonnel.filter { $0.objectID == person.objectID}
            if result.isEmpty {
                    self.attendeesAvailable = true
                    self.thePersonnel.append(person)
            }
        }
            for person in self.thePersonnel {
                if let guid = person.attendeeGuid {
                    let result = self.theICS214Personnel.filter({ $0.userAttendeeGuid == guid})
                    if result.isEmpty {
                        var personnel = ICS214Personnel(context: self.context)
                        if let theGuid = self.theICS214Form.ics214Guid {
                            personnel =  personnel.buildTheICS214Personnel(guid, theGuid)
                            self.theICS214Form.addToIcs214PersonneDetail(personnel)
                            
                        }
                    }
                    
                    
                }
                
            }
            self.saveICS214Attendees(self)
            let theHeight = self.thePersonnel.count * 50
            self.attendeeHeight = CGFloat(theHeight)
            
            
        let index1 = IndexPath(row: 11, section: 0)
        let index2 = IndexPath(row: 12, section: 0)
            self.ics214TableView.reloadRows(at: [index1, index2], with: .automatic)
        })
    }
    
    
}

extension ICS214FormDetailVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        let row = index.row
        switch row {
        case 4:
            theICS214Form.ics214FromTime = theDate
        case 5:
            theICS214Form.ics214ToTime = theDate
        default: break
        }
    }
    
}

extension ICS214FormDetailVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        let row = index.row
        switch row {
        case 4:
            theICS214Form.ics214FromTime = date
        case 5:
            theICS214Form.ics214ToTime = date
        default: break
        }
    }
    
}


extension ICS214FormDetailVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        switch tag {
        case 2:
            theICS214Form.ics214IncidentName = text
        case 6:
            theICS214Form.ics214UserName = text
        case 7:
            theICS214Form.ics214ICSPosition = text
        case 8:
            theICS214Form.ics241HomeAgency = text
        case 18:
            theICS214Form.icsPreparfedName = text
        case 19:
            theICS214Form.icsPreparedPosition = text
        default: break
        }
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
}
