    //
    //  ListTVC+ObserverExtensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/24/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit

extension ListTVC {
    
    func configureObservers() {
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector: #selector(dataSavedReloadList(ns:)), name:NSNotification.Name(rawValue: FJkRELOADTHELIST), object: nil)
        nc.addObserver(self, selector: #selector(dataSavedReloadListForMap(ns:)), name:NSNotification.Name(rawValue: FJkTHEMAPTYPECHANGED), object: nil)
        nc.addObserver(self, selector: #selector(loadNewestICS214(ns:)), name:NSNotification.Name(rawValue: FJkICS214_NEW_TO_LIST), object: nil)
        nc.addObserver(self, selector: #selector(loadNewestARCForm(ns:)), name:NSNotification.Name(rawValue: FJkARCFORM_NEW_TO_LIST), object: nil)
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector: #selector(viewNewestARCForm(ns:)), name:NSNotification.Name(rawValue: FJkNEWARCFORMCAMPAIGNCREATED), object: nil)
        
    }
    
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact: break
            case .regular: break
            }
        }
    }
    
    @objc func dataSavedReloadList(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            myShift = userInfo["shift"] as? MenuItems ?? .incidents
            tableView.reloadData()
        }
    }
    
    @objc func dataSavedReloadListForMap(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            myShiftTwo = userInfo["shift"] as? MenuItems ?? .incidents
            switch myShiftTwo {
            case .incidents, .fire, .ems, .rescue:
                entity = "Incident"
                attribute = "incidentSearchDate"
            case .ics214:
                entity = "ICS214Form"
                attribute = "ics214Guid"
            case .arcForm:
                entity = "ARCrossForm"
                attribute = "arcFormGuid"
            default: break
            }
            _ = getTheDataForTheList()
            tableView.reloadData()
        }
    }
    
    @objc func loadNewestICS214(ns: Notification) {
        if (ns.userInfo as! [String: Any]?) != nil
        {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
        }
    }
    
    @objc func loadNewestARCForm(ns: Notification) {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    
    @objc func noConnectionCalled(ns: Notification) {
        if vcLaunch.alertI == 0 {
            let alert = vcLaunch.networkUnavailable()
            self.present(alert,animated: true)
        }
    }
    
    @objc func viewNewestARCForm(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            let id = userInfo["object"] as! NSManagedObjectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type: MenuItems.arcForm, id: id, compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "Form", bundle: nil)
                let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
                let navigator = UINavigationController.init(rootViewController: controller)
                
                if theUserTime != nil {
                    controller.userTimeOID = theUserTime.objectID
                }
                if theFireJournalUser != nil {
                    controller.userOID = theFireJournalUser.objectID
                }
                
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                controller.delegate = self
                controller.objectID = id
                    //                controller.titleName = "CRR Smoke Alarm Inspection Form"
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        }
    }
    
}
