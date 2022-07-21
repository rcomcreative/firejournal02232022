    //
    //  MasterViewController.swift
    //  dashboard
    //
    //  Created by DuRand Jones on 7/12/18.
    //  Copyright © 2018 PureCommand LLC. All rights reserved.
    //

import UIKit
import CoreData
import StoreKit

class MasterViewController: UITableViewController,UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate{
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var shiftMine: MenuItems = .journal
    var startEndGuid = ""
    let horizontalClass: NSInteger = UIScreen.main.traitCollection.horizontalSizeClass.rawValue
    let verticalClass: NSInteger = UIScreen.main.traitCollection.verticalSizeClass.rawValue;
    let nc = NotificationCenter.default
    var compact: SizeTrait = .regular
    
    let vcLaunch = VCLaunch()
    var launchNC: LaunchNotifications!
    
    let segue = "ShowJournalSegue"
    var myShiftForSegue: MenuItems = .journal
    var myShiftTitle = ""
    var device:Device!
        //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let userDefaults = UserDefaults.standard
    var agreementAccepted:Bool = false
    var firstTimeAgreementAccepted: Bool = false
    var journalEmpty: Bool = false
    
        //    let pendingOperations = PendingOperations()
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    var fetched:Array<Any>!
    var plistsLoaded: Bool = false
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var startEndShift: Bool = false
    var alertUp:Bool = false
    var lockDown: Bool = false
    var firstRun: Bool = true
    var child: SpinnerViewController!
    var childAdded: Bool = false
    var versionControlled: Bool = false
    var subscriptionIsLocallyCached: Bool = false
    var myShift: MenuItems = .journal
    var locationMovedToLocationsSC: Bool = false
    
    lazy var plistProvider: PlistProvider = {
        let provider = PlistProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var plistContext: NSManagedObjectContext!
    
    lazy var statusProvider: StatusProvider = {
        let provider = StatusProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var statusContext: NSManagedObjectContext!
    var theStatusA = [Status]()
    
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    
    var theUserContext: NSManagedObjectContext!
    var theUser: FireJournalUser!
    var theUserObjectID: NSManagedObjectID!
    var theUserTime: UserTime!
    var theUserTimeObjectID: NSManagedObjectID!
    var theStatus: Status!
    var cloudKitAndCoreDataDeleted: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        if let split = splitViewController {
            self.splitViewController?.delegate = self
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            vcLaunch.splitVC = self.splitViewController
        }
        
        self.title = ""
        device = Device.init()
        subscriptionIsLocallyCached = userDefaults.bool(forKey: FJkSUBSCRIPTIONIsLocallyCached)
        
        registerCells()
        
        addObserversForMaster()
        
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        if !agreementAccepted {
            DispatchQueue.main.async {
                self.nc.post(name: NSNotification.Name(rawValue: FJkUserAgreementAgreed), object: nil, userInfo:nil)
            }
        } else {
            if theUser == nil {
                getTheUser()
                getTheStatus()
            }
        }
        
        nc.addObserver(self, selector: #selector(newContentForDashboard(ns:)),name:NSNotification.Name(rawValue: FJkRELOADTHEDASHBOARD), object: nil)
        
        nc.addObserver(self, selector:#selector(masterReloadDetail(ns:)),name:NSNotification.Name(rawValue: FJkMASTERRELOADDETAIL), object: nil)
        
        if Device.IS_IPHONE {
            
            
            if agreementAccepted {
                
                nc.addObserver(self,selector: #selector(versionControlYouShouldChange(ns:)),name:NSNotification.Name(rawValue: FJkVERSIONCONTROL), object:nil)
                
                versionControlled = userDefaults.bool(forKey: FJkVERSIONCONTROL)
                if versionControlled {} else {
                    nc.addObserver(self,selector: #selector(versionControlYouShouldChange(ns:)),name:NSNotification.Name(rawValue: FJkVERSIONCONTROL), object:nil)
                    userDefaults.set(true, forKey: FJkVERSIONCONTROL)
                    userDefaults.synchronize()
                }
                
                
                self.nc.post(name:Notification.Name(rawValue:(FJkChangeTheLocationsTOLOCATIONSSC)), object: nil, userInfo: nil)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
            //        let backgroundColor = UIColor(red:0.89, green:0.90, blue:0.93, alpha:1.00)
        self.tableView.backgroundColor = .clear
        
        var floatPercent = 1.00
            // MARK: -COMPACT/REGULAR TRAIT
        if (self.view.traitCollection.horizontalSizeClass == .compact) {
            floatPercent = 0.1028
            compact = .compact
            nc.post(name:Notification.Name(rawValue: FJkCOMPACTORREGULAR),
                    object: nil,
                    userInfo: ["compact":compact])
        } else {
            floatPercent = 0.1338
            compact = .regular
            nc.post(name:Notification.Name(rawValue: FJkCOMPACTORREGULAR),
                    object: nil,
                    userInfo: ["compact":compact])
        }
            //        print(floatPercent)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Device.IS_IPHONE {
            let minminWidth = CGFloat((splitViewController?.view.bounds.width)!/4)
            splitViewController?.minimumPrimaryColumnWidth = minminWidth
            splitViewController?.maximumPrimaryColumnWidth = minminWidth
            splitViewController?.preferredPrimaryColumnWidthFraction = 0.3
            
            clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        }
        let collaped = self.splitViewController?.isCollapsed
        print("Settings here is collapsed \(String(describing: collaped))")
        userDefaults.set(collaped, forKey: FJkFJISCOLLAPSED)
    }
    
        //    MARK: -ALERTS-
    
    func deletionFromOtherDeviceCalledAlert(count: Int) {
        let alert = UIAlertController.init(title: "Deletion", message: "It is indicated that you deleted your data from your other device and from your ICloud account. Do you want to delete your cached data from this device?", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Yes", style: .default, handler: {_ in
            self.alertUp = false
            self.shouldRunDeletionOfCoreData()
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(cancelAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
        //    MARK: -ALERTS-
        //    MARK: -REMOVE DATA
        /**Data has been removed
         
    observe fConCDSuccess
    show alert
    post to fConCKCDDeletionCompleted
    move to agreement
         */
    func completionAlert(_ message: String) {
        let alert = UIAlertController.init(title: "Deletion Completed", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
            self.moveToAgreement()
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func moveToAgreement() {
        DispatchQueue.main.async {
            self.nc.post(name: .fConCKCDDeletionCompleted,
                         object: nil,
                         userInfo: nil )
        }
    }
    
    func shouldRunDeletionOfCoreData() {
        DispatchQueue.main.async {
            self.nc.post(name: .fireJournalRemoveAllDataFromCD, object: nil)
        }
    }
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
