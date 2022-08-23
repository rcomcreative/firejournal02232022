    //
    //  ListTVC+ConfigureExtensions.swift
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
    
    func getTheStatus() {
        statusContext = statusProvider.persistentContainer.newBackgroundContext()
        if let status = statusProvider.getTheStatus(context: statusContext) {
            let aStatus = status.last
            if let id = aStatus?.objectID {
                theStatus = context.object(with: id) as? Status
            }
        }
    }
    
    func getTheLastUserTime(guid: String) {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        if let userTime = userTimeProvider.getTheShift(userTimeContext, guid)  {
            let uTime = userTime.last
            if let id = uTime?.objectID {
                theUserTime  = context.object(with: id) as? UserTime
            }
        }
    }
    
    func getTheFireJournalUser() {
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
    
    func configureNavigationBar() {
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        let navigationBarAppearance = UINavigationBar.appearance()
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        self.splitViewController?.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(loadMenuUp(_:)))
    }
    
    func configureHomeButtonNavigation() {
        switch myShift {
        case .ics214:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewICS214Entry(_:)))
        case .arcForm:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewARCFormEntry(_:)))
        case .incidents:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewIncidentEntry(_:)))
        case .journal:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewJournalModalEntry(_:)))
        case .personal:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPersonalNewEntryModal(_:)))
        case .projects:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewProject(_:)))
        default:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewJournalModalEntry(_:)))
        }
    }
    
    func configureData() {
        switch myShift {
        case .journal:
            entity = "Journal"
            attribute = "journalDateSearch"
        case .incidents, .maps:
            entity = "Incident"
            attribute = "incidentSearchDate"
        case .personal:
            entity = "Journal"
            attribute = "journalDateSearch"
        case .arcForm:
            entity = "ARCrossForm"
            attribute = "arcFormGuid"
        case .ics214:
            entity = "ICS214Form"
            attribute = "ics214Guid"
        default:
            print("nothing to see here")
        }
        getTheUser()
        _ = getTheDataForTheList()
    }
    
    private func getTheUser() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            self.fju = self.fetched.last as? FireJournalUser
            fjuStreetNumber = fju.fireStationStreetNumber ?? ""
            fjuStreetName = fju.fireStationStreetName ?? ""
            fjuCity = fju.fireStationCity ?? ""
            fjuState = fju.fireStationState ?? ""
            fjuZip = fju.fireStationZipCode ?? ""
            
        } catch let error as NSError {
            print("ListTVC line 681 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func loadMenuUp(_ sender: Any) {
        if (Device.IS_IPHONE){
            delegate?.menuWasTapped()
        } else if(Device.IS_IPAD) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller:MasterViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as! MasterViewController
            let navigator = UINavigationController.init(rootViewController: controller)
            self.splitVC?.show(navigator, sender: self)
            let shift: MenuItems = .myShift
            controller.myShiftCellTapped(myShift: shift)
        }
    }
    
    @IBAction func addNewARCFormEntry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "ARC_FormMain", bundle:nil)
        if let newARC_FormMainVC = storyBoard.instantiateViewController(withIdentifier: "NewARC_FormMainVC") as? NewARC_FormMainVC {
            newARC_FormMainVC.delegate = self
            newARC_FormMainVC.transitioningDelegate = slideInTransitioningDelgate
            if Device.IS_IPHONE {
                newARC_FormMainVC.modalPresentationStyle = .formSheet
            } else {
                newARC_FormMainVC.modalPresentationStyle = .custom
            }
            if theUserTime != nil {
                newARC_FormMainVC.userTimeOID = theUserTime.objectID
            }
            if theFireJournalUser != nil {
                newARC_FormMainVC.userOID = theFireJournalUser.objectID
            } else {
                
            }
            self.present(newARC_FormMainVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func addNewICS214Entry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "ICS214NewMasterAddiitionalForm", bundle:nil)
        if let ics214NewMasterAddiitionalFormVC = storyBoard.instantiateViewController(withIdentifier: "ICS214NewMasterAddiitionalFormVC") as? ICS214NewMasterAddiitionalFormVC {
            ics214NewMasterAddiitionalFormVC.transitioningDelegate = slideInTransitioningDelgate
            if Device.IS_IPHONE {
                ics214NewMasterAddiitionalFormVC.modalPresentationStyle = .formSheet
            } else {
                ics214NewMasterAddiitionalFormVC.modalPresentationStyle = .custom
            }
            if theUserTime != nil {
                ics214NewMasterAddiitionalFormVC.theUserTimeOID = theUserTime.objectID
            }
            if theFireJournalUser != nil {
                ics214NewMasterAddiitionalFormVC.theUserOID = theFireJournalUser.objectID
            }
            ics214NewMasterAddiitionalFormVC.delegate = self
            self.present(ics214NewMasterAddiitionalFormVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func addNewIncidentEntry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "IncidentNew", bundle:nil)
        let incidentNewModalVC = storyBoard.instantiateViewController(withIdentifier: "IncidentNewModalVC") as! IncidentNewModalVC
        incidentNewModalVC.transitioningDelegate = slideInTransitioningDelgate
        if theUserTimeOID != nil {
            incidentNewModalVC.userTimeObjectID = theUserTimeOID
        }
        if Device.IS_IPHONE {
            incidentNewModalVC.modalPresentationStyle = .formSheet
        } else {
            incidentNewModalVC.modalPresentationStyle = .custom
        }
        incidentNewModalVC.delegate = self
        self.present(incidentNewModalVC, animated: true, completion: nil)
    }
    
    @IBAction func addNewPersonalNewEntryModal(_ sender: Any) {
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
    
    @objc func addNewProject(_ sender: Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "NewPromotion", bundle:nil)
        let promotionNewModalVC = storyBoard.instantiateInitialViewController() as! NewPromotionVC
        promotionNewModalVC.transitioningDelegate = slideInTransitioningDelgate
        if theUserTime != nil {
            promotionNewModalVC.userTimeObjectID = theUserTime.objectID
            if Device.IS_IPHONE {
                promotionNewModalVC.modalPresentationStyle = .formSheet
            } else {
                promotionNewModalVC.modalPresentationStyle = .custom
            }
            promotionNewModalVC.delegate = self
            self.present(promotionNewModalVC,animated: true)
        } else {
            let errorMessage = "A shift needs to be started to create journal entries."
            errorAlert(errorMessage: errorMessage)
        }
    }
    
    @IBAction func addNewJournalModalEntry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "JournalNewModal", bundle:nil)
        let journalNewModalVC = storyBoard.instantiateInitialViewController() as! JournalNewModalVC
        journalNewModalVC.transitioningDelegate = slideInTransitioningDelgate
        if theUserTime != nil {
            journalNewModalVC.userTimeObjectID = theUserTime.objectID
            if Device.IS_IPHONE {
                journalNewModalVC.modalPresentationStyle = .formSheet
            } else {
                journalNewModalVC.modalPresentationStyle = .custom
            }
            journalNewModalVC.delegate = self
            self.present(journalNewModalVC,animated: true)
        } else {
            let errorMessage = "A shift needs to be started to create journal entries."
            errorAlert(errorMessage: errorMessage)
        }
    }
    
    @IBAction func addNewJournalEntry(_ sender:Any) {
        var title = ""
        switch myShift {
        case .journal:
            title = "New Journal Entry"
        case .incidents,.maps:
            title = "New Incident Entry"
        case .personal:
            title = "New Personal Entry"
        default:
            print("no shift")
        }
        let vc:ModalTVC = vcLaunch.presentModal(menuType: myShift, title: title)
        switch myShift {
        case .personal:
            let shift:MenuItems = .personal
            vc.myShift = shift
        case .journal:
            let shift:MenuItems = .journal
            vc.myShift = shift
        case .incidents, .maps:
            let shift:MenuItems = .incidents
            vc.myShift = shift
        default:
            print("no data")
        }
        vc.delegate = self
        vc.context = context
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ListTVC: NewARC_FormMainVCDelegate {
    
    func theCampaignButtonTapped(userTimeOID: NSManagedObjectID, userOID: NSManagedObjectID) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Campaign", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "CampaignTVC") as! CampaignTVC
        controller.delegate = self
        
        controller.userOID = userOID
        controller.userTimeOID = userTimeOID
        
        controller.transitioningDelegate = slideInTransitioningDelgate
        if Device.IS_IPHONE {
            controller.modalPresentationStyle = .formSheet
        } else {
            controller.modalPresentationStyle = .custom
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func theSingleFormButtonTapped(userTimeOID: NSManagedObjectID, userOID: NSManagedObjectID) {
        let storyboard = UIStoryboard(name: "Form", bundle: nil)
        let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        
        controller.userOID = userOID
        controller.userTimeOID = userTimeOID
        
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.delegate = self
        if Device.IS_IPHONE {
            controller.modalPresentationStyle = .formSheet
            self.present(navigator, animated: true, completion: nil)
        } else {
            self.splitVC?.showDetailViewController(navigator, sender:self)
        }
    }
    
    
}

extension ListTVC: ICS214NewMasterAddiitionalFormVCDelegate {
    
    func newMasterAdditionalFormCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func newMasterAdditionalFormSaved(_ newICS214FormOID: NSManagedObjectID) {
        self.dismiss(animated: true, completion: nil)
        if theUserTime != nil {
            let theUserTimeID = theUserTime.objectID
            if theFireJournalUser != nil {
                let userID = theFireJournalUser.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkICS214_FROM_MASTER),
                             object: nil,
                             userInfo: ["objectID": newICS214FormOID, "shift": MenuItems.ics214, "theUserTimeID": theUserTimeID, "theUserID": userID])
            }
            }
        }
        self.tableView.reloadData()
    }
    
    
}

