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

extension ICS214FormDetailVC {
    
    func grabTheManagedObjects() {
        
        if theICS214FormOID != nil {
            theICS214Form = context.object(with: theICS214FormOID) as? ICS214Form
            if theICS214Form.ics214ActivityDetail != nil {
                if let result = theICS214Form.ics214ActivityDetail?.allObjects as? [ICS214ActivityLog] {
                    theICS214ActivityLog = result
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
            
            if Device.IS_IPHONE {
                let listButton = UIBarButtonItem(title: "ICS 214", style: .plain, target: self, action: #selector(returnToList(_:)))
                navigationItem.leftBarButtonItem = listButton
                navigationItem.setLeftBarButtonItems([listButton], animated: true)
                navigationItem.leftItemsSupplementBackButton = false
            } else {
                saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveICS214(_:)))
                navigationItem.rightBarButtonItem = saveButton
                _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
            }
            
            
            
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
    }
    
    func buildAddObservers() {
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(deliverTheShare(ns:)), name:NSNotification.Name(rawValue: FJkLINKFROMCLOUDFORICS214TOSHARE), object: nil)
        
        nc.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        ics214TableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func deliverTheShare(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            self.pdfLink = userInfo["pdfLink"] as? String ?? ""
//            let items = [URL(string: self.pdfLink)!]
            let items = [ self.pdfLink ]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let pc = ac.popoverPresentationController {
                pc.barButtonItem = saveButton
            }
             self.present(ac, animated: true, completion: nil)
        }
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
        
        NSLayoutConstraint.activate([
            ics214TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            ics214TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            ics214TableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60),
        ])
    }
}

extension ICS214FormDetailVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        
    }
    
}

extension ICS214FormDetailVC: UITableViewDataSource {
    
}
