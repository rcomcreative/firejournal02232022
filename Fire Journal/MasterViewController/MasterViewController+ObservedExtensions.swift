//
//  MasterViewController+ObservedExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import StoreKit

extension MasterViewController {

        //  MARK: -OBSERVERS-
    func addObserversForMaster() {
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector: #selector(listOfJournalCalled(ns:)), name:NSNotification.Name(rawValue: FJkJOURNALLISTSEGUE), object: nil)
        nc.addObserver(self, selector: #selector(listOfProjectsCalled(ns:)), name: .fireJournalProjectListCalled , object: nil)
        nc.addObserver(self, selector: #selector(incidentListCalled(ns:)), name:NSNotification.Name(rawValue: FJkINCIDENTLISTCALLED), object: nil)
        nc.addObserver(self, selector: #selector(mapListCalled(ns:)), name:NSNotification.Name(rawValue: FJkMAPSLISTCALLED), object: nil)
        nc.addObserver(self, selector: #selector(listOfPersonalCalled(ns:)), name:NSNotification.Name(rawValue: FJkPERSONALLISTCALLED), object: nil)
        nc.addObserver(self, selector: #selector(ics214ListCalled(ns:)), name:NSNotification.Name(rawValue: FJkICS214FORMLISTCALLED), object: nil)
        nc.addObserver(self, selector: #selector(arcFormListCalled(ns:)), name:NSNotification.Name(rawValue: FJkARCFORMLISTCALLED), object: nil)
        nc.addObserver(self, selector: #selector(openingNeededOnMaster(ns:)), name:NSNotification.Name(rawValue: FJkUserAgreementAgreed), object: nil)
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector:#selector(myProfileCalled(ns:)),name:NSNotification.Name(rawValue: FJkPROFILE_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(myFreshDeskUpdated(ns:)),name:NSNotification.Name(rawValue: FJkFRESHDESK_UPDATED), object: nil)
        nc.addObserver(self, selector:#selector(storeTappedInAlert(ns:)),name:NSNotification.Name(rawValue: FJkSTOREINALERTTAPPED), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(lockdownButtons(ns:)), name: NSNotification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD), object: nil)
        if Device.IS_IPHONE {
            nc.addObserver(self, selector: #selector(changeTheLocationsToSC(ns:)), name: NSNotification.Name(rawValue: FJkChangeTheLocationsTOLOCATIONSSC), object: nil)
            nc.addObserver(self, selector: #selector(saveStatusToCloud(ns:)), name: .fireJournalStatusNewToCloud, object: nil)
        }
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.managedObjectContext?.mergeChanges(fromContextDidSave: notification)
        }
    }
    
//    MARK: -STATUS SAVE-
    @objc func saveStatusToCloud(ns:Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            if let objectID = userInfo["objectID"] as? NSManagedObjectID {
                DispatchQueue.global().async {
                    self.statusContext = self.statusProvider.persistentContainer.viewContext
                    self.statusProvider.createStatusCKRecord(self.statusContext, objectID) { status in
                        print("status has been updated in the cloud \(status)")
                    }
                }
            }
        }
    }
    
        // MARK: -NC OBSERVERS-
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
    
    @objc func masterReloadDetail(ns: Notification)->Void {
        if Device.IS_IPAD {
            let segue = "showDetail"
            shiftMine = .myShift
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc func newContentForDashboard(ns: Notification)->Void {
        
        if Device.IS_IPHONE {
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
                            if self.firstRun {
                                self.fdResourcesPointOfTruthFirstTime()
                                self.firstRun = false
                            }
                                //                        self.processCollectionViewAfterDownload()
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
                                //                        self.fdResourcesPointOfTruthFirstTime()
                            self.firstRun = false
                        }
                            //                    self.processCollectionViewAfterDownload()
                    })
                    alert.addAction(okAction)
                    alertUp = true
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func myProfileCalled(ns: Notification) {
        var id: NSManagedObjectID!
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            if let objectID = userInfo["userObjID"] as? NSManagedObjectID {
                id = objectID
            }
        }
        let vc: SettingsTheProfileTVC = vcLaunch.myProfileCalled(compact: compact)
        vc.delegate = self
        vc.titleName = ""
        vc.compact = compact
        if id != nil {
            vc.objectID = id
        }
        let navigator = UINavigationController.init(rootViewController: vc)
        self.splitViewController?.showDetailViewController(navigator, sender:self)
    }
    
        //    MARK: -FRESHDESK
    @objc func myFreshDeskUpdated(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            if let info = userInfo["freshDesk"] as? Bool {
        if !alertUp {
            let title: InfoBodyText = .syncedWithCRMSubject
            let message: InfoBodyText = .syncedWithCRM
            let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Thanks for the info", style: .default, handler: {_ in
                self.alertUp = false
                let fresh = info
                DispatchQueue.main.async {
                    self.userDefaults.set(fresh, forKey: FJkFRESHDESK_UPDATED)
                }
                let userIsFromCloud = self.userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
                if userIsFromCloud {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print("Timer fired!")
                        self.goingToStartADownloadFromCloud()
                    }
                } else {
                    print("no longer using resources")
                }
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            alertUp = true
        }
            }
        }
    }
    
    @objc func lockdownButtons(ns: Notification) {
        lockDown.toggle()
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
    
    @objc func journalListCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        switch myShiftForSegue {
        case .journal:
            controller.titleName = "Journal"
            let shift:MenuItems = .journal
            controller.myShift = shift
            controller.color = UIColor(named: "FJJournalBlueColor") ?? .black
            controller.entity = "Journal"
            controller.attribute = "journalModDate"
        case .maps:
            controller.titleName = "Maps"
            let shift:MenuItems = .maps
            controller.myShift = shift
            controller.color = UIColor(named: "FJRedColor") ?? .black
        case .personal:
            controller.titleName = ""
            let shift:MenuItems = .personal
            controller.myShift = shift
            controller.color = UIColor(named: "FJJournalBlueColor") ?? .black
            controller.view.backgroundColor = controller.color
        default:
            print("nada")
        }
        controller.delegate = self
        controller.splitVC = self.splitViewController
        controller.compact = compact
        self.splitViewController?.show(navigator, sender: self)
    }
    
    @objc func listOfJournalCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        controller.myShift = MenuItems.journal
        controller.delegate = self
        controller.entity = "Journal"
        controller.attribute = "journalModDate"
        controller.journalPersonal = true
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }
    
    @objc func listOfProjectsCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        controller.myShift = MenuItems.projects
        controller.delegate = self
        controller.entity = "PromotionJournal"
        controller.attribute = "promotionDate"
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }
    
    
    
    @objc func listOfPersonalCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        controller.myShift = MenuItems.personal
        controller.delegate = self
        controller.entity = "Journal"
        controller.attribute = "journalModDate"
        controller.journalPersonal = false
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }
    
    @objc func incidentListCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        let shift:MenuItems = .incidents
        controller.myShift = shift
        controller.entity = "Incident"
        controller.attribute = "incidentSearchDate"
        controller.delegate = self
        controller.titleName = "Incident"
        controller.color = UIColor(named: "FJRedColor") ?? .black
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }
    
    @objc func mapListCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        let shift:MenuItems = .maps
        controller.myShift = shift
        controller.entity = "Incident"
        controller.attribute = "incidentSearchDate"
        controller.delegate = self
        controller.titleName = "Incident"
        controller.color = UIColor(named: "FJRedColor") ?? .black
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }

    @objc func arcFormListCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        let shift:MenuItems = .arcForm
        controller.myShift = shift
        controller.entity = "ARCrossForm"
        controller.attribute = "arcFormGuid"
        controller.delegate = self
        controller.titleName = ""
        controller.color = UIColor(named: "FJRedColor") ?? .black
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }

