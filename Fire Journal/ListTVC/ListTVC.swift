    //
    //  ListTVC.swift
    //  dashboard
    //
    //  Created by DuRand Jones on 9/20/18.
    //  Copyright © 2018 PureCommand LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit


protocol ListTVCDelegate: AnyObject {
    func theJournalWasTapped()
    func menuWasTapped()
    func journalObjectChosen(type: MenuItems, id: NSManagedObjectID, compact: SizeTrait)
    func incidentTappedForMap(objectID: NSManagedObjectID, compact: SizeTrait)
}

class ListTVC: UITableViewController,UISplitViewControllerDelegate   {
    
    weak var delegate: ListTVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
        //    MARK: -FetchResultsController and delegate
        //    : used for filling the list
        //    : and for deleting the rows when edited after the delete actions are called
        //    : in the tableview delegate - editingStyle
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    var fju:FireJournalUser!
    var fjuStreetName: String = ""
    var fjuStreetNumber: String = ""
    var fjuCity: String = ""
    var fjuState: String = ""
    var fjuZip: String = ""
    
    var myShift: MenuItems = .journal
    var myShiftTwo: MenuItems = .incidents
    var titleName: String = ""
    
    let vcLaunch = VCLaunch()
    var launchNC: LaunchNotifications!
    var journalStructure: JournalData!
    var incidentStructure: IncidentData!
    var splitVC:UISplitViewController!
    var compact:SizeTrait = .regular
    let nc = NotificationCenter.default
    var device:Device!
    var color = UIColor.black
    var journalPersonal: Bool = true
    
    var objectID:NSManagedObjectID!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var ckrData:Data!
    var theEntity:String = ""
    let userDefaults = UserDefaults.standard
    var alertUp:Bool = false
    
    let dateFormatter = DateFormatter()
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    lazy var statusProvider: StatusProvider = {
        let provider = StatusProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var statusContext: NSManagedObjectContext!
    var theStatusA = [Status]()
    var theStatus: Status!
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var theUserTime: UserTime!
    var theUserTimeOID: NSManagedObjectID!
    
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    var theUserOID: NSManagedObjectID!
    var theFireJournalUser: FireJournalUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = Device.init()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        
        
        getTheStatus()
        if theStatus != nil {
            if let guid = theStatus.guidString {
                getTheLastUserTime(guid: guid)
            }
        }
        
        if theUserTimeOID != nil {
            theUserTime = context.object(with: theUserTimeOID) as? UserTime
        }
        
        getTheFireJournalUser()
        
        configureNavigationBar()
        
        configureObservers()
        
        tableView.allowsMultipleSelection = false
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        registerTheCells()
        
        if entity != "" {
            _ = getTheDataForTheList()
        }
        
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureHomeButtonNavigation()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
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
    
    
}
