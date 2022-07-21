    //
    //  JournalNewModalVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/26/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

protocol JournalNewModalVCDelegate: AnyObject {
    func journalNewCancelled()
    func journalNewSaved(objectID: NSManagedObjectID)
}

class JournalNewModalVC: UIViewController {
    
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
    
    weak var delegate: JournalNewModalVCDelegate? = nil
    
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
    var theJournalLocation: FCLocation!
    var thePhoto: Photo!
    var theJournal: Journal!
    var theTags = [Tag]()
    var theJournalTags: JournalTags!
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
New Journal
"""
    var journalModalHeaderV: ModalHeaderSaveDismiss!
    var journalTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .station
    
    var theOverviewNotes: String = " "
    var theOverviewNotesAvailable: Bool = false
    var theOverviewNotesHeight: CGFloat = 0
    
    var theDiscussionNotes: String = " "
    var theDiscussionNotesAvailable: Bool = false
    var theDiscussionNotesHeight: CGFloat = 0
    
    var theNextStepsNotes: String = " "
    var theNextStepsNotesAvailable: Bool = false
    var theNextStepsNotesHeight: CGFloat = 0
    
    var theSummaryNotes: String = " "
    var theSummaryNotesAvailable: Bool = false
    var theSummaryNotesHeight: CGFloat = 0
    
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
        
        if let obj = userTimeObjectID {
            theUserTime = context.object(with: obj) as? UserTime
        }
        if theUserTime == nil {
            delegate?.journalNewCancelled()
        }
        
        getTheUser()
        if theUser == nil {
            delegate?.journalNewCancelled()
        }
        
        roundViews()
        getUserLocation.determineLocation()
        buildTheJournal()
        configureModalHeaderSaveDismiss()
        configureJournalTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
    }
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            journalTableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        journalTableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func buildTheJournal() {
        
        theJournal = Journal(context: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDateAndTime()
        let jGuid:String = jGuidDate.formatGuid()
        theJournal.fjpJGuidForReference = "01."+jGuid
        theJournal.journalModDate = journalModDate
        theJournal.journalCreationDate = journalModDate
        theJournal.fjpJournalModifiedDate = journalModDate
        theJournal.journalDateSearch = sDate
        theJournal.fjpUserReference = theUser.userGuid
        theJournal.locationAvailable = false
        theJournal.journalTagsAvailable = false
        theJournal.journalPhotoTaken = false
        theJournal.journalGuid = UUID()
        theUser.addToFireJournalUserDetails(theJournal)
        if theUserTime != nil {
            theUserTime.addToJournal(theJournal)
            theJournal.journalTempPlatoon = theUserTime.startShiftPlatoon
            theJournal.journalTempAssignment = theUserTime.startShiftAssignment
            theJournal.journalFireStation = theUserTime.startShiftFireStation
            theJournal.journalTempApparatus = theUserTime.startShiftApparatus
            theJournal.journalFireStation = theUserTime.startShiftFireStation
        }
        theJournalLocation = FCLocation(context: context)
        theJournalLocation.guid = UUID.init()
        if let guid = theJournal.fjpJGuidForReference {
            theJournalLocation.journalGuid = guid
        }
        theJournal.theLocation = theJournalLocation
        theJournal.journalEntryType = "Station"
        theJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        theJournal.journalPrivate = true
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
        if getUserLocation.currentLocation != nil {
            theJournalLocation.location = getUserLocation.currentLocation
            if let location = theJournalLocation.location {
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                    print(location)
                    
                    if error != nil {
                        print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                        return
                    }
                    
                    if placemarks?.count != 0 {
                        let pm = placemarks![0]
                        self.theJournalLocation.city = "\(pm.locality!)"
                        self.theJournalLocation.streetNumber = "\(pm.subThoroughfare!)"
                        self.theJournalLocation.streetName = "\(pm.thoroughfare!)"
                        self.theJournalLocation.state = "\(pm.administrativeArea!)"
                        self.theJournalLocation.zip = "\(pm.postalCode!)"
                        self.theJournalLocation.latitude = location.coordinate.latitude
                        self.theJournalLocation.longitude = location.coordinate.longitude
                    }
                    else {
                        print("Problem with the data received from geocoder")
                    }
                })
            }
        }
        
    }
    
}