extension ListTVC: CampaignDelegate {
    
    func theCampaignHasBegun() {
        
    }
    
    
}



extension ListTVC: NSFetchedResultsControllerDelegate {
    
        //    MARK: -NSFetch
    
    
    func getTheDataForTheList() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fresh = userDefaults.bool(forKey: FJkCHANGESINFROMCLOUD)
        if fresh {
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
            userDefaults.set(false, forKey: FJkCHANGESINFROMCLOUD)
            userDefaults.synchronize()
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        switch myShift {
        case .journal:
                //            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicate2 = NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value:true))
            let predicate5 = NSPredicate(format: "%K == %@ || %K == %@ || %K == %@ || %K == %@","journalEntryType","Station","journalEntryType","Community","journalEntryType","Members","journalEntryType","Training")
            let predicate3 = NSPredicate(format: "%K != %@", "journalEntryTypeImageName","NOTJournal")
            let predicate4 = NSPredicate(format: "%K != %@","journalEntryTypeImageName","ICONS_BBLUELOCK")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate2,predicate3,predicate4,predicate5])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "journalModDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            print("nothing")
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Journal")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .incidents:
            let predicate = NSPredicate(format: "%K != nil", attribute)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .projects:
            let predicate = NSPredicate(format: "%K != nil",attribute)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "promotionDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .maps:
            
