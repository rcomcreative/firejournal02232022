//
//  ICS214NewIncidentVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/5/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

protocol ICS214NewIncidentVCDelegate: AnyObject {
    func ics214IncidentNewCancelled()
    func ics214IncidentNewSaved(objectID: NSManagedObjectID)
}

class ICS214NewIncidentVC: UIViewController {
    
    lazy var getUserLocation: GetTheUserLocation = { return GetTheUserLocation.init() }()
    var theUserRegion: MKCoordinateRegion?
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var userTimeObjectID: NSManagedObjectID!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    weak var delegate: ICS214NewIncidentVCDelegate? = nil
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var theUserTime: UserTime!
    var theUser: FireJournalUser!
    var theIncident: Incident!
    var theIncidentLocation: FCLocation!
    var theIncidentTime: IncidentTimer!
    var theIncidentAddress: IncidentAddress!
    var theIncidentLocal: IncidentLocal!
    var theIncidentNFIRS: IncidentNFIRS!
    var theIncidentNotes: IncidentNotes!
    var theIncidentTags: IncidentTags!
    var theActionsTaken: ActionsTaken!
    var theIncidentNFIRSCompleteMods: IncidentNFIRSCompleteMods!
    var theIncidentNFIRSKSec: IncidentNFIRSKSec!
    var theIncidentNFIRSRequiredModules: IncidentNFIRSRequiredModules!
    var theIncidentNFIRSsecL: IncidentNFIRSsecL!
    var theIncidentNFIRSsecM: IncidentNFIRSsecM!
    var thePhoto: Photo!
    var theJournal: Journal!
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
New Incident
"""
    var incidentModalHeaderV: ModalHeaderSaveDismiss!
    var incidentTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .fire

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        nc.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if userTimeObjectID != nil {
            theUserTime = context.object(with: userTimeObjectID) as? UserTime
            if theUserTime.fireJournalUser != nil {
                theUser = theUserTime.fireJournalUser
            } else {
                getTheUser()
                if theUser == nil {
                    dismiss(animated: true, completion: nil)
                }
            }
            roundViews()
            getUserLocation.determineLocation()
            buildTheIncident()
            configureModalHeaderSaveDismiss()
            configureIncidentTableView()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
        
        

    }
    

}
