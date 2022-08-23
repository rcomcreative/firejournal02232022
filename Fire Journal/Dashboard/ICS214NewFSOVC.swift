    //
    //  ICS214NewFSOVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 8/6/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

protocol ICS214NewFSOVCDelegate: AnyObject {
    func cancelTheICS214NewFSO()
    func saveTheICS214NewFSO(objectID: NSManagedObjectID)
}

class ICS214NewFSOVC: UIViewController {
    
    weak var delegate: ICS214NewFSOVCDelegate? = nil
    
    lazy var getUserLocation: GetTheUserLocation = { return GetTheUserLocation.init() }()
    var theUserRegion: MKCoordinateRegion?
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var theUserTimeOID: NSManagedObjectID!
    var theUserTime: UserTime!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    var theUserOID: NSManagedObjectID!
    var theUser: FireJournalUser!
    
    let dateFormatter = DateFormatter()
    
    var theICS214Location: FCLocation!
    var theJournal: Journal!
    var theJournalOID: NSManagedObjectID!
    var theJournalLocation: FCLocation!
    
    var theICS214Form: ICS214Form!
    var theICS214FormOID: NSManagedObjectID!
    var theMasterICS214Form: ICS214Form!
    var theMasterICS214FormOID: NSManagedObjectID!
    var theICS214ActivityLog: ICS214ActivityLog!
    var theICS214Personnel: ICS214Personnel!
    var type: TypeOfForm!
    var theIncidentAddress: String = ""
    var theJournalAddress: String = ""
    var theLatitude: String = ""
    var theLongitude: String = ""
    var theCLLocation: CLLocation!
    var theLocationAvailable: Bool = false
    
    var fetched = [ICS214Form]()
    
    var masterOrNot: Bool = false
    var theMasterGuid: String = ""
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
New ICS214
"""
    var ics214ModalHeaderV: ModalHeaderSaveDismiss!
    var ics214TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        addObservers()
        
        grabTheManagedObjects()
        
        buildTheICS214()
        
        configureModalHeaderSaveDismiss()
        configureics214TableView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
    }
    
    
    func buildTheICS214() {
        
        theICS214Form = ICS214Form(context: context)
        let iGuidDate = GuidFormatter.init(date: Date())
        let iGuid:String = iGuidDate.formatGuid()
        theICS214Form.ics214Guid = "30."+iGuid
        if masterOrNot {
            let iGuidDate = GuidFormatter.init(date: Date())
            let iGuid:String = iGuidDate.formatGuid()
            theICS214Form.ics214MasterGuid = "31."+iGuid
            theICS214Form.ics214Count = 1
            theICS214Form.ics214EffortMaster = true
            if theUser != nil {
                if let agency = theUser.ics214HomeAgency {
                    theICS214Form.ics241HomeAgency = agency
                }
                if let position = theUser.ics214Position {
                    theICS214Form.ics214ICSPosition = position
                }
            }
        } else {
            theICS214Form.ics214MasterGuid = theMasterGuid
            theICS214Form.ics214EffortMaster = false
            if theMasterICS214FormOID != nil {
                theMasterICS214Form = context.object(with: theMasterICS214FormOID) as? ICS214Form
                theICS214Form.ics241HomeAgency = theMasterICS214Form.ics241HomeAgency
                theICS214Form.ics214UserName = theMasterICS214Form.ics214UserName
                theICS214Form.ics214ICSPosition = theMasterICS214Form.ics214ICSPosition
                theICS214Form.ics214LocalIncidentNumber = theMasterICS214Form.ics214LocalIncidentNumber
                theMasterICS214Form.addToMaster(theICS214Form)
                if let name = theMasterICS214Form.ics214IncidentName {
                    if let count = theMasterICS214Form.master?.count {
                        theICS214Form.ics214IncidentName = name + " - \(count)"
                    } else {
                        theICS214Form.ics214IncidentName = name
                    }
                }
                if theMasterICS214Form.ics214JournalInfo != nil {
                    theJournal = theMasterICS214Form.ics214JournalInfo
                    if theJournal.theLocation != nil {
                        theJournalLocation = theJournal.theLocation
                    }
                }
            }
                //            }
        }
        switch type {
        case .incidentForm:
            theICS214Form.ics214Effort = type.rawValue
        case .femaTaskForceForm:
            theICS214Form.ics214Effort = type.rawValue
        case .strikeForceForm:
            theICS214Form.ics214Effort = type.rawValue
        case .otherForm:
            theICS214Form.ics214Effort = type.rawValue
        default:
            theICS214Form.ics214Effort = TypeOfForm.incidentForm.rawValue
        }
        
        if theJournal == nil {
            buildTheJournalEntry()
            
            theJournalLocation = FCLocation(context: context)
            theJournalLocation.guid = UUID.init()
            theJournalLocation.ics214Guid = theICS214Form.ics214Guid
            theJournal.theLocation = theJournalLocation
            theJournal.locationAvailable = false
            
        }
        
        theICS214Form.journalGuid = theJournal.fjpJGuidForReference
        
        if theJournal != nil {
            if theJournalLocation != nil {
                
                
                if let number = theJournalLocation.streetNumber {
                    theIncidentAddress = number + " "
                }
                if let street = theJournalLocation.streetName {
                    theIncidentAddress = theIncidentAddress + street
                }
                if let c = theJournalLocation.city {
                    theIncidentAddress = theIncidentAddress + " " + c + ", "
                }
                if let s = theJournalLocation.state {
                    theIncidentAddress = theIncidentAddress + s + ""
                }
                if let z = theJournalLocation.zip {
                    theIncidentAddress = theIncidentAddress + z
                }
                if theJournalLocation.latitude != 0.0 {
                    theLatitude = String(theJournalLocation.latitude)
                }
                if theJournalLocation.longitude != 0.0 {
                    theLongitude = String(theJournalLocation.longitude)
                }
                if theJournalLocation.location != nil {
                    theLocationAvailable = true
                    theJournal.locationAvailable = true
                } else {
                    theJournal.locationAvailable = false
                }
            } else {
                theJournal.locationAvailable = false
            }
        }
        
        if theUser != nil {
            var theName: String = ""
            if let name = theUser.userName {
                theName = name
            } else {
                if let first = theUser.firstName {
                    theName = first
                    if let last = theUser.lastName {
                        theName = theName + " " + last
                    }
                }
            }
            theICS214Form.ics214UserName = theName
            if let agency = theUser.ics214HomeAgency {
                theICS214Form.ics241HomeAgency = agency
            }
            if let position = theUser.ics214Position {
                theICS214Form.ics214ICSPosition = position
            }
        }
        
        theICS214Form.ics214FromTime = Date()
        
        if theJournal != nil {
            theJournal.addToJournalICS214Details(theICS214Form)
        }
        
    }
    
    func getMasterCount(_ theMasterGuid: String ) -> Int? {
        
        var count: Int  = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "ics214MasterGuid" , theMasterGuid)
        request.predicate = predicate
        
        do {
            self.fetched = try context.fetch(request) as! [ICS214Form]
            if !self.fetched.isEmpty {
                count = self.fetched.count
            }
        } catch let error as NSError {
            print("MasterICS214 search line 125 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
        return count
        
    }
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            ics214TableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        ics214TableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
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
    
    func presentAlert() {
        let title: InfoBodyText = .newICS214FormSubject
        let message: InfoBodyText = .newICS214FormDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapAlert() {
        let subject = InfoBodyText.mapErrorSubject.rawValue
        let message = InfoBodyText.mapErrorDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}
