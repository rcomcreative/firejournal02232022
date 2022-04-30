    //
    //  DetailViewController+NotificationExtensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/2/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import AVFoundation
import Foundation
import CoreData
import CoreLocation
import StoreKit

extension DetailViewController {
    
        //    MARK: -REGISTER NOTIFICATIONS-
    func registerNotifications() {
        nc.addObserver(self, selector:#selector(formsWasTapped(notification:)), name:NSNotification.Name(rawValue: FJkFORMS_FROM_MASTER), object: nil)

        nc.addObserver(self, selector:#selector(formsWasTapped(notification:)), name:NSNotification.Name(rawValue: FJkFORMS_FROM_DETAIL), object: nil)
        
        nc.addObserver(self, selector:#selector(journalWasTapped(nc:)), name:NSNotification.Name(rawValue: FJkJOURNAL_FROM_DETAIL), object: nil)
        
        nc.addObserver(self, selector:#selector(incidentWasTapped(nc:)), name:NSNotification.Name(rawValue: FJkINCIDENT_FROM_DETAIL), object: nil)
        
        nc.addObserver(self, selector:#selector(endShiftWasTapped(nc:)), name:NSNotification.Name(rawValue: FJkENDSHIFT_FROM_DETAIL), object: nil)
        
        nc.addObserver(self, selector:#selector(startShiftWasTapped(nc:)), name:NSNotification.Name(rawValue: FJkSTARTSHIFT_FROM_DETAIL), object: nil)

        nc.addObserver(self,selector:#selector(newUserCreated(notification:)), name:NSNotification.Name(rawValue:FJkFireJournalUserSaved),object:nil)
        
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        
        nc.addObserver(self, selector:#selector(startShiftForDash(ns:)),name:NSNotification.Name(rawValue: FJkSTARTSHIFTFORDASH), object: nil)
        
        nc.addObserver(self, selector:#selector(newContentForDashboard(ns:)),name:NSNotification.Name(rawValue: FJkRELOADTHEDASHBOARD), object: nil)
        
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        nc.addObserver(self, selector:#selector(updateWeatherInfo(ns:)),name:NSNotification.Name(rawValue: FJkWEATHERHASBEENUPDATED), object: nil)
        
        nc.addObserver(self, selector: #selector(loadTheFormModal(ns:)), name: NSNotification.Name(rawValue: FJkLOADFORMMODAL), object: nil)
        
        nc.addObserver(self, selector: #selector(addNewPersonalNewEntryModal(nc:)), name: NSNotification.Name(rawValue: FJkLOADPERSONALMODAL), object: nil)
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        nc.addObserver(self, selector: #selector(checkOnTheVersion(nc:)), name: NSNotification.Name(rawValue: FJkLETSCHECKTHEVERSION), object: nil)
        
        nc.addObserver(self, selector: #selector(presentNewJournalForEmptyJournalA(nc:)), name: .fireJournalPresentNewJournal, object: nil)
        
        nc.addObserver(self, selector:#selector(myFreshDeskUpdated(ns:)),name:NSNotification.Name(rawValue: FJkFRESHDESK_UPDATED), object: nil)
        
    }
    
        //    MARK: -NOTIFICATION FUNCTIONS-
    
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
        }
    }
    
    @objc func presentTheIncidentModalFirstTime() {
        
    }
    
    @objc func checkOnTheVersion(nc: Notification) {
        if agreementAccepted {
            if Device.IS_IPAD {
                versionControlled = userDefaults.bool(forKey: FJkVERSIONCONTROL)
                if versionControlled {} else {
                    self.nc.addObserver(self,selector: #selector(versionControlYouShouldChange(ns:)),name:NSNotification.Name(rawValue: FJkVERSIONCONTROL), object: nil)
                    userDefaults.set(true, forKey: FJkVERSIONCONTROL)
                    userDefaults.synchronize()
                }
            }
        }
    }
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func loadTheFormModal(ns: Notification) {
        presentFormsModal()
    }
    
    func presentModal(menuType: MenuItems, title: String) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "ModalTVC") as! ModalTVC
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        modalTVC.myShift = menuType
        if personalModalCalled {
            modalTVC.personalJournalEntry = true
        }
        modalTVC.modalPresentationStyle = .custom
        modalTVC.context = context
        self.present(modalTVC, animated: true, completion: nil)
    }
    
    @objc func addNewPersonalNewEntryModal(nc: Notification) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let personalNewEntrylModalTVC = storyBoard.instantiateViewController(withIdentifier: "PersonalNewEntryModalTVC") as! PersonalNewEntryModalTVC
        personalNewEntrylModalTVC.transitioningDelegate = slideInTransitioningDelgate
        personalNewEntrylModalTVC.modalPresentationStyle = .custom
        personalNewEntrylModalTVC.context = context
        personalNewEntrylModalTVC.delegate = self
        self.present(personalNewEntrylModalTVC,animated: true)
    }
    
    @objc func formsWasTapped(notification:Notification)-> Void {
        presentFormsModal()
    }
    
    @objc func incidentWasTapped(nc: Notification)-> Void {
        presentNewIncidentFormModal()
    }
    
    @objc func journalWasTapped(nc: Notification) -> Void {
        presentJournalFormModal()
    }
    
    @objc func startShiftWasTapped(nc: Notification) -> Void {
        startShiftTapped() 
    }
    
    @objc func endShiftWasTapped(nc: Notification) -> Void {
        endShiftTapped()
    }
    
    @objc func newUserCreated(notification:Notification)-> Void {
        
    }
    
    @objc func noConnectionCalled(ns: Notification) {
        if vcLaunch.alertI == 0 {
            let alert = vcLaunch.networkUnavailable()
            self.present(alert,animated: true)
        }
    }
    
    @objc func startShiftForDash(ns: Notification)-> Void {
            
    }
    
        /// notification from cloudkit download is concluded
        /// FJkRELOADTHEDASHBOARD
        /// - Parameter ns: notification no userinfo included
        /// - Returns: removes spinner and tells Master to remove lock on buttons
    @objc func newContentForDashboard(ns: Notification)->Void {
        
        if agreementAccepted {
            entity = "FireJournalUser"
            attribute = "userGuid"
            sortAttribute = "lastName"
            startEndShift = userDefaults.bool(forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        }
            // wait two seconds to simulate some work happening
        if childAdded {
            DispatchQueue.main.async {
                    // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
                self.nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                             object: nil,
                             userInfo: nil)
            }
            childAdded = false
        }
        
        
        if !alertUp {
            var count:Int = self.userDefaults.integer(forKey: FJkALERTBACKUPCOMPLETED)
            if count == 0 {
                let title: InfoBodyText = .cloudDataSubject2
                let message: InfoBodyText = .cloudData2
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let learnMore = UIAlertAction.init(title: "Learn More", style: .default, handler: {_ in
                    self.alertUp = false
                    count = count + 1
                    if count > 20 {
                        count = 0
                    }
                    self.userDefaults.set(count, forKey: FJkALERTBACKUPCOMPLETED)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.nc.post(name:Notification.Name(rawValue:FJkSTOREINALERTTAPPED),
                                     object: nil,
                                     userInfo: nil)
                    }
                })
                alert.addAction(learnMore)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    count = count + 1
                    if count > 20 {
                        count = 0
                    }
                    self.userDefaults.set(count, forKey: FJkALERTBACKUPCOMPLETED)
                    if self.firstRun {
                        self.firstRun = false
                        
                        self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.shift.rawValue))
                        self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.status.rawValue))
                    }
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
        //    MARK: -WEATHER NOTIFICATION
        /// notification to get weather for weather cell on FJkWEATHERHASBEENUPDATED
        /// - Parameter ns: userinfo includes temp, humidity, windspeed and direction
    @objc func updateWeatherInfo(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            weatherTemperature = userInfo[FJkTEMPERATURE] as? String ?? ""
            weatherHumidity = userInfo[FJkHUMIDITY] as? String ?? ""
            weatherWindSpeed = userInfo[FJkWINDSPEEDDIRECTION] as? String ?? ""
            
            dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.weather.rawValue))
        }
    }
    
    @objc func versionControlYouShouldChange(ns: Notification ) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            let version = userInfo["versionControl"] as? Bool ?? false
            if version {
                if !alertUp {
                    let title: InfoBodyText = .versionChangeSubject
                    let message: InfoBodyText = .versionChange
                    let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Get It", style: .default, handler: {_ in
                        self.alertUp = false
                        self.openStoreProductWithiTunesItemIdentifier(identifier: "587192813")
                    })
                    alert.addAction(okAction)
                    let dismissAction = UIAlertAction.init(title: "Dismiss", style: .default, handler: {_ in
                        self.alertUp = false
                    })
                    alert.addAction(dismissAction)
                    alertUp = true
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func openStoreProductWithiTunesItemIdentifier(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                    // Parent class of self is UIViewContorller
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    
}

extension DetailViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailViewController: PersonalNewEntryModalTVCDelegate {
    
    func dismissPJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func personalJournalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailViewController: ModalTVCDelegate {
    
    func saveBTapped(shift: MenuItems) {}
    func journalSaved(id: NSManagedObjectID, shift: MenuItems) {}
    func incidentSave(id: NSManagedObjectID, shift: MenuItems) {}
    
    func dismissTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func formTypedTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
        switch shift {
        case .ics214:
            let int = theCount(entity: "ICS214Form")
            if int != 0 {
                let objectID = fetchTheLatest(shift: shift)
                nc.post(name:Notification.Name(rawValue: FJkICS214_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID, "shift": shift])
            } else {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let vc: NewICS214ModalTVC = vcLaunch.modalICS214NewCalled()
                vc.title = "New ICS 214"
                vc.delegate = self
                vc.transitioningDelegate = slideInTransitioningDelgate
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        case .arcForm:
            let int = theCount(entity: "ARCrossForm")
            if int != 0 {
                let objectID = fetchTheLatest(shift: shift)
                nc.post(name:Notification.Name(rawValue:FJkARCFORM_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID, "shift": shift])
            } else {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let vc:ARC_ViewController = vcLaunch.modalARCFormNewCalled()
                vc.title = "New ARC Form"
                vc.transitioningDelegate = slideInTransitioningDelgate
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    func theCount(entity: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("DashboardVC line 1391 Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func fetchTheLatest(shift: MenuItems)->NSManagedObjectID {
        var objectID:NSManagedObjectID!
        switch shift {
        case .ics214:
            var ics214 = [ICS214Form]()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            let sort = NSSortDescriptor(key: "ics214FromTime", ascending: true)
            request.sortDescriptors = [sort]
            do {
                ics214 = try context.fetch(request) as! [ICS214Form]
                let form = ics214.last
                objectID = form?.objectID
            }  catch let error as NSError {
                let nserror = error
                let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
                print("there were zero ICS214 Forms available \(errorMessage)")
            }
        case .arcForm:
            var arcForm = [ARCrossForm]()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
            let sort = NSSortDescriptor(key: "arcCreationDate", ascending: true)
            request.sortDescriptors = [sort]
            do {
                arcForm = try context.fetch(request) as! [ARCrossForm]
                if !arcForm.isEmpty {
                    let form = arcForm.last
                    objectID = form?.objectID
                } else {
                    
                }
            } catch let error as NSError {
                print("DashboardVC line 1475 Error: \(error.localizedDescription)")
            }
        default: break
        }
        return objectID
    }
    
}

extension DetailViewController: NewICS214ModalTVCDelegate {
    
    func theCancelCalledOnNewICS214Modal() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
