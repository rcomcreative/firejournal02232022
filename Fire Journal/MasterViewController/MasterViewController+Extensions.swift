//
//  MasterViewController+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//
import UIKit
import CoreData
import StoreKit

extension MasterViewController {
    
    func theAgreementsAccepted() {
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        if theUser == nil {
            getTheUser()
        }
        if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
            startEndGuid = guid
        }
    }
    
    func freshDeskRequest() {
        let fresh = self.userDefaults.bool(forKey: FJkFRESHDESK_UPDATED)
        DispatchQueue.main.async {
            if !fresh {
                let title: InfoBodyText = .syncWithCRMSubject
                let message: InfoBodyText = .syncWithCRM
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                var userIsFromCloud: Bool = false
                let okAction = UIAlertAction.init(title: "Yes Thank you", style: .default, handler: {_ in
                    self.alertUp = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkFRESHDESK_UPDATENow), object: nil, userInfo: nil)
                        userIsFromCloud = self.userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
                        if userIsFromCloud {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print("Timer fired!")
                                self.goingToStartADownloadFromCloud()
                            }
                        } else {
                            self.buildUsersFDResourcesAfterAgreement()
                        }
                    }
                })
                alert.addAction(okAction)
                let noAction = UIAlertAction.init(title: "No Thanks", style: .default, handler: {_ in
                    self.alertUp = false
                    let fresh = false
                    DispatchQueue.main.async {
                        self.userDefaults.set(fresh, forKey: FJkFRESHDESK_UPDATED)
                        self.userDefaults.synchronize()
                        userIsFromCloud = self.userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
                        if userIsFromCloud {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print("Timer fired!")
                                self.goingToStartADownloadFromCloud()
                            }
                        } else {
                            self.buildUsersFDResourcesAfterAgreement()
                        }
                    }
                })
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                self.alertUp = true
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
    
        //    MARK: -BUILD USERS FDRESOURCES-
    private func buildUsersFDResourcesAfterAgreement() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "OpenFDResources", bundle: nil)
        let openFDREsourcesTVC  = storyboard.instantiateViewController(identifier: "OpenFDResourcesTVC") as! OpenFDResourcesTVC
        openFDREsourcesTVC.titleName = "Fire/EMS Resources"
        openFDREsourcesTVC.settingType = FJSettings.resources
        openFDREsourcesTVC.firstRun = true
        openFDREsourcesTVC.delegate = self
        openFDREsourcesTVC.transitioningDelegate = slideInTransitioningDelgate
        openFDREsourcesTVC.modalPresentationStyle = .custom
        self.present(openFDREsourcesTVC, animated: true, completion: nil)
    }
    
    private func goingToStartADownloadFromCloud() {
        if Device.IS_IPHONE {
            if !alertUp {
                let count:Int = self.userDefaults.integer(forKey: FJkALERTBACKUPCOMPLETED)
                if count == 0 {
                    let title: InfoBodyText = .cloudDataSubject
                    let message: InfoBodyText = .cloudData
                    let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                        self.alertUp = false
                        self.createSpinnerView()
                        
                            //                    FJkLOCKMASTERDOWNFORDOWNLOAD
                    })
                    alert.addAction(okAction)
                    alertUp = true
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func createSpinnerView() {
        child = SpinnerViewController()
        childAdded = true
            // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                object: nil,
                userInfo: nil)
    }
    
    
    func saveToCD(guid: String) {
        do {
            try managedObjectContext?.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"MasterViewController merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSaved(guid: guid)
                self.nc.post(name: NSNotification.Name(rawValue: FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        }  catch let error as NSError {
            let nserror = error
            let errorMessage = "MasterTVC saveToCD()context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    func getTheLastSaved(guid:String) -> NSManagedObjectID{
        var objectID: NSManagedObjectID  = NSManagedObjectID()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@","attendeeGuid", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "attendeeGuid", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [UserAttendees]
            let attendee = self.fetched.last as! UserAttendees
            objectID = attendee.objectID
        } catch let error as NSError {
            print("IncidentPOVNotesTVC line 490 Fetch Error: \(error.localizedDescription)")
        }
        return objectID
    }
    
    func beginPlistProcess() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSIncidentType" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "incidentTypeNumber CONTAINS %@","100")
        fetchRequest.predicate = predicate
        do {
            let fetched = try context.fetch(fetchRequest) as! [NFIRSIncidentType]
            if fetched.count == 0 {
                let plistsLoad = LoadPlists.init(context)
                plistsLoad.runTheOperations()
                print("here is plistsLoaded \(plistsLoaded)")
            }
        }  catch let error as NSError {
            let errorMessage = "MasterTVC fetchRequest for plists error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
        }
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
            theUser = context.object(with: id) as? FireJournalUser
        }
    }
    
}

extension MasterViewController {
    
        // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            
            if theUser != nil {
                controller.fjuObjectID = theUser.objectID
            }
            if theUserTime != nil {
                controller.userTimeObjectID = theUserTime.objectID
            }
            if firstTimeAgreementAccepted {
                controller.startEndShift = true
                controller.firstTimeAgreementAccepted = true
                firstTimeAgreementAccepted = false
                agreementAccepted = true
                userDefaults.set(true, forKey: FJkUserAgreementAgreed)
            }
            if journalEmpty {
                DispatchQueue.main.async {
                    self.nc.post(name: .fireJournalPresentNewJournal, object: nil)
                }
                journalEmpty = false
            }
            