            let predicate = NSPredicate(format: "%K != nil", attribute)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            switch myShiftTwo {
            case .incidents:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-All-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .fire:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateOne = NSPredicate(format: "%K = %@", "situationIncidentImage", "Fire")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicateOne])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-Fire-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .ems:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateOne = NSPredicate(format: "%K = %@", "situationIncidentImage", "EMS")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicateOne])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-EMS-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .rescue:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateOne = NSPredicate(format: "%K = %@", "situationIncidentImage", "Rescue")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicateOne])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-RESCUE-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .ics214:
                let predicate = NSPredicate(format: "%K != %@", "ics214Guid", "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ICS214-MAP")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .arcForm:
                let predicate = NSPredicate(format: "%K != %@", "arcFormGuid", "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ARCForm-MAP")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            default:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-All-Default-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            }
        case .personal:
            let predicate1 = NSPredicate(format: "journalPrivate == %@", NSNumber(value: false))
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 50
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Personal")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .ics214:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ICS214")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .arcForm:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ARCForm")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        default:
            print("noting")
        }
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            let nserror = error
            let errorMessage = "ListTVC getTheDataForTheList() Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.insertSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
        case .delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.deleteSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case NSFetchedResultsChangeType.insert:
            print("NSFetchedResultsChangeType.insert detected")
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
                    //                saveToCD()
            }
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
        case NSFetchedResultsChangeType.update:
            print("NSFetchedResultsChangeType.update detected")
            if let indexPath = indexPath, let _ = tableView.cellForRow(at: indexPath) {
                _ = configureCell(at: indexPath)
                    //                saveToCD()
            }
        case NSFetchedResultsChangeType.move:
            print("NSFetchedResultsChangeType.Move detected")
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
            
                // Note that for Move, we insert a row at the __newIndexPath__
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: UITableView.RowAnimation.fade)
            }
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
}