    @objc func ics214ListCalled(ns: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:ListTVC = storyboard.instantiateViewController(withIdentifier: "ListTVC") as! ListTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        controller.compact = compact
        let shift:MenuItems = .ics214
        controller.myShift = shift
        controller.entity = "ICS214Form"
        controller.attribute = "ics214Guid"
        controller.delegate = self
        controller.titleName = "ICS 214"
        controller.color = UIColor(named: "FJRedColor") ?? .black
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }
    
    @objc func openingNeededOnMaster(ns:Notification) -> Void {
        if Device.IS_IPHONE {
            DispatchQueue.main.async {
                self.plistContext = self.plistProvider.persistentContainer.newBackgroundContext()
                let loadTheUserFromCloud = LoadTheUserFromCloud(context: self.plistContext)
                loadTheUserFromCloud.getCloudUser()
            }
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let openingScrollVC = storyBoard.instantiateViewController(withIdentifier: "OpenModalScrollVC") as! OpenModalScrollVC
            openingScrollVC.delegate = self
            openingScrollVC.fromMaster = true
            openingScrollVC.transitioningDelegate = slideInTransitioningDelgate
            openingScrollVC.modalPresentationStyle = .custom
            self.present(openingScrollVC, animated: true, completion: nil)
        }
    }
    
    @objc func noConnectionCalled(ns: Notification) {
        if vcLaunch.alertI == 0 {
            let alert = vcLaunch.networkUnavailable()
            self.present(alert,animated: true)
        }
    }
    
        //    MARK: -STORE IN ALERT TAPPED
    @objc func storeTappedInAlert(ns: Notification) {
        print("Store")
        switch compact {
        case .compact:
            let available = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
            if available {
                vcLaunch.storeCalled()
            } else {
                self.dismiss(animated: true, completion: nil)
                let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
                self.present(alert,animated: true)
            }
        case .regular:
            let available = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
            if available {
                nc.post(name:Notification.Name(rawValue:FJkSTORE_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID":"", "date":"","arcFormGuid":""])
            } else {
                self.dismiss(animated: true, completion: nil)
                let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
                self.present(alert,animated: true)
            }
        }
    }
    
    @objc func changeTheLocationsToSC(ns: Notification) {
        
        if agreementAccepted {
            if Device.IS_IPHONE {
                locationMovedToLocationsSC = userDefaults.bool(forKey: FJkMoveTheLocationsToLocationsSC)
                
                if !locationMovedToLocationsSC {
                        ///notify cloudkitmanager need to run operation
                        ///FJkNEXTLOCATIONUPDATE
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:(FJkNEXTLOCATIONUPDATE)), object: nil, userInfo: ["MenuItems": MenuItems.arcForm])
                    }
                        ///listen for completion remove spinner
                    nc.addObserver(self,selector: #selector(removeSpinnerUpdate(ns:)),name:NSNotification.Name(rawValue: FJkLocationsAllUpdatedToSC), object:nil)
                        ///spinner alert
                    updateLocationDataToSC()
                }
            }
        }
    }
    
    @objc func removeSpinnerUpdate(ns: Notification) {
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
    }
    
    private func updateLocationDataToSC() {
        if !alertUp {
            let title: InfoBodyText = .updateLocationSubject
            let message: InfoBodyText = .updateLocationMessage
            let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