            switch shiftMine {
            case .incidents:
                controller.incidentModalCalled = true
            case .forms:
                controller.formModalCalled = true
            case .personal:
                controller.incidentModalCalled = false
                controller.personalModalCalled = true
            default:
                controller.formModalCalled = false
            }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "ShowJournalSegue" {
            let controller:ListTVC = segue.destination as! ListTVC
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.myShift = myShiftForSegue
            controller.delegate = self
            controller.titleName = myShiftTitle
            controller.entity = "Journal"
            controller.attribute = "journalModDate"
        } else if segue.identifier == "ShowDetailMapVCSegue" {
              
        }
    }
    
}

extension MasterViewController {
    
    func fjMembershipIsBought()-> Bool {
        var membership: Bool = false
        membership = userDefaults.bool(forKey: FJkSUBSCRIPTIONIsLocallyCached)
        return membership
    }
    
    func buyAMembership()->Void {
        if !alertUp {
            let title: InfoBodyText = .accessMembershipSubject
            let message: InfoBodyText = .accessMembership
            let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Membership", style: .default, handler: {_ in
                self.alertUp = false
                self.loadUpTheStore()
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
    
    private func loadUpTheStore() {
        myShiftCellTapped(myShift: MenuItems.store)
    }
}

extension MasterViewController {
    
        // MARK: -GETTHEDATA-
        ///    GetTheData
        /// - Parameters:
        ///        - myShift: MenuItems
        ///
        /// - Note
        ///    sets up predicates for each button type
        ///
    func getTheData(myShift:MenuItems) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        switch myShift {
        case .journal:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicate2 = NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value: true))
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .incidents:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            fetchRequest.predicate = predicate
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .personal:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicate2 = NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value: false))
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .projects:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "promotionDate", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        default:
            print("noting")
        }
        fetchRequest.fetchBatchSize = 20
        
        do {
            switch myShift {
            case .journal:
                self.fetched = try context.fetch(fetchRequest) as! [Journal]
            case .incidents:
                self.fetched = try context.fetch(fetchRequest) as! [Incident]
            case .personal:
                self.fetched = try context.fetch(fetchRequest) as! [Journal]
            case .projects:
                self.fetched = try context.fetch(fetchRequest) as! [PromotionJournal]
            default:
                print("noting to search")
            }
        } catch let error as NSError {
                // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    func theNetworkUnavailable(errorString: String)->UIAlertController {
        let title = "Internet Activity"
        let errorString = errorString
        let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Thanks", style: .default, handler: {_ in
        })
        alert.addAction(okAction)
            //        self.alertI = 1
        return alert
    }

    func getTheMapsList() {
        myShiftForSegue = MenuItems.maps
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
        controller.color = ButtonsForFJ092018.fillColor38
        controller.splitVC = self.splitViewController
        self.splitViewController?.show(navigator, sender: self)
    }

    func theCount(entity: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func theCountProject() -> Int {
        let entity = "PromotionJournal"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate1 = NSPredicate(format: "%K != %@","projectGuid", "")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
        fetchRequest.predicate = predicateCan
        print(fetchRequest)
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }

    func theCountPersonal()->Int {
        let entity = "Journal"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate1 = NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value: false))
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
        fetchRequest.predicate = predicateCan
        print(fetchRequest)
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
}

extension MasterViewController {
    
        //    MARK: -cloudOrSupport-
        //    TODO: - MOVE TO WKWebView
        ///   ALERT for firejournalcloud and crm moving to web browser
        /// - Parameters:
        ///        - supportOrCloud: String
        ///
        /// - Note
        ///    -alert controller to take user to web - checks for browser availability
        ///   - purecommand.com
        ///   - firejournalcloud.com
        ///   - crm - freshdesk.com
        ///
    func cloudOrSupport(supportOrCloud: String) {
        let supportedOrSendToCloud = supportOrCloud
        self.dismiss(animated: true, completion: nil )
        let available = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
        if available {
            if supportedOrSendToCloud == "cloud" {
                let title: InfoBodyText = .accessMembershipSubject
                let message: InfoBodyText = .accessMembership
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Proceed", style: .default, handler: {_ in
                    self.alertUp = false
                    guard let url = URL(string: "https://firejournalcloud.com") else { return }
                    UIApplication.shared.open(url)
                })
                let noAction = UIAlertAction.init(title: "Cancel", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                self.alertUp = true
            } else if supportedOrSendToCloud == "purecommand" {
                let title: InfoBodyText = .pureCommandSubject
                let message: InfoBodyText = .pureCommand
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Proceed", style: .default, handler: {_ in
                    self.alertUp = false
                    guard let url = URL(string: "http://purecommand.com") else { return }
                    UIApplication.shared.open(url)
                })
                let noAction = UIAlertAction.init(title: "Cancel", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                self.alertUp = true
            }else {
                let title: InfoBodyText = .syncWithCRMSubject2
                let message: InfoBodyText = .syncWithCRM2
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Proceed", style: .default, handler: {_ in
                    self.alertUp = false
                    guard let url = URL(string: "https://purecommand.freshdesk.com/support/home") else { return }
                    UIApplication.shared.open(url)
                })
                let noAction = UIAlertAction.init(title: "Cancel", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                self.alertUp = true
            }
        } else {
            let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
            self.present(alert,animated: true)
            self.alertUp = true
        }
    }
    
    func fdResourcesPointOfTruthFirstTime() {
        print("Running fdResourcesPointOfTruthFirstTime")
        self.nc.post(name:Notification.Name(rawValue:(FJkUSERFDRESOURCESPOINTOFTRUTH)),
                     object: nil,
                     userInfo: nil )
        self.userDefaults.set(true, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
        self.userDefaults.synchronize()
    }
    
    
}


